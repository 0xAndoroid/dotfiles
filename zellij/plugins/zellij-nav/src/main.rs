use std::collections::{BTreeMap, HashMap, VecDeque};
use zellij_tile::prelude::*;

#[derive(Default)]
struct State {
    pending_commands: VecDeque<(Direction, bool)>,
    /// SSH panes need async window-title check via yabai to detect remote nvim
    pending_ssh: VecDeque<(Direction, bool)>,
    pane_manifest: HashMap<usize, Vec<PaneInfo>>,
    tab_info: Option<TabInfo>,
    clients: Vec<ClientInfo>,
    got_permissions: bool,
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Direction {
    Left,
    Right,
    Up,
    Down,
}

impl Direction {
    fn from_str(s: &str) -> Option<Self> {
        match s.to_lowercase().as_str() {
            "left" | "h" => Some(Direction::Left),
            "right" | "l" => Some(Direction::Right),
            "up" | "k" => Some(Direction::Up),
            "down" | "j" => Some(Direction::Down),
            _ => None,
        }
    }

    fn to_zellij(&self) -> zellij_tile::prelude::Direction {
        match self {
            Direction::Left => zellij_tile::prelude::Direction::Left,
            Direction::Right => zellij_tile::prelude::Direction::Right,
            Direction::Up => zellij_tile::prelude::Direction::Up,
            Direction::Down => zellij_tile::prelude::Direction::Down,
        }
    }

    fn to_yabai(&self) -> &'static str {
        match self {
            Direction::Left => "west",
            Direction::Right => "east",
            Direction::Up => "north",
            Direction::Down => "south",
        }
    }

    fn to_ctrl_char(&self) -> &'static str {
        match self {
            Direction::Left => "\u{0008}",  // Ctrl+H
            Direction::Right => "\u{000C}", // Ctrl+L
            Direction::Up => "\u{000B}",    // Ctrl+K
            Direction::Down => "\u{000A}",  // Ctrl+J
        }
    }
}

register_plugin!(State);

impl ZellijPlugin for State {
    fn load(&mut self, _configuration: BTreeMap<String, String>) {
        request_permission(&[
            PermissionType::ChangeApplicationState,
            PermissionType::ReadApplicationState,
            PermissionType::RunCommands,
            PermissionType::WriteToStdin,
        ]);
        subscribe(&[
            EventType::PermissionRequestResult,
            EventType::PaneUpdate,
            EventType::TabUpdate,
            EventType::ListClients,
            EventType::RunCommandResult,
        ]);
    }

    fn update(&mut self, event: Event) -> bool {
        match event {
            Event::PermissionRequestResult(result) => {
                if result == PermissionStatus::Granted {
                    self.got_permissions = true;
                }
            }
            Event::TabUpdate(tabs) => {
                self.tab_info = tabs.into_iter().find(|t| t.active);
            }
            Event::PaneUpdate(pane_manifest) => {
                self.pane_manifest = pane_manifest.panes;
            }
            Event::ListClients(clients) => {
                self.clients = clients;
                self.process_pending_commands();
            }
            Event::RunCommandResult(_exit_code, stdout, _stderr, context) => {
                if context.get("source").map(|s| s.as_str()) == Some("ssh_vim_check") {
                    self.handle_ssh_title_result(&stdout);
                }
            }
            _ => {}
        }
        false
    }

    fn pipe(&mut self, pipe_message: PipeMessage) -> bool {
        let Some(payload) = &pipe_message.payload else {
            return false;
        };

        let Some(direction) = Direction::from_str(payload) else {
            return false;
        };

        match pipe_message.name.as_str() {
            "move_focus" => {
                self.pending_commands.push_back((direction, false));
                list_clients();
            }
            "nvim_at_edge" => {
                self.pending_commands.push_back((direction, true));
                list_clients();
            }
            _ => return false,
        }
        false
    }
}

impl State {
    fn process_pending_commands(&mut self) {
        while let Some((direction, from_nvim_edge)) = self.pending_commands.pop_front() {
            self.handle_navigation(direction, from_nvim_edge);
        }
    }

    fn handle_navigation(&mut self, direction: Direction, from_nvim_edge: bool) {
        let at_edge = self.is_at_edge(direction);

        if from_nvim_edge {
            if at_edge {
                self.call_yabai(direction);
            } else {
                move_focus(direction.to_zellij());
            }
            return;
        }

        match self.check_current_pane() {
            PaneKind::Vim => {
                write_chars(direction.to_ctrl_char());
            }
            PaneKind::Ssh => {
                // Can't detect remote nvim from plugin API — query the
                // Ghostty window title (which reflects terminal titles
                // propagated through SSH) via yabai.
                self.pending_ssh.push_back((direction, at_edge));
                let mut ctx = BTreeMap::new();
                ctx.insert("source".to_string(), "ssh_vim_check".to_string());
                run_command(
                    &["yabai", "-m", "query", "--windows", "--window"],
                    ctx,
                );
            }
            PaneKind::Other => {
                if at_edge {
                    self.call_yabai(direction);
                } else {
                    move_focus(direction.to_zellij());
                }
            }
        }
    }

    fn handle_ssh_title_result(&mut self, stdout: &[u8]) {
        let Some((direction, at_edge)) = self.pending_ssh.pop_front() else {
            return;
        };

        let output = String::from_utf8_lossy(stdout);
        let title = Self::extract_json_title(&output).unwrap_or("");

        if Self::is_vim_command(title) {
            write_chars(direction.to_ctrl_char());
        } else if at_edge {
            self.call_yabai(direction);
        } else {
            move_focus(direction.to_zellij());
        }
    }

    /// Extract "title" value from yabai JSON without a JSON library.
    fn extract_json_title<'a>(json: &'a str) -> Option<&'a str> {
        let marker = "\"title\":\"";
        let start = json.find(marker)? + marker.len();
        let end = start + json[start..].find('"')?;
        Some(&json[start..end])
    }

    fn focused_pane(&self) -> Option<&PaneInfo> {
        let idx = self.tab_info.as_ref()?.position;
        self.pane_manifest
            .get(&idx)?
            .iter()
            .find(|p| p.is_focused && !p.is_plugin)
    }

    fn check_current_pane(&self) -> PaneKind {
        let Some(pane) = self.focused_pane() else {
            return if self
                .clients
                .iter()
                .any(|c| Self::is_vim_command(&c.running_command))
            {
                PaneKind::Vim
            } else {
                PaneKind::Other
            };
        };

        for client in &self.clients {
            if matches!(client.pane_id, PaneId::Terminal(id) if id == pane.id) {
                if Self::is_vim_command(&client.running_command) {
                    return PaneKind::Vim;
                }
                if Self::is_ssh_command(&client.running_command) {
                    return PaneKind::Ssh;
                }
                return PaneKind::Other;
            }
        }

        PaneKind::Other
    }

    fn is_vim_command(cmd: &str) -> bool {
        let cmd_lower = cmd.to_lowercase();
        cmd_lower.contains("nvim")
            || cmd_lower.contains("/vim")
            || cmd_lower == "vim"
            || cmd_lower.ends_with(" vim")
    }

    fn is_ssh_command(cmd: &str) -> bool {
        let cmd_lower = cmd.to_lowercase();
        let first_word = cmd_lower
            .split_whitespace()
            .next()
            .unwrap_or(&cmd_lower);
        let basename = first_word.rsplit('/').next().unwrap_or(first_word);
        matches!(basename, "ssh" | "mosh")
    }

    fn is_at_edge(&self, direction: Direction) -> bool {
        let (Some(pane), Some(tab)) = (self.focused_pane(), &self.tab_info) else {
            return false;
        };

        match direction {
            Direction::Left => pane.pane_x == 0,
            Direction::Right => {
                pane.pane_x + pane.pane_columns >= tab.display_area_columns
            }
            Direction::Up => pane.pane_y == 0,
            Direction::Down => {
                pane.pane_y + pane.pane_rows >= tab.display_area_rows
            }
        }
    }

    fn call_yabai(&self, direction: Direction) {
        run_command(
            &["yabai", "-m", "window", "--focus", direction.to_yabai()],
            BTreeMap::new(),
        );
    }
}

enum PaneKind {
    Vim,
    Ssh,
    Other,
}

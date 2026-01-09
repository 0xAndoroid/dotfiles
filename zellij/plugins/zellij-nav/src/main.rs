use std::collections::{BTreeMap, VecDeque};
use zellij_tile::prelude::*;

#[derive(Default)]
struct State {
    /// (direction, from_nvim_edge) - if from_nvim_edge, skip forwarding to nvim
    pending_commands: VecDeque<(Direction, bool)>,
    pane_info: Option<PaneInfo>,
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
                self.pane_info = None;
                let active_tab_idx = self.tab_info.as_ref().map(|t| t.position);
                if let Some(idx) = active_tab_idx {
                    if let Some(panes) = pane_manifest.panes.get(&idx) {
                        for pane in panes {
                            if pane.is_focused && !pane.is_plugin {
                                self.pane_info = Some(pane.clone());
                                break;
                            }
                        }
                    }
                }
            }
            Event::ListClients(clients) => {
                self.clients = clients;
                self.process_pending_commands();
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
                // From keybinding: queue navigation
                self.pending_commands.push_back((direction, false));
                list_clients();
            }
            "nvim_at_edge" => {
                // From nvim at_edge: handle zellij/yabai (nvim already handled its splits)
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

    fn handle_navigation(&self, direction: Direction, from_nvim_edge: bool) {
        let is_vim = self.is_current_pane_vim();
        let at_edge = self.is_at_edge(direction);

        if from_nvim_edge {
            // Called from nvim's at_edge handler - nvim already handled its splits
            // Just do zellij/yabai based on zellij edge
            if at_edge {
                self.call_yabai(direction);
            } else {
                move_focus(direction.to_zellij());
            }
        } else if is_vim {
            // Nvim pane from keybinding: only forward to nvim
            // nvim's at_edge will call back via nvim_at_edge if needed
            write_chars(direction.to_ctrl_char());
        } else if at_edge {
            // Non-nvim at zellij edge -> yabai
            self.call_yabai(direction);
        } else {
            // Non-nvim not at edge -> move zellij focus
            move_focus(direction.to_zellij());
        }
    }

    fn is_current_pane_vim(&self) -> bool {
        let Some(pane) = &self.pane_info else {
            // No pane info, check any client for nvim
            return self.clients.iter().any(|c| Self::is_vim_command(&c.running_command));
        };

        // Match focused pane with client by pane_id
        for client in &self.clients {
            let client_pane_id = match client.pane_id {
                PaneId::Terminal(id) => id,
                PaneId::Plugin(_) => continue,
            };

            if client_pane_id == pane.id && Self::is_vim_command(&client.running_command) {
                return true;
            }
        }

        // Fallback: check pane title
        Self::is_vim_command(&pane.title)
    }

    fn is_vim_command(cmd: &str) -> bool {
        let cmd_lower = cmd.to_lowercase();
        cmd_lower.contains("nvim") ||
        cmd_lower.contains("/vim") ||
        cmd_lower == "vim" ||
        cmd_lower.ends_with(" vim") ||
        cmd_lower.ends_with("/vim")
    }

    fn is_at_edge(&self, direction: Direction) -> bool {
        let (Some(pane), Some(tab)) = (&self.pane_info, &self.tab_info) else {
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

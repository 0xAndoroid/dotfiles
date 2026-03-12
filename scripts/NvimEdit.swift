import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var didOpen = false

    func application(_ application: NSApplication, open urls: [URL]) {
        guard !didOpen else { return }
        didOpen = true
        launchGhostty(with: urls.map(\.path))
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async { [self] in
            if !didOpen {
                launchGhostty(with: [])
            }
        }
    }

    func launchGhostty(with files: [String]) {
        if files.isEmpty {
            NSAppleScript(source: "tell application \"Ghostty\" to activate")?.executeAndReturnError(nil)
        } else {
            let nvim = NSHomeDirectory() + "/.local/share/bob/nvim-bin/nvim"
            let command = ([nvim] + files).map { shellQuote($0) }.joined(separator: " ")
            let escaped = command
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            let script = """
                tell application "Ghostty"
                    activate
                    set cfg to new surface configuration
                    set initial input of cfg to "exec \(escaped)" & return
                    new window with configuration cfg
                end tell
                """
            var error: NSDictionary?
            NSAppleScript(source: script)?.executeAndReturnError(&error)

            if error != nil {
                Process.run("/usr/bin/open", ["-na", "/Applications/Ghostty.app", "--args", "--command=" + command])
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NSApp.terminate(nil)
        }
    }

    func shellQuote(_ s: String) -> String {
        if s.range(of: "[^a-zA-Z0-9/_.,@:=-]", options: .regularExpression) == nil {
            return s
        }
        return "'" + s.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}

extension Process {
    @discardableResult
    static func run(_ path: String, _ arguments: [String]) -> Process {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: path)
        task.arguments = arguments
        try? task.run()
        return task
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()

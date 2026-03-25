import Foundation

// Single-instance enforcement via lock file
let lockPath = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".config/gf-alert/gf-alert.lock").path
if let existing = try? String(contentsOfFile: lockPath),
   let pid = Int32(existing.trimmingCharacters(in: .whitespacesAndNewlines)),
   pid != ProcessInfo.processInfo.processIdentifier,
   kill(pid, 0) == 0 {
    print("Another instance (pid \(pid)) is already running. Exiting.")
    exit(0)
}
try? String(ProcessInfo.processInfo.processIdentifier).write(toFile: lockPath, atomically: true, encoding: .utf8)

let config = Config.load()
print("gf-alert started — interval: \(config.intervalMinutes) min, message: \"\(config.message)\"")

let monitor = SystemStateMonitor()
let notifications = NotificationManager(config: config)
let scheduler = AlertScheduler(config: config, monitor: monitor, notifications: notifications)

notifications.requestAuthorization()
monitor.startObserving()
scheduler.start()

// Keep the process alive for notification callbacks and system observers
RunLoop.main.run()

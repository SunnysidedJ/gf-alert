import Foundation

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

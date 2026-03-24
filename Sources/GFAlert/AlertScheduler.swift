import Foundation

final class AlertScheduler {
    enum State {
        case idle
        case alerting(since: Date)
    }

    private let config: Config
    private let monitor: SystemStateMonitor
    private let notifications: NotificationManager
    private var state: State = .idle
    private var lastConfirmedTime: Date = .distantPast
    private var timer: DispatchSourceTimer?

    private let reminderInterval: TimeInterval = 5 * 60 // Re-nag every 5 minutes
    private var lastNagTime: Date = .distantPast

    init(config: Config, monitor: SystemStateMonitor, notifications: NotificationManager) {
        self.config = config
        self.monitor = monitor
        self.notifications = notifications

        // Fire alert immediately when system becomes available (wake/unlock)
        monitor.onBecameAvailable = { [weak self] in
            self?.fireAlert()
        }

        // Reset timer when user confirms
        notifications.onConfirmed = { [weak self] in
            self?.handleConfirmation()
        }
    }

    func start() {
        // Fire an alert on launch
        fireAlert()

        // Start the 30-second check loop
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + 30, repeating: 30)
        timer.setEventHandler { [weak self] in
            self?.tick()
        }
        timer.resume()
        self.timer = timer
    }

    private func tick() {
        guard monitor.isAvailable else { return }

        switch state {
        case .idle:
            let elapsed = Date().timeIntervalSince(lastConfirmedTime)
            let interval = TimeInterval(config.intervalMinutes * 60)
            if elapsed >= interval {
                fireAlert()
            }

        case .alerting:
            // Re-nag if unconfirmed for reminderInterval
            let timeSinceLastNag = Date().timeIntervalSince(lastNagTime)
            if timeSinceLastNag >= reminderInterval {
                notifications.sendAlert()
                lastNagTime = Date()
            }
        }
    }

    private func fireAlert() {
        guard monitor.isAvailable else { return }
        state = .alerting(since: Date())
        lastNagTime = Date()
        notifications.sendAlert()
    }

    private func handleConfirmation() {
        lastConfirmedTime = Date()
        state = .idle
    }
}

import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    private static let categoryIdentifier = "GF_ALERT_CATEGORY"
    private static let confirmActionIdentifier = "CONFIRM_ACTION"

    private let center = UNUserNotificationCenter.current()
    private let config: Config

    var onConfirmed: (() -> Void)?

    init(config: Config) {
        self.config = config
        super.init()
        center.delegate = self
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            if !granted {
                print("WARNING: Notification permission denied. Enable in System Settings > Notifications > gf-alert")
            }
        }

        let confirmAction = UNNotificationAction(
            identifier: Self.confirmActionIdentifier,
            title: "Done! Contacted her",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: Self.categoryIdentifier,
            actions: [confirmAction],
            intentIdentifiers: []
        )
        center.setNotificationCategories([category])
    }

    func sendAlert() {
        let content = UNMutableNotificationContent()
        content.title = "GF Alert"
        content.body = config.message
        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier
        content.interruptionLevel = .timeSensitive

        let request = UNNotificationRequest(
            identifier: "gf-alert-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        center.add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

    func removeAllNotifications() {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Show notification even when app is in foreground (command-line tool is always "foreground")
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }

    // Handle action button tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        if response.actionIdentifier == Self.confirmActionIdentifier {
            // Dispatch to main queue so state updates are serialized with the GCD
            // tick timer, preventing a race where the re-nag fires after the user
            // already confirmed.
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.removeAllNotifications()
                self.onConfirmed?()
            }
        }
    }
}

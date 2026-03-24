import Foundation
import AppKit

final class SystemStateMonitor {
    private(set) var isSleeping = false
    private(set) var isLocked = false
    private(set) var isScreenSaverActive = false

    var onBecameAvailable: (() -> Void)?

    var isAvailable: Bool {
        !isSleeping && !isLocked && !isScreenSaverActive
    }

    func startObserving() {
        let workspace = NSWorkspace.shared.notificationCenter
        let distributed = DistributedNotificationCenter.default()

        // Sleep / Wake
        workspace.addObserver(self, selector: #selector(handleSleep),
                              name: NSWorkspace.willSleepNotification, object: nil)
        workspace.addObserver(self, selector: #selector(handleWake),
                              name: NSWorkspace.didWakeNotification, object: nil)

        // Screen lock / unlock
        distributed.addObserver(self, selector: #selector(handleLock),
                                name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        distributed.addObserver(self, selector: #selector(handleUnlock),
                                name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)

        // Screen saver
        distributed.addObserver(self, selector: #selector(handleScreenSaverStart),
                                name: NSNotification.Name("com.apple.screensaver.didStart"), object: nil)
        distributed.addObserver(self, selector: #selector(handleScreenSaverStop),
                                name: NSNotification.Name("com.apple.screensaver.didStop"), object: nil)
    }

    @objc private func handleSleep(_ notification: Notification) {
        isSleeping = true
    }

    @objc private func handleWake(_ notification: Notification) {
        isSleeping = false
        if isAvailable { onBecameAvailable?() }
    }

    @objc private func handleLock(_ notification: Notification) {
        isLocked = true
    }

    @objc private func handleUnlock(_ notification: Notification) {
        isLocked = false
        if isAvailable { onBecameAvailable?() }
    }

    @objc private func handleScreenSaverStart(_ notification: Notification) {
        isScreenSaverActive = true
    }

    @objc private func handleScreenSaverStop(_ notification: Notification) {
        isScreenSaverActive = false
        if isAvailable { onBecameAvailable?() }
    }
}

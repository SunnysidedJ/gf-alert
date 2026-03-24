# gf-alert

A lightweight macOS background app that reminds you to text your girlfriend at regular intervals.

## Features

- Configurable alert interval (default: 60 minutes)
- Persistent macOS notification with a "Done! Contacted her" confirm button
- Re-nags every 5 minutes until confirmed
- Alerts immediately on wake/unlock/login/cold boot
- No alerts while laptop is sleeping, locked, or screen saver is active
- Auto-starts at login via LaunchAgent
- Invisible — no Dock icon, no menu bar, ~5MB RAM, ~0% CPU

## Requirements

- macOS 13 (Ventura) or later
- Swift 5.9+ (included with Xcode or Command Line Tools)

## Install

```bash
./install.sh
```

Then complete the required notification setup:

1. **Allow notifications**: System Settings > Notifications > gf-alert > toggle on
2. **Set alert style to "Alerts"**: System Settings > Notifications > gf-alert > Alert style > **Alerts**

> The "Alerts" style is required. With "Banners", notifications auto-dismiss before you can click the confirm button, causing the app to re-nag every 5 minutes.

## Configure

Edit `~/.config/gf-alert/config.json`:

```json
{
    "intervalMinutes": 60,
    "message": "Hey! Time to text your girlfriend :)"
}
```

Restart the agent to pick up changes:

```bash
launchctl unload ~/Library/LaunchAgents/com.gf-alert.app.plist
launchctl load ~/Library/LaunchAgents/com.gf-alert.app.plist
```

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.gf-alert.app.plist
rm ~/Library/LaunchAgents/com.gf-alert.app.plist
rm -rf ~/Applications/GFAlert.app
rm -rf ~/.config/gf-alert
```

## Logs

```
/tmp/gf-alert.stdout.log
/tmp/gf-alert.stderr.log
```

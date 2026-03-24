#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY_NAME="gf-alert"
APP_BUNDLE="$HOME/Applications/GFAlert.app"
APP_BINARY="$APP_BUNDLE/Contents/MacOS/$BINARY_NAME"
CONFIG_DIR="$HOME/.config/gf-alert"
PLIST_NAME="com.jaeheelee.gf-alert.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "Building gf-alert..."
cd "$SCRIPT_DIR"
swift build -c release

echo "Creating app bundle at $APP_BUNDLE..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
cp ".build/release/$BINARY_NAME" "$APP_BUNDLE/Contents/MacOS/$BINARY_NAME"
cp "$SCRIPT_DIR/AppBundle/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "Code-signing app bundle..."
codesign --force --sign - "$APP_BUNDLE"

echo "Setting up config..."
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    cp "$SCRIPT_DIR/config.json" "$CONFIG_DIR/config.json"
    echo "  Default config installed at $CONFIG_DIR/config.json"
else
    echo "  Config already exists at $CONFIG_DIR/config.json (skipping)"
fi

echo "Installing LaunchAgent..."
mkdir -p "$LAUNCH_AGENTS_DIR"

# Write the plist with the correct binary path
cat > "$LAUNCH_AGENTS_DIR/$PLIST_NAME" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jaeheelee.gf-alert</string>
    <key>ProgramArguments</key>
    <array>
        <string>$APP_BINARY</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/gf-alert.stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/gf-alert.stderr.log</string>
    <key>ProcessType</key>
    <string>Background</string>
</dict>
</plist>
EOF

# Unload if already loaded
launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_NAME" 2>/dev/null || true

echo "Loading LaunchAgent..."
launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo ""
echo "gf-alert installed and running!"
echo ""
echo "IMPORTANT: Allow notifications for gf-alert in:"
echo "  System Settings > Notifications > gf-alert"
echo ""
echo "Config: $CONFIG_DIR/config.json"
echo "Logs:   /tmp/gf-alert.stdout.log"
echo "        /tmp/gf-alert.stderr.log"

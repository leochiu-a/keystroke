#!/bin/bash
# Build and bundle Keystroke.app
set -e

cd "$(dirname "$0")/.."

echo "Building..."
swift build -c release 2>&1

APP_DIR=".build/Keystroke.app/Contents/MacOS"
mkdir -p "$APP_DIR"
cp .build/release/Keystroke "$APP_DIR/Keystroke"
cp Resources/Info.plist ".build/Keystroke.app/Contents/Info.plist"
codesign --force --sign - --identifier com.keystroke.app ".build/Keystroke.app"

echo "Built: .build/Keystroke.app"
echo "Run with: open .build/Keystroke.app"

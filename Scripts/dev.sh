#!/bin/bash
# Dev mode: watch for changes and auto-rebuild + relaunch
set -e

cd "$(dirname "$0")/.."

APP_BUNDLE=".build/Keystroke.app"
APP_EXEC="$APP_BUNDLE/Contents/MacOS/Keystroke"
PROCESS_NAME="Keystroke"

build_and_run() {
    echo ""
    echo "==> Building..."
    if swift build -c debug 2>&1; then
        mkdir -p "$APP_BUNDLE/Contents/MacOS"
        cp .build/debug/Keystroke "$APP_EXEC"
        cp Resources/Info.plist "$APP_BUNDLE/Contents/Info.plist"
        echo "==> Launching..."
        open "$APP_BUNDLE"
    else
        echo "==> Build failed!"
    fi
}

kill_app() {
    pkill -x "$PROCESS_NAME" 2>/dev/null || true
    sleep 0.3
}

# Check if fswatch is installed
if ! command -v fswatch &>/dev/null; then
    echo "fswatch is required. Install with: brew install fswatch"
    exit 1
fi

# Initial build
kill_app
build_and_run

echo ""
echo "==> Watching for changes in Sources/ and Resources/..."
echo "==> Press Ctrl+C to stop"
echo ""

# Watch for changes and rebuild
fswatch -o -l 0.5 --exclude '\.build' Sources/ Resources/ Package.swift | while read -r _; do
    echo ""
    echo "==> Change detected, rebuilding..."
    kill_app
    build_and_run
done

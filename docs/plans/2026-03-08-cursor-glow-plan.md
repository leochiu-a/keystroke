# Keystroke - 游標光圈 macOS App 實作計畫

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 建立一個 macOS menu bar app，在全螢幕透明 overlay 上顯示游標光暈和點擊漣漪效果。

**Architecture:** Swift Package 結構，將可測試邏輯（MouseTracker、RippleState）與 UI 層分離。核心邏輯用 TDD 驅動，UI 層手動驗證。App 使用 SwiftUI App lifecycle + AppDelegate 建立透明 NSWindow overlay。

**Tech Stack:** Swift 6, SwiftUI, AppKit (NSWindow, NSEvent), Swift Package Manager

---

### Task 1: 專案骨架

**Files:**
- Create: `Package.swift`
- Create: `Sources/Keystroke/KeystrokeApp.swift`
- Create: `Tests/KeystrokeTests/PlaceholderTest.swift`

**Step 1: 建立 Package.swift**

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Keystroke",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Keystroke",
            path: "Sources/Keystroke"
        ),
        .testTarget(
            name: "KeystrokeTests",
            dependencies: ["Keystroke"],
            path: "Tests/KeystrokeTests"
        ),
    ]
)
```

**Step 2: 建立最小 App 進入點**

```swift
// Sources/Keystroke/KeystrokeApp.swift
import SwiftUI

@main
struct KeystrokeApp: App {
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
```

**Step 3: 建立 placeholder test 確認測試能跑**

```swift
// Tests/KeystrokeTests/PlaceholderTest.swift
import Testing

@Test func placeholder() {
    #expect(1 + 1 == 2)
}
```

**Step 4: 跑測試確認通過**

Run: `cd /Users/leochiu/Desktop/keystroke && swift test 2>&1`
Expected: All tests passed

**Step 5: Commit**

```bash
git init
git add Package.swift Sources/ Tests/
git commit -m "feat: init project skeleton with SPM"
```

---

### Task 2: ClickEvent model

**Files:**
- Create: `Sources/Keystroke/Models/ClickEvent.swift`
- Create: `Tests/KeystrokeTests/ClickEventTests.swift`

**Step 1: 寫失敗測試**

```swift
// Tests/KeystrokeTests/ClickEventTests.swift
import Testing
import Foundation
@testable import Keystroke

@Test func clickEventStoresPositionAndTimestamp() {
    let position = CGPoint(x: 100, y: 200)
    let event = ClickEvent(position: position)

    #expect(event.position == position)
    #expect(event.timestamp.timeIntervalSinceNow < 1)
    #expect(event.id != UUID())
}

@Test func clickEventIsIdentifiable() {
    let a = ClickEvent(position: .zero)
    let b = ClickEvent(position: .zero)
    #expect(a.id != b.id)
}
```

**Step 2: 跑測試確認失敗**

Run: `swift test 2>&1`
Expected: FAIL — ClickEvent not found

**Step 3: 實作最小程式碼**

```swift
// Sources/Keystroke/Models/ClickEvent.swift
import Foundation

struct ClickEvent: Identifiable {
    let id = UUID()
    let position: CGPoint
    let timestamp = Date()
}
```

**Step 4: 跑測試確認通過**

Run: `swift test 2>&1`
Expected: All tests passed

**Step 5: Commit**

```bash
git add Sources/Keystroke/Models/ Tests/KeystrokeTests/ClickEventTests.swift
git commit -m "feat: add ClickEvent model"
```

---

### Task 3: MouseTracker 核心邏輯

**Files:**
- Create: `Sources/Keystroke/MouseTracker.swift`
- Create: `Tests/KeystrokeTests/MouseTrackerTests.swift`

**Step 1: 寫失敗測試 — 初始狀態**

```swift
// Tests/KeystrokeTests/MouseTrackerTests.swift
import Testing
import Foundation
@testable import Keystroke

@Test @MainActor func initialState() {
    let tracker = MouseTracker()
    #expect(tracker.cursorPosition == .zero)
    #expect(tracker.clicks.isEmpty)
    #expect(tracker.isEnabled == true)
}
```

**Step 2: 跑測試確認失敗**

Run: `swift test 2>&1`
Expected: FAIL — MouseTracker not found

**Step 3: 實作最小 MouseTracker**

```swift
// Sources/Keystroke/MouseTracker.swift
import SwiftUI

@MainActor
final class MouseTracker: ObservableObject {
    @Published var cursorPosition: CGPoint = .zero
    @Published var clicks: [ClickEvent] = []
    @Published var isEnabled: Bool = true
    @Published var glowColor: Color = .yellow
}
```

**Step 4: 跑測試確認通過**

Run: `swift test 2>&1`
Expected: All tests passed

**Step 5: Commit**

```bash
git add Sources/Keystroke/MouseTracker.swift Tests/KeystrokeTests/MouseTrackerTests.swift
git commit -m "feat: add MouseTracker with initial state"
```

---

### Task 4: MouseTracker — updatePosition 和 addClick

**Files:**
- Modify: `Sources/Keystroke/MouseTracker.swift`
- Modify: `Tests/KeystrokeTests/MouseTrackerTests.swift`

**Step 1: 寫失敗測試 — updatePosition**

在 `MouseTrackerTests.swift` 追加：

```swift
@Test @MainActor func updatePosition() {
    let tracker = MouseTracker()
    tracker.updatePosition(CGPoint(x: 42, y: 99))
    #expect(tracker.cursorPosition == CGPoint(x: 42, y: 99))
}

@Test @MainActor func updatePositionIgnoredWhenDisabled() {
    let tracker = MouseTracker()
    tracker.isEnabled = false
    tracker.updatePosition(CGPoint(x: 42, y: 99))
    #expect(tracker.cursorPosition == .zero)
}
```

**Step 2: 跑測試確認失敗**

Run: `swift test 2>&1`
Expected: FAIL — updatePosition not found

**Step 3: 實作 updatePosition**

在 `MouseTracker` 中加入：

```swift
func updatePosition(_ point: CGPoint) {
    guard isEnabled else { return }
    cursorPosition = point
}
```

**Step 4: 跑測試確認通過**

Run: `swift test 2>&1`
Expected: All tests passed

**Step 5: 寫失敗測試 — addClick**

在 `MouseTrackerTests.swift` 追加：

```swift
@Test @MainActor func addClick() {
    let tracker = MouseTracker()
    let pos = CGPoint(x: 10, y: 20)
    tracker.addClick(at: pos)
    #expect(tracker.clicks.count == 1)
    #expect(tracker.clicks.first?.position == pos)
}

@Test @MainActor func addClickIgnoredWhenDisabled() {
    let tracker = MouseTracker()
    tracker.isEnabled = false
    tracker.addClick(at: CGPoint(x: 10, y: 20))
    #expect(tracker.clicks.isEmpty)
}
```

**Step 6: 跑測試確認失敗**

Run: `swift test 2>&1`
Expected: FAIL — addClick not found

**Step 7: 實作 addClick**

在 `MouseTracker` 中加入：

```swift
func addClick(at position: CGPoint) {
    guard isEnabled else { return }
    clicks.append(ClickEvent(position: position))
}
```

**Step 8: 跑測試確認通過**

Run: `swift test 2>&1`
Expected: All tests passed

**Step 9: Commit**

```bash
git add Sources/Keystroke/MouseTracker.swift Tests/KeystrokeTests/MouseTrackerTests.swift
git commit -m "feat: add updatePosition and addClick to MouseTracker"
```

---

### Task 5: MouseTracker — removeClick（清除過期漣漪）

**Files:**
- Modify: `Sources/Keystroke/MouseTracker.swift`
- Modify: `Tests/KeystrokeTests/MouseTrackerTests.swift`

**Step 1: 寫失敗測試**

```swift
@Test @MainActor func removeClick() {
    let tracker = MouseTracker()
    tracker.addClick(at: .zero)
    let clickId = tracker.clicks.first!.id
    tracker.removeClick(id: clickId)
    #expect(tracker.clicks.isEmpty)
}

@Test @MainActor func removeClickOnlyRemovesTarget() {
    let tracker = MouseTracker()
    tracker.addClick(at: CGPoint(x: 1, y: 1))
    tracker.addClick(at: CGPoint(x: 2, y: 2))
    let firstId = tracker.clicks.first!.id
    tracker.removeClick(id: firstId)
    #expect(tracker.clicks.count == 1)
    #expect(tracker.clicks.first?.position == CGPoint(x: 2, y: 2))
}
```

**Step 2: 跑測試確認失敗**

Run: `swift test 2>&1`
Expected: FAIL — removeClick not found

**Step 3: 實作 removeClick**

```swift
func removeClick(id: UUID) {
    clicks.removeAll { $0.id == id }
}
```

**Step 4: 跑測試確認通過**

Run: `swift test 2>&1`
Expected: All tests passed

**Step 5: Commit**

```bash
git add Sources/Keystroke/MouseTracker.swift Tests/KeystrokeTests/MouseTrackerTests.swift
git commit -m "feat: add removeClick to MouseTracker"
```

---

### Task 6: OverlayView — 光暈效果 (UI，非 TDD)

**Files:**
- Create: `Sources/Keystroke/Views/CursorGlowView.swift`
- Create: `Sources/Keystroke/Views/OverlayView.swift`

**Step 1: 建立 CursorGlowView**

```swift
// Sources/Keystroke/Views/CursorGlowView.swift
import SwiftUI

struct CursorGlowView: View {
    let position: CGPoint
    let color: Color
    let size: CGFloat = 80

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.0)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .position(position)
            .allowsHitTesting(false)
    }
}
```

**Step 2: 建立 OverlayView**

```swift
// Sources/Keystroke/Views/OverlayView.swift
import SwiftUI

struct OverlayView: View {
    @ObservedObject var tracker: MouseTracker

    var body: some View {
        ZStack {
            if tracker.isEnabled {
                CursorGlowView(position: tracker.cursorPosition, color: tracker.glowColor)

                ForEach(tracker.clicks) { click in
                    RippleView(click: click) {
                        tracker.removeClick(id: click.id)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}
```

**Step 3: 跑測試確認沒有 compilation error**

Run: `swift build 2>&1`
Expected: Build succeeded（RippleView 尚未建立，會失敗 — 在 Task 7 解決）

**Step 4: Commit**（在 Task 7 一起 commit）

---

### Task 7: RippleView — 漣漪動畫 (UI，非 TDD)

**Files:**
- Create: `Sources/Keystroke/Views/RippleView.swift`

**Step 1: 建立 RippleView**

```swift
// Sources/Keystroke/Views/RippleView.swift
import SwiftUI

struct RippleView: View {
    let click: ClickEvent
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.6

    var body: some View {
        Circle()
            .stroke(Color.white.opacity(opacity), lineWidth: 2)
            .frame(width: 80, height: 80)
            .scaleEffect(scale)
            .position(click.position)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 1.0
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    onComplete()
                }
            }
    }
}
```

**Step 2: 跑 build 確認編譯通過**

Run: `swift build 2>&1`
Expected: Build succeeded

**Step 3: 跑測試確認全部通過**

Run: `swift test 2>&1`
Expected: All tests passed

**Step 4: Commit**

```bash
git add Sources/Keystroke/Views/
git commit -m "feat: add CursorGlowView, RippleView, OverlayView"
```

---

### Task 8: AppDelegate — 透明 NSWindow overlay + 滑鼠監聽

**Files:**
- Create: `Sources/Keystroke/AppDelegate.swift`
- Modify: `Sources/Keystroke/KeystrokeApp.swift`

**Step 1: 建立 AppDelegate**

```swift
// Sources/Keystroke/AppDelegate.swift
import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: NSWindow?
    let mouseTracker = MouseTracker()
    var mouseMovedMonitor: Any?
    var mouseClickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupOverlayWindow()
        setupMouseMonitors()
    }

    private func setupOverlayWindow() {
        guard let screen = NSScreen.main else { return }

        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = NSHostingView(rootView: OverlayView(tracker: mouseTracker))
        window.orderFrontRegardless()

        overlayWindow = window
    }

    private func setupMouseMonitors() {
        mouseMovedMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            guard let self, let screen = NSScreen.main else { return }
            let point = CGPoint(x: event.locationInWindow.x, y: screen.frame.height - event.locationInWindow.y)
            Task { @MainActor in
                self.mouseTracker.updatePosition(point)
            }
        }

        mouseClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let screen = NSScreen.main else { return }
            let point = CGPoint(x: event.locationInWindow.x, y: screen.frame.height - event.locationInWindow.y)
            Task { @MainActor in
                self.mouseTracker.addClick(at: point)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = mouseMovedMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = mouseClickMonitor { NSEvent.removeMonitor(monitor) }
    }
}
```

**Step 2: 更新 KeystrokeApp.swift**

```swift
// Sources/Keystroke/KeystrokeApp.swift
import SwiftUI

@main
struct KeystrokeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
```

**Step 3: 跑 build 確認通過**

Run: `swift build 2>&1`
Expected: Build succeeded

**Step 4: 跑測試確認通過**

Run: `swift test 2>&1`
Expected: All tests passed

**Step 5: Commit**

```bash
git add Sources/Keystroke/AppDelegate.swift Sources/Keystroke/KeystrokeApp.swift
git commit -m "feat: add transparent overlay window and mouse monitors"
```

---

### Task 9: Menu Bar 控制面板

**Files:**
- Create: `Sources/Keystroke/Views/MenuBarView.swift`
- Modify: `Sources/Keystroke/AppDelegate.swift`

**Step 1: 建立 MenuBarView**

```swift
// Sources/Keystroke/Views/MenuBarView.swift
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var tracker: MouseTracker

    private let colors: [(String, Color)] = [
        ("Yellow", .yellow),
        ("Blue", .blue),
        ("Green", .green),
        ("Pink", .pink),
    ]

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Enabled", isOn: $tracker.isEnabled)
                .toggleStyle(.switch)

            Divider()

            Text("Glow Color")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                ForEach(colors, id: \.0) { name, color in
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: tracker.glowColor == color ? 2 : 0)
                        )
                        .onTapGesture {
                            tracker.glowColor = color
                        }
                        .accessibilityLabel(name)
                }
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 180)
    }
}
```

**Step 2: 在 AppDelegate 中加入 StatusBar item**

在 `AppDelegate` 中加入屬性和 setup 方法：

```swift
var statusItem: NSStatusItem?

// 在 applicationDidFinishLaunching 中加入：
setupMenuBar()

private func setupMenuBar() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem?.button {
        button.image = NSImage(systemSymbolName: "cursor.rays", accessibilityDescription: "Keystroke")
    }

    let popover = NSPopover()
    popover.contentSize = NSSize(width: 180, height: 160)
    popover.behavior = .transient
    popover.contentViewController = NSHostingController(rootView: MenuBarView(tracker: mouseTracker))

    statusItem?.button?.action = #selector(togglePopover(_:))
    statusItem?.button?.target = self
}

@objc func togglePopover(_ sender: AnyObject?) {
    // Store popover as property and toggle
}
```

注意：需要將 popover 存為屬性以便 toggle。完整實作見 Step 3。

**Step 3: 完整更新 AppDelegate（含 popover toggle）**

將 `popover` 提升為 `AppDelegate` 的屬性：

```swift
var popover: NSPopover?

private func setupMenuBar() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem?.button {
        button.image = NSImage(systemSymbolName: "cursor.rays", accessibilityDescription: "Keystroke")
        button.action = #selector(togglePopover(_:))
        button.target = self
    }

    let pop = NSPopover()
    pop.contentSize = NSSize(width: 180, height: 160)
    pop.behavior = .transient
    pop.contentViewController = NSHostingController(rootView: MenuBarView(tracker: mouseTracker))
    popover = pop
}

@objc func togglePopover(_ sender: AnyObject?) {
    guard let popover, let button = statusItem?.button else { return }
    if popover.isShown {
        popover.performClose(sender)
    } else {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
}
```

**Step 4: 跑 build 確認通過**

Run: `swift build 2>&1`
Expected: Build succeeded

**Step 5: 跑測試確認通過**

Run: `swift test 2>&1`
Expected: All tests passed

**Step 6: Commit**

```bash
git add Sources/Keystroke/Views/MenuBarView.swift Sources/Keystroke/AppDelegate.swift
git commit -m "feat: add menu bar control panel"
```

---

### Task 10: 手動整合測試 + 微調

**Step 1: 執行 App**

Run: `swift run 2>&1`

**Step 2: 驗證清單**

- [ ] 游標移動時看到柔和光暈跟隨
- [ ] 點擊時看到漣漪從點擊位置擴散
- [ ] 漣漪約 0.5 秒後消失
- [ ] Menu bar 出現 cursor.rays icon
- [ ] 點擊 icon 打開控制面板
- [ ] Toggle 可以開關效果
- [ ] 顏色選擇可以改變光暈顏色
- [ ] Quit 按鈕可以退出 App

**Step 3: 修正發現的問題（如果有）**

**Step 4: 最終 commit**

```bash
git add -A
git commit -m "fix: integration adjustments"
```

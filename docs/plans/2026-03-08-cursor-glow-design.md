# Keystroke - 游標光圈 macOS App 設計

## 概述

一個 macOS menu bar app，在整個螢幕上覆蓋一個透明視窗，顯示跟隨游標的柔和光暈效果，以及點擊時的漣漪擴散動畫。

## 技術方案

NSWindow overlay + SwiftUI（方案 A）。建立透明 NSWindow 覆蓋全螢幕，用 SwiftUI 繪製動畫效果，透過 NSEvent global monitor 監聽滑鼠事件。

## 架構

```
KeystrokeApp (SwiftUI App, menu bar only)
├── AppDelegate
│   ├── 建立透明 NSWindow overlay
│   ├── NSEvent global monitor
│   └── Menu bar icon + popover
├── OverlayView (SwiftUI)
│   ├── CursorGlowView — 柔和光暈
│   └── RippleEffectView — 漣漪擴散
└── MouseTracker (ObservableObject)
    ├── cursorPosition: CGPoint
    ├── clicks: [ClickEvent]
    ├── isEnabled: Bool
    └── glowColor: Color
```

## 光暈效果

- RadialGradient，中心半透明，向外漸變到透明
- ~80pt 直徑，即時跟隨游標

## 漣漪點擊效果

- 點擊時產生圓圈，從 ~20pt 擴大到 ~80pt
- 透明度 0.6 → 0，時長 ~0.5s，easeOut
- 支援多個同時漣漪

## Menu Bar 控制面板

- 啟用/停用切換
- 顏色選擇（黃、藍、綠、粉紅）
- 退出按鈕

## 權限

- 需要 Accessibility 權限（NSEvent.addGlobalMonitorForEvents）

## NSWindow 設定

- level: .screenSaver
- isOpaque: false
- backgroundColor: .clear
- ignoresMouseEvents: true
- collectionBehavior: [.canJoinAllSpaces, .fullScreenAuxiliary]

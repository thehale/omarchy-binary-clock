// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "BinaryTime.js" as BinaryTime
import "ClockFace.js" as ClockFace

// A binary clock for the bar, drawn in braille: 19:37 reads ⢀⡁⢠⡆.
//
// This file only wires things together. BinaryTime.js turns the time into
// bits, ClockFace.js lays the bits out as braille text, DotMatrix.qml paints
// it, and StockCalendar.qml borrows the stock clock's calendar popup.
//
// Left click opens the calendar.
BarWidget {
  id: root
  moduleName: "dev.jhale.binaryclock.omarchy" // Must match `id` in manifest.json

  // Overrides come from this widget's entry in shell.json's bar.layout
  readonly property bool showSeconds: setting("seconds", false)
  readonly property string separator: setting("separator", "")
  readonly property real ghostOpacity: setting("ghostOpacity", 0.25)

  readonly property var components: BinaryTime.asBinaryTime(clock.hours, clock.minutes, clock.seconds, showSeconds)

  // ---- Bar popout contract, forwarded to the calendar. Bar.findPanelWidget
  //      requires open/close/opened on the bar-widget root, Bar.requestPopout
  //      prefers closeForPopoutSwitch over close, and KeyboardPanel reads
  //      popoutSwitchClosing back off its owner.
  readonly property bool opened: calendar.opened
  readonly property bool popoutSwitchClosing: calendar.popoutSwitchClosing

  function open() {
    calendar.open();
  }
  function close() {
    calendar.close();
  }
  function togglePanel() {
    calendar.toggle();
  }
  function closeForPopoutSwitch() {
    calendar.closeForPopoutSwitch();
  }

  // The open-panel dot under the pill takes the width of the dots, not the
  // padded slot around them.
  readonly property real openPanelIndicatorWidth: face.implicitWidth
  readonly property real openPanelIndicatorHeight: Math.max(Style.space(10), Math.round(Style.bar.iconSlot * 0.55))

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  SystemClock {
    id: clock
    precision: root.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
  }

  StockCalendar {
    id: calendar
    moduleName: root.moduleName
    bar: root.bar
    settings: root.settings
    anchorItem: button
    hostWidget: root
  }

  // The IPC target follows moduleName, so the id is spelled once in this file.
  IpcHandler {
    target: root.moduleName

    function open(): void {
      root.open();
    }
    function close(): void {
      root.close();
    }
    function show(): void {
      root.open();
    }
    function hide(): void {
      root.close();
    }
    function toggle(): void {
      root.togglePanel();
    }
  }

  WidgetButton {
    id: button
    width: root.width
    height: root.height
    bar: root.bar
    labelVisible: false
    hasVisualContent: true
    fixedWidth: face.implicitWidth + scaledHorizontalMargin * 2
    horizontalMargin: 8.75
    tooltipText: calendar.available ? "Click for the calendar" : ""

    onPressed: root.togglePanel()

    DotMatrix {
      id: face
      anchors.centerIn: parent
      lit: ClockFace.litText(root.components, root.separator)
      ghost: ClockFace.ghostText(root.components, root.separator)
      ghostOpacity: root.ghostOpacity
      color: button.foreground
      fontFamily: button.fontFamily
      fontSize: button.fontSize
    }
  }
}

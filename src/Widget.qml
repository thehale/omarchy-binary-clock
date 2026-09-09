// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0

import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "BinaryTime.js" as BinaryTime
import "ClockFace.js" as ClockFace

// A binary clock for the bar, drawn in braille: 19:37 reads ⢀⡁⢠⡆.
//
// This file only wires things together. BinaryTime.js turns the time into
// bits, ClockFace.js lays the bits out as braille text, and DotMatrix.qml
// paints it.
BarWidget {
  id: root
  moduleName: "dev.jhale.binaryclock.omarchy" // Must match `id` in manifest.json

  // Overrides come from this widget's entry in shell.json's bar.layout
  readonly property bool showSeconds: setting("seconds", false)
  readonly property string separator: setting("separator", "")
  readonly property real ghostOpacity: setting("ghostOpacity", 0.25)

  readonly property var components: BinaryTime.asBinaryTime(clock.hours, clock.minutes, clock.seconds, showSeconds)

  implicitWidth: face.implicitWidth + Style.spacing.controlPaddingX * 2
  implicitHeight: barSize

  SystemClock {
    id: clock
    precision: root.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
  }

  DotMatrix {
    id: face
    anchors.centerIn: parent
    lit: ClockFace.litText(root.components, root.separator)
    ghost: ClockFace.ghostText(root.components, root.separator)
    ghostOpacity: root.ghostOpacity
    color: root.bar ? root.bar.barForeground : Color.foreground
    fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
    fontSize: Style.font.body
  }
}

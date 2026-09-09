// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0

import QtQuick

// Two layers of braille text in one footprint: a dim ghost of every dot that
// could light, and the bright dots that are lit. Pure view; the strings come
// from ClockFace.js.
Item {
  id: root

  property string lit: ""
  property string ghost: ""
  property real ghostOpacity: 0.25
  property color color: "white"
  property string fontFamily: ""
  property real fontSize: 12

  implicitWidth: ghostLabel.implicitWidth
  implicitHeight: ghostLabel.implicitHeight

  Text {
    id: ghostLabel
    anchors.centerIn: parent
    text: root.ghost
    textFormat: Text.PlainText
    color: root.color
    opacity: root.ghostOpacity
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
  }

  Text {
    anchors.centerIn: parent
    text: root.lit
    textFormat: Text.PlainText
    color: root.color
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
  }
}

// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0

import QtQuick
import Quickshell

// The stock clock's calendar popup, borrowed straight from the shell rather
// than copied here. Wraps the loader and the property injection the stock
// bar widget does, and exposes the panel's open/close surface so the host
// widget can forward the bar's popout contract to it.
//
// The panel is the shell's own file, not a published component, so what it
// offers is checked once it loads. A shell that has changed it leaves
// `available` false and the calendar out of reach, with one line in the log
// saying why, rather than failing on the first click.
Item {
  id: root

  // Injected into the panel, mirroring what its own bar widget hands it.
  property QtObject bar: null
  property var settings: ({})
  property var anchorItem: null
  property var hostWidget: null

  // The panel persists its own settings (week start, birth year) under its
  // moduleName. Pointing that at the host keeps them in the host's entry,
  // since the stock clock's entry is not in the layout while the host is.
  property string moduleName: ""

  readonly property var requiredMethods: ["open", "close", "toggle", "closeForPopoutSwitch"]
  readonly property var requiredProperties: ["opened", "popoutSwitchClosing", "moduleName", "bar", "settings", "anchorItem", "hostWidget"]

  readonly property var panel: loader.status === Loader.Ready && loader.item ? loader.item : null
  readonly property bool available: panel !== null && conforms(panel)

  readonly property bool opened: available && panel.opened === true
  readonly property bool popoutSwitchClosing: available && panel.popoutSwitchClosing === true

  function open() {
    if (available)
      panel.open();
  }

  function close() {
    if (available)
      panel.close();
  }

  function toggle() {
    if (available)
      panel.toggle();
  }

  function closeForPopoutSwitch() {
    if (available)
      panel.closeForPopoutSwitch();
  }

  function conforms(target) {
    for (var i = 0; i < requiredMethods.length; i++) {
      if (typeof target[requiredMethods[i]] !== "function")
        return false;
    }
    for (var j = 0; j < requiredProperties.length; j++) {
      if (!(requiredProperties[j] in target))
        return false;
    }
    return true;
  }

  function inject() {
    if (!available)
      return;
    panel.moduleName = root.moduleName;
    panel.bar = root.bar;
    panel.settings = root.settings;
    panel.anchorItem = root.anchorItem;
    panel.hostWidget = root.hostWidget;
  }

  onBarChanged: inject()
  onSettingsChanged: inject()
  onAnchorItemChanged: inject()
  onHostWidgetChanged: inject()

  Loader {
    id: loader
    active: true
    source: Quickshell.shellDir + "/plugins/panels/clock/Panel.qml"
    visible: false
    onStatusChanged: {
      if (status === Loader.Error)
        console.warn("binary clock: the stock calendar failed to load from " + source + "; calendar disabled");
      else if (status === Loader.Ready && !root.conforms(item))
        console.warn("binary clock: the stock calendar at " + source + " no longer has the expected surface; calendar disabled");
    }
    onLoaded: {
      root.inject();
      Qt.callLater(root.inject);
    }
  }
}

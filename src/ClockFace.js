// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0
//
// Layout: the components of a binary time arranged as braille text. Each
// digit takes one column of a cell, top to bottom worth 8, 4, 2, 1. A tens
// digit takes the right column of its cell and the ones digit the left
// column of the next, so the two lit columns sit together and the dark outer
// columns space the components apart without any separator: 19:37 is ⢀⡁⢠⡆.

.import "Braille.js" as Braille

// The lit dots: the time itself.
function litText(components, separator) {
  return text(components, separator, function(bit) { return bit.active })
}

// Every dot that could light. Drawn dimly under the lit dots, it gives the eye
// a grid to count against, so a lone bottom dot reads as "1" and not as "8".
function ghostText(components, separator) {
  return text(components, separator, function(bit) { return bit.possible })
}

function text(components, separator, raised) {
  return components.map(function(component) {
    return Braille.cell([], component.tens.bits.map(raised)) + Braille.cell(component.ones.bits.map(raised), [])
  }).join(separator)
}

if (typeof module !== "undefined") {
  module.exports = {
    litText: litText,
    ghostText: ghostText
  }
}

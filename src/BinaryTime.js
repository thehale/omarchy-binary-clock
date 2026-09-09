// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0
//
// Domain: a wall-clock time as binary digits. Ported from the core of
// github.com/thehale/BinaryClock (src/utils/binaryTime.ts). Knows nothing
// about how the bits are drawn.

// A decimal digit as four bits, most significant first. Each bit says whether
// it is set for this digit, and whether it could ever be set for a digit in
// this place: the tens of hours never exceed 2, so its 8 and 4 bits are
// impossible, and a display can leave them out rather than show them off.
function asBinaryDigit(number, maxValue) {
  var bits = []
  for (var value = 8; value >= 1; value /= 2) {
    bits.push({
      value: value,
      active: (number & value) > 0,
      possible: maxValue >= value
    })
  }
  return { value: number, bits: bits }
}

// The components of a 24-hour time, each as a tens and a ones digit. Seconds
// are included only when asked, since a clock that changes every second is a
// price only a seconds clock should pay.
function asBinaryTime(hours, minutes, seconds, withSeconds) {
  var components = [
    component("hours", hours, 2),
    component("minutes", minutes, 5)
  ]
  if (withSeconds) components.push(component("seconds", seconds, 5))
  return components
}

function component(name, value, maxTens) {
  return {
    name: name,
    tens: asBinaryDigit(Math.floor(value / 10), maxTens),
    ones: asBinaryDigit(value % 10, 9)
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    asBinaryDigit: asBinaryDigit,
    asBinaryTime: asBinaryTime
  }
}

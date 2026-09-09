// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0
//
// Encoding: dots in a 2x4 braille cell to a Unicode character. Knows nothing
// about clocks or digits.

// Unicode braille assigns one bit per dot, read top down: dots 1, 2, 3, 7
// for the left column and dots 4, 5, 6, 8 for the right.
var BLANK = 0x2800
var LEFT_COLUMN = [0x01, 0x02, 0x04, 0x40]
var RIGHT_COLUMN = [0x08, 0x10, 0x20, 0x80]

// One cell. Each column is four booleans, top to bottom, true where a dot is
// raised; a missing column is empty.
function cell(leftDots, rightDots) {
  return String.fromCharCode(BLANK | columnBits(leftDots, LEFT_COLUMN) | columnBits(rightDots, RIGHT_COLUMN))
}

function columnBits(dots, column) {
  var bits = 0
  for (var i = 0; i < column.length; i++) {
    if (dots && dots[i]) bits |= column[i]
  }
  return bits
}

if (typeof module !== "undefined") {
  module.exports = {
    cell: cell
  }
}

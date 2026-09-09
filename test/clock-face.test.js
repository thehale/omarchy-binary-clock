// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0

const { test } = require("node:test")
const assert = require("node:assert/strict")
const { load } = require("./qml.js")
const BinaryTime = load("src/BinaryTime.js")
const ClockFace = load("src/ClockFace.js")

const at = (h, m, s, showSeconds) => BinaryTime.asBinaryTime(h, m, s, showSeconds)

// The reference glyphs: a tens digit in the right column of its cell, the
// ones digit in the left column of the next.
const pair = (tens, ones) => [{ name: "x", tens: BinaryTime.asBinaryDigit(tens, 15), ones: BinaryTime.asBinaryDigit(ones, 15) }]

test("tens digits render in the right column", () => {
  const tens = n => ClockFace.litText(pair(n, 0), "")[0]
  assert.equal(tens(1), "⢀")
  assert.equal(tens(3), "⢠")
  assert.equal(tens(7), "⢰")
  assert.equal(tens(9), "⢈")
  assert.equal(tens(15), "⢸")
})

test("ones digits render in the left column", () => {
  const ones = n => ClockFace.litText(pair(0, n), "")[1]
  assert.equal(ones(1), "⡀")
  assert.equal(ones(3), "⡄")
  assert.equal(ones(7), "⡆")
  assert.equal(ones(9), "⡁")
  assert.equal(ones(15), "⡇")
})

test("the lit layer renders the time", () => {
  assert.equal(ClockFace.litText(at(19, 37, 0, false), ""), "⢀⡁⢠⡆")
  assert.equal(ClockFace.litText(at(19, 37, 13, true), ""), "⢀⡁⢠⡆⢀⡄")
})

test("the ghost layer renders every dot that could light", () => {
  assert.equal(ClockFace.ghostText(at(0, 0, 0, false), ""), "⢠⡇⢰⡇")
})

test("a separator goes between components", () => {
  assert.equal(ClockFace.ghostText(at(0, 0, 0, true), " "), "⢠⡇ ⢰⡇ ⢰⡇")
})

test("midnight lights nothing", () => {
  assert.equal(ClockFace.litText(at(0, 0, 0, false), ""), "⠀⠀⠀⠀")
})

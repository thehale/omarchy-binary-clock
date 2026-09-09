// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0

const { test } = require("node:test")
const assert = require("node:assert/strict")
const Braille = require("./qml.js").load("src/Braille.js")

const none = [false, false, false, false]
const all = [true, true, true, true]

test("an empty cell is the blank braille pattern", () => {
  assert.equal(Braille.cell(none, none), "⠀")
  assert.equal(Braille.cell(), "⠀")
})

test("dots fill the left column top to bottom", () => {
  assert.equal(Braille.cell([true, false, false, false], none), "⠁")
  assert.equal(Braille.cell([false, true, false, false], none), "⠂")
  assert.equal(Braille.cell([false, false, true, false], none), "⠄")
  assert.equal(Braille.cell([false, false, false, true], none), "⡀")
  assert.equal(Braille.cell(all, none), "⡇")
})

test("dots fill the right column top to bottom", () => {
  assert.equal(Braille.cell(none, [true, false, false, false]), "⠈")
  assert.equal(Braille.cell(none, [false, true, false, false]), "⠐")
  assert.equal(Braille.cell(none, [false, false, true, false]), "⠠")
  assert.equal(Braille.cell(none, [false, false, false, true]), "⢀")
  assert.equal(Braille.cell(none, all), "⢸")
})

test("both columns combine in one cell", () => {
  assert.equal(Braille.cell(all, all), "⣿")
})

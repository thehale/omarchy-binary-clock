// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0

const { test } = require("node:test")
const assert = require("node:assert/strict")
const LayoutEntry = require("./qml.js").load("src/LayoutEntry.js")

test("a patch becomes a fresh entry keyed by the module", () => {
  assert.deepEqual(LayoutEntry.patched("acme.clock", {}, { seconds: true }), { id: "acme.clock", seconds: true })
})

test("other settings carry over and a stale id is never copied", () => {
  const settings = { id: "stale", separator: " ", seconds: false }
  assert.deepEqual(LayoutEntry.patched("acme.clock", settings, { seconds: true }), {
    id: "acme.clock",
    separator: " ",
    seconds: true
  })
})

test("a patch can change several settings at once", () => {
  assert.deepEqual(LayoutEntry.patched("acme.clock", {}, { seconds: true, separator: ":" }), {
    id: "acme.clock",
    seconds: true,
    separator: ":"
  })
})

test("nothing in the patch can change the id", () => {
  assert.deepEqual(LayoutEntry.patched("acme.clock", {}, { id: "other", seconds: true }), { id: "acme.clock", seconds: true })
})

test("the original settings are left untouched", () => {
  const settings = { seconds: false }
  LayoutEntry.patched("acme.clock", settings, { seconds: true })
  assert.deepEqual(settings, { seconds: false })
})

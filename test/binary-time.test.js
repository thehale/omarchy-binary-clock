// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0

const { test } = require("node:test")
const assert = require("node:assert/strict")
const BinaryTime = require("./qml.js").load("src/BinaryTime.js")

const lit = digit => digit.bits.filter(b => b.active).map(b => b.value)
const possible = digit => digit.bits.filter(b => b.possible).map(b => b.value)

test("a digit's bits run 8, 4, 2, 1 from the top", () => {
  assert.deepEqual(BinaryTime.asBinaryDigit(0, 9).bits.map(b => b.value), [8, 4, 2, 1])
})

test("a digit lights the dots whose values sum to it", () => {
  assert.deepEqual(lit(BinaryTime.asBinaryDigit(0, 9)), [])
  assert.deepEqual(lit(BinaryTime.asBinaryDigit(1, 9)), [1])
  assert.deepEqual(lit(BinaryTime.asBinaryDigit(5, 9)), [4, 1])
  assert.deepEqual(lit(BinaryTime.asBinaryDigit(9, 9)), [8, 1])
})

test("a digit knows which bits a digit in its place can ever set", () => {
  assert.deepEqual(possible(BinaryTime.asBinaryDigit(0, 2)), [2, 1])
  assert.deepEqual(possible(BinaryTime.asBinaryDigit(0, 5)), [4, 2, 1])
  assert.deepEqual(possible(BinaryTime.asBinaryDigit(0, 9)), [8, 4, 2, 1])
})

test("a time splits into named components of tens and ones", () => {
  const digits = time => time.map(c => [c.name, c.tens.value, c.ones.value])
  assert.deepEqual(digits(BinaryTime.asBinaryTime(23, 59, 7, false)), [["hours", 2, 3], ["minutes", 5, 9]])
  assert.deepEqual(digits(BinaryTime.asBinaryTime(23, 59, 7, true)), [["hours", 2, 3], ["minutes", 5, 9], ["seconds", 0, 7]])
})

test("tens places are capped at what a clock can reach", () => {
  const [hours, minutes, seconds] = BinaryTime.asBinaryTime(0, 0, 0, true)
  assert.deepEqual(possible(hours.tens), [2, 1])
  assert.deepEqual(possible(minutes.tens), [4, 2, 1])
  assert.deepEqual(possible(seconds.tens), [4, 2, 1])
  assert.deepEqual(possible(hours.ones), [8, 4, 2, 1])
})

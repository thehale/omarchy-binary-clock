// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0
//
// Load a QML-side JavaScript file under node. QML's `.import "x.js" as X`
// line has no meaning to node, so it is rewritten to a require of the same
// file before evaluation.

const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function load(file) {
  const absolute = path.resolve(__dirname, "..", file)
  const source = fs.readFileSync(absolute, "utf8").replace(
    /^\.import "([^"]+)" as (\w+)$/gm,
    (_, dependency, name) => `const ${name} = load(${JSON.stringify(path.join(path.dirname(file), dependency))})`
  )
  const module = { exports: {} }
  vm.runInThisContext(`(function(module, load) {\n${source}\n})`, { filename: absolute })(module, load)
  return module.exports
}

module.exports = { load }

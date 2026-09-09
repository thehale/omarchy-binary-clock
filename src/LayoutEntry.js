// Copyright (c) Joseph Hale, 2026
// SPDX-License-Identifier: MPL-2.0
//
// A widget's inline entry in shell.json's bar.layout: `{ id, ...settings }`.
// The shell hands the widget the settings and takes back a whole entry, so a
// change is a fresh entry, under the widget's canonical id, with a patch
// applied on top of what was there.

function patched(moduleName, settings, patch) {
  var entry = {}
  for (var key in settings) entry[key] = settings[key]
  for (var changed in patch) entry[changed] = patch[changed]
  entry.id = moduleName
  return entry
}

if (typeof module !== "undefined") {
  module.exports = {
    patched: patched
  }
}

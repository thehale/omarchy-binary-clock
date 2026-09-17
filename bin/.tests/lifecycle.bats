#!/usr/bin/env bats
# Copyright (c) Joseph Hale, 2026
# SPDX-License-Identifier: MPL-2.0
#
# bin/preview, bin/reload and bin/unpreview against a fake home and stubbed
# omarchy commands, so the shell.json edits can be checked without a shell.

setup() {
	REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
	PLUGIN_ID="$(jq -r '.id' "$REPO/manifest.json")"

	export HOME="${BATS_TEST_TMPDIR:?}/home"
	export XDG_STATE_HOME="$HOME/.local/state"
	mkdir -p "$HOME/.config/omarchy"
	SHELL_JSON="$HOME/.config/omarchy/shell.json"
	LINK="$HOME/.config/omarchy/plugins/$PLUGIN_ID"

	cat >"$SHELL_JSON" <<-JSON
		{
		  "version": 1,
		  "bar": {
		    "centerAnchor": "omarchy.clock",
		    "layout": {
		      "left": [{ "id": "omarchy.menu" }],
		      "center": [
		        { "id": "omarchy.indicators" },
		        { "id": "omarchy.clock", "format": "dddd HH:mm" },
		        { "id": "omarchy.weather" }
		      ],
		      "right": [{ "id": "omarchy.power" }]
		    }
		  },
		  "plugins": []
		}
	JSON

	stub_omarchy
	cd "$BATS_TEST_TMPDIR"
}

# `omarchy` and `omarchy-shell` as the scripts use them: the shell already
# knows every plugin, and removing one deletes its link.
stub_omarchy() {
	mkdir -p "$BATS_TEST_TMPDIR/bin"
	cat >"$BATS_TEST_TMPDIR/bin/omarchy" <<-STUB
		#!/usr/bin/env bash
		case "\$1 \$2" in
		"plugin list") echo '[{"id":"$PLUGIN_ID"}]' ;;
		"plugin remove") rm "$LINK" ;;
		"restart shell") echo restarted ;;
		esac
	STUB
	cat >"$BATS_TEST_TMPDIR/bin/omarchy-shell" <<-STUB
		#!/usr/bin/env bash
		echo ok
	STUB
	chmod +x "$BATS_TEST_TMPDIR/bin/"*
	export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

center_ids() {
	jq -c '[.bar.layout.center[].id]' "$SHELL_JSON"
}

@test "preview links the checkout and takes the stock clock's slot and anchor" {
	run "$REPO/bin/preview"

	[ "$status" -eq 0 ]
	[ "$(readlink -f "$LINK")" = "$REPO" ]
	[ "$(center_ids)" = "[\"omarchy.indicators\",\"$PLUGIN_ID\",\"omarchy.weather\"]" ]
	[ "$(jq -r '.bar.centerAnchor' "$SHELL_JSON")" = "$PLUGIN_ID" ]
}

@test "preview leaves the rest of shell.json alone" {
	"$REPO/bin/preview"

	[ "$(jq -c '.bar.layout.left, .bar.layout.right, .plugins' "$SHELL_JSON")" = '[{"id":"omarchy.menu"}]
[{"id":"omarchy.power"}]
[]' ]
}

@test "preview twice changes nothing more" {
	"$REPO/bin/preview"
	run "$REPO/bin/preview"

	[ "$status" -eq 0 ]
	[[ "$output" == *"Already linked"* ]]
	[[ "$output" == *"already in the bar"* ]]
	[ "$(center_ids)" = "[\"omarchy.indicators\",\"$PLUGIN_ID\",\"omarchy.weather\"]" ]
}

@test "preview refuses to replace something that is not this checkout" {
	mkdir -p "$LINK"

	run "$REPO/bin/preview"

	[ "$status" -ne 0 ]
	[[ "$output" == *"not a link to this checkout"* ]]
	[ "$(center_ids)" = '["omarchy.indicators","omarchy.clock","omarchy.weather"]' ]
}

@test "preview without a stock clock appends to the center and keeps the anchor" {
	jq '.bar.layout.center |= map(select(.id != "omarchy.clock")) | .bar.centerAnchor = "omarchy.weather"' "$SHELL_JSON" >tmp && mv tmp "$SHELL_JSON"

	"$REPO/bin/preview"

	[ "$(center_ids)" = "[\"omarchy.indicators\",\"omarchy.weather\",\"$PLUGIN_ID\"]" ]
	[ "$(jq -r '.bar.centerAnchor' "$SHELL_JSON")" = "omarchy.weather" ]
}

@test "unpreview restores the stock clock with its settings, slot and anchor" {
	"$REPO/bin/preview"

	run "$REPO/bin/unpreview"

	[ "$status" -eq 0 ]
	[ ! -e "$LINK" ]
	[ "$(jq -c '.bar.layout.center' "$SHELL_JSON")" = '[{"id":"omarchy.indicators"},{"id":"omarchy.clock","format":"dddd HH:mm"},{"id":"omarchy.weather"}]' ]
	[ "$(jq -r '.bar.centerAnchor' "$SHELL_JSON")" = "omarchy.clock" ]
}

@test "unpreview after a preview without a stock clock just removes the widget" {
	jq '.bar.layout.center |= map(select(.id != "omarchy.clock")) | .bar.centerAnchor = "omarchy.weather"' "$SHELL_JSON" >tmp && mv tmp "$SHELL_JSON"
	"$REPO/bin/preview"

	"$REPO/bin/unpreview"

	[ "$(center_ids)" = '["omarchy.indicators","omarchy.weather"]' ]
	[ "$(jq -r '.bar.centerAnchor' "$SHELL_JSON")" = "omarchy.weather" ]
}

@test "unpreview does not add a second stock clock when one is already back" {
	"$REPO/bin/preview"
	jq '.bar.layout.center += [{id: "omarchy.clock"}]' "$SHELL_JSON" >tmp && mv tmp "$SHELL_JSON"

	"$REPO/bin/unpreview"

	[ "$(center_ids)" = '["omarchy.indicators","omarchy.weather","omarchy.clock"]' ]
	[ "$(jq -r '.bar.centerAnchor' "$SHELL_JSON")" = "omarchy.clock" ]
}

@test "unpreview without a preview falls back to the stock defaults" {
	jq --arg id "$PLUGIN_ID" '.bar.layout.center[1] = {id: $id} | .bar.centerAnchor = $id' "$SHELL_JSON" >tmp && mv tmp "$SHELL_JSON"

	run "$REPO/bin/unpreview"

	[ "$status" -eq 0 ]
	[ "$(center_ids)" = '["omarchy.indicators","omarchy.clock","omarchy.weather"]' ]
	[ "$(jq -r '.bar.centerAnchor' "$SHELL_JSON")" = "omarchy.clock" ]
	[[ "$output" == *"was not linked"* ]]
}

@test "unpreview leaves a foreign plugin folder alone" {
	mkdir -p "$LINK"

	run "$REPO/bin/unpreview"

	[ "$status" -eq 0 ]
	[ -d "$LINK" ]
	[[ "$output" == *"leaving it alone"* ]]
}

@test "reload refuses until the checkout is linked" {
	run "$REPO/bin/reload"

	[ "$status" -ne 0 ]
	[[ "$output" == *"run bin/preview first"* ]]
}

@test "reload restarts the shell once linked" {
	"$REPO/bin/preview"

	run "$REPO/bin/reload"

	[ "$status" -eq 0 ]
	[[ "$output" == *"restarted"* ]]
}

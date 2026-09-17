<div align="center">

# Binary Clock

A nerdy way to tell time on your Omarchy bar 🕓

![The binary clock ticking in the Omarchy bar](docs/binary-clock.gif)

<!-- BADGES -->
[![License: MPL-2.0](https://badgen.net/github/license/thehale/omarchy-binary-clock)](https://github.com/thehale/omarchy-binary-clock/blob/main/LICENSE)
[![Sponsor thehale on GitHub](https://badgen.net/badge/icon/Sponsor/pink?icon=github&label)](https://github.com/sponsors/thehale)
[![Joseph Hale's software engineering blog](https://jhale.dev/badges/website.svg)](https://jhale.dev)
[![Follow Joseph Hale on LinkedIn](https://jhale.dev/badges/follow.svg)](https://www.linkedin.com/comm/mynetwork/discovery-see-all?usecase=PEOPLE_FOLLOWS&followMember=thehale)
</div>

## Quickstart

```bash
omarchy plugin add https://github.com/thehale/omarchy-binary-clock.git --enable
```

> [!WARNING]
> Plugins run as unsandboxed code inside the long-lived `omarchy-shell`
process, so read the source before you enable one.

Then swap `omarchy.clock` for `dev.jhale.binaryclock.omarchy` in the `center`
layout of `~/.config/omarchy/shell.json`, and point `centerAnchor` at it too so
the bar stays centered on the clock:

```json
"bar": {
  "centerAnchor": "dev.jhale.binaryclock.omarchy",
  "layout": {
    "center": [
      { "id": "omarchy.indicators" },
      { "id": "dev.jhale.binaryclock.omarchy" },
      ...
    ]
  }
}
```

Each digit is one column of dots worth 8, 4, 2, and 1 from top to bottom, so
19:37 reads `⢀⡁⢠⡆`. The faint dots are the ones that could light.

## Settings

Left-click the clock for the calendar, the same one the stock clock shows.
Right-click the clock to toggle seconds. The choice is written back to
`shell.json`, so it sticks. You can also add any of these to the widget's
entry in `shell.json` by hand:

| Setting        | Default | Meaning                                        |
| -------------- | ------- | ---------------------------------------------- |
| `seconds`      | `false` | Add a third pair of cells for seconds          |
| `separator`    | `""`    | Text between the hour, minute and second cells |
| `ghostOpacity` | `0.25`  | How faint the unlit dots are, `0` hides them   |

## Development

```bash
bin/setup  # Install the tools
bin/ci     # Run the checks
bin/ci --fix  # Fix what can be fixed automatically
```

To try the plugin on your own bar while you work on it:

```bash
bin/preview    # Link this folder in and swap it for the stock clock
bin/reload     # Restart the shell to pick up edits
bin/unpreview  # Put the stock clock back and drop the link
```

The code is layered, one concept per file under `src/`:

| File                | Layer    | Concern                                    |
| ------------------- | -------- | ------------------------------------------ |
| `BinaryTime.js`     | Domain   | A time as binary digits (from BinaryClock) |
| `Braille.js`        | Encoding | Dots in a 2x4 cell to a Unicode character  |
| `ClockFace.js`      | Layout   | Digits as braille text, lit and ghost      |
| `LayoutEntry.js`    | Config   | Rewriting the widget's `shell.json` entry  |
| `DotMatrix.qml`     | View     | The two stacked text layers                |
| `StockCalendar.qml` | View     | The shell's own calendar popup, borrowed   |
| `Widget.qml`        | Wiring   | Bar widget: settings, clock, clicks, IPC   |

The JavaScript layers are unit tested under node (`test/`), loaded through a
small shim that understands QML's `.import` lines.

- [Develop a plugin](https://plugins.omarchy.org/develop.html)
- [Publish a plugin](https://plugins.omarchy.org/publish.html)
- [Shell plugins, in the Omarchy manual](https://omarchy.org/manual/shell-plugins/)

## License

Copyright (c) 2026 Joseph Hale, All Rights Reserved

Provided under the terms of the [Mozilla Public License, version 2.0](./LICENSE)

<details>

<summary><b>What does the MPL-2.0 license allow/require?</b></summary>

### TL;DR

You can use files from this project in both open source and proprietary
applications, provided you include the above attribution. However, if
you modify any code in this project, or copy blocks of it into your own
code, you must publicly share the resulting files (note, not your whole
program) under the MPL-2.0. The best way to do this is via a Pull
Request back into this project.

If you have any other questions, you may also find Mozilla's [official
FAQ](https://www.mozilla.org/en-US/MPL/2.0/FAQ/) for the MPL-2.0 license
insightful.

If you dislike this license, you can contact me about negotiating a paid
contract with different terms.

**Disclaimer:** This TL;DR is just a summary. All legal questions
regarding usage of this project must be handled according to the
official terms specified in the `LICENSE` file.

### Why the MPL-2.0 license?

I believe that an open-source software license should ensure that code
can be used everywhere.

Strict copyleft licenses, like the GPL family of licenses, fail to
fulfill that vision because they only permit code to be used in other
GPL-licensed projects. Permissive licenses, like the MIT and Apache
licenses, allow code to be used everywhere but fail to prevent
proprietary or GPL-licensed projects from limiting access to any
improvements they make.

In contrast, the MPL-2.0 license allows code to be used in any software
project, while ensuring that any improvements remain available for
everyone.

</details>

# Agent instructions

`bin/setup` installs everything this repository builds with. Run it on clone,
and again whenever you want a consistent environment. It expects `mise` on
PATH already and stops with a link when it is missing. Do not make it install
mise: a plugin that downloads and runs an installer is refused publication.
The template it was scaffolded from installs mise here and keeps that on
purpose, so this difference is a decision rather than a sync fallen behind.

`bin/ci` runs every check, and `bin/ci --fix` fixes what a tool can fix on its
own. Run it before calling a change done.

## The check bin/ci does not run

A plugin can pass everything here and still be refused publication, because
the marketplace scans the tree for things `bin/ci` never looks at.

- The scanner is `scripts/security-baseline-*.mjs` in
  `omacom/omarchy-plugin-marketplace`, MIT licensed. Clone it at a pinned
  commit rather than vendoring a copy, which would go stale silently.
- `buildSecurityBaseline({ repository, repoUrl, commitSha, files })` takes
  `files` as `{ path, content }`, so it runs against a working tree with
  nothing pushed. Filter the tree through `isSecurityScanPath` from
  `scripts/security-baseline-scope.mjs` first.
- Do not wire it into `bin/`. Everything in `bin/` is scanned, so a script
  there that fetched the marketplace would report `curl-pipe-shell` against
  itself.
- The scanner skips `.github`, `docs`, `test`, `tests`, `spec`, `specs`,
  `fixtures`, `coverage` and `node_modules`. Moving a file into one of those
  is not a fix unless the file belongs there anyway.
- Read the result from `outcome` and `findings`. `enforcementMode` is
  advisory, so `blocksApproval` reads `false` even on a commit the
  marketplace refuses.
- Nothing in the scanner knows what a checksum is. It fires on how a
  downloaded file is named afterwards, not on whether anyone verified it.
  Report it upstream if that ever changes, because a scanner that reads a
  recorded digest is the one thing that would reopen how the template
  installs mise.

`bin/ci` is the check for this repository. Run it before calling work done.

The marketplace runs a second check that `bin/ci` does not, and a plugin can
pass every check here and still be blocked from publication by it.

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

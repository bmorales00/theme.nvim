# Contributing

Changes should preserve the renderer invariants documented in [`DEVELOPMENT.md`](DEVELOPMENT.md).

In particular:

- keep palettes as complete semantic data tables;
- keep filesystem and harness concerns outside the plugin;
- do not make integration rendering depend on a plugin being installed;
- validate and compile completely before mutating Neovim; and
- retain the original Lackluster MIT license and attribution.

Run `make format`, `make lint`, and `make test` before submitting a change.

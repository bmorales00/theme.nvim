# theme.nvim development

## Architecture

The public entry points are:

- `colors/lackluster.lua` for native `:colorscheme lackluster` loading;
- `lua/theme/init.lua` for the Lua API; and
- `lua/lualine/themes/lackluster.lua` for Lualine discovery.

Palette application has four stages:

1. `theme.schema` strictly validates and normalizes a complete semantic palette into a fresh table.
2. `theme.options` validates presentation settings independently from palette colors.
3. `theme.build` derives the editor theme, and `theme.renderer` compiles every highlight and terminal color without changing Neovim.
4. `theme.init` snapshots affected state, commits the compiled result, and rolls back on failure.

The reusable mappings in `theme.foundation`, `theme.highlights`, and `theme.integrations` derive from `slugbyte/lackluster.nvim`. They remain independent of plugin installation state: setting a nonexistent plugin's highlight groups is safe in Neovim.

## Adding a palette

Create a complete module under `lua/theme/palettes/` using `theme.palettes.lackluster` as the schema-v1 reference. Do not create a new renderer or duplicate the highlight definitions.

A palette module is data only. It must not read files, inspect environment variables, mutate Neovim, or use `"none"` as a color. Whether a palette receives its own `colors/*.lua` entry point is a separate public-interface decision.

## Adding an integration

Create a function under `lua/theme/integrations/` that receives the derived theme and returns a `ThemeHighlightGroup`. Add it to the unconditional list in `theme.highlights`.

Integration code must not require the target plugin or inspect whether it is installed. It should use derived semantic theme roles rather than importing a built-in palette.

## Invariants

- External palettes are complete and strictly validated before rendering.
- Renderer functions do not mutate the palette or Neovim.
- Every invocation receives a newly normalized palette table.
- Palette colors and presentation settings remain separate.
- Failed validation, rendering, or highlight application emits no `ColorScheme` event.
- Failed validation or rendering performs no active mutation.
- Failed highlight application restores the previous owned highlights and relevant Neovim state.
- Successful public application sets `g:colors_name` to `lackluster` and emits exactly one `ColorScheme` event.
- The plugin never reads generated harness data itself.

## Verification

`make test` uses `tests/run.sh`, which creates disposable XDG config, data, state, and cache directories before starting `nvim --clean --headless -i NONE`.

The suite verifies the built-in appearance, semantic palette validation, core and integration highlights, ANSI colors, transparency, comment style, ColorScheme events, A → B → A application, caller isolation, and rollback after an injected Neovim write failure.

Run all checks before review:

```sh
make format
make lint
make test
```

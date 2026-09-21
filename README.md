# theme.nvim

`theme.nvim` is a native Neovim colorscheme renderer. It owns one rendering path for core, Treesitter, LSP, diagnostic, terminal, and third-party plugin highlights, while palettes remain complete semantic data tables.

The built-in `lackluster` palette reproduces the previously configured `lackluster-hack` appearance:

- green keywords and return keywords;
- blue exception keywords;
- gray italic comments;
- transparent normal, menu, and popup backgrounds; and
- an opaque Telescope background.

The renderer is based on the MIT-licensed implementation from [slugbyte/lackluster.nvim](https://github.com/slugbyte/lackluster.nvim). The original copyright and license are retained in [`LICENSE.md`](LICENSE.md).

## Installation

The repository must be on Neovim's runtime path. A plugin manager is only an installation mechanism; the colorscheme itself uses Neovim's standard `colors/` entry point and APIs.

```lua
{
    "bmorales00/theme.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd.colorscheme("lackluster")
    end,
}
```

No external palette source or runtime dependency is required for the built-in theme.

## API

```lua
local theme = require("theme")

theme.setup({
    transparent = {
        normal = true,
        menu = true,
        popup = true,
        telescope = false,
    },
    styles = {
        comments = { italic = true },
        diagnostics = { undercurl = true },
    },
    ui = {
        hide_end_of_buffer = true,
    },
})

-- Apply a complete external semantic palette.
local ok, err = theme.apply(palette)

-- Reapply the active palette, or apply a supplied replacement.
ok, err = theme.reload()
ok, err = theme.reload(palette)
```

`setup()` changes presentation options only. Palette colors never contain `"none"`; transparency is controlled independently.

The remaining public helpers are:

- `theme.validate_palette(palette)` validates without changing Neovim.
- `theme.default_palette()` returns a fresh copy of the built-in palette.
- `theme.active_palette()` returns a fresh copy of the active palette, or `nil` before the first application.
- `theme.lualine()` returns a Lualine theme generated from the active palette.

The renderer deep-copies and validates the complete palette before compiling highlights. Application is transactional: affected highlights, terminal colors, options, and `g:colors_name` are restored if a Neovim write fails. A successful direct `apply()` or `reload()` emits `ColorScheme` exactly once. `:colorscheme lackluster` relies on Neovim's native event and also emits it exactly once.

## Semantic palette schema

Every external palette must set `schema_version = 1` and provide every role. Unknown roles, missing roles, non-string colors, and colors outside `#RRGGBB` form are rejected before any active state changes.

The built-in [`lua/theme/palettes/lackluster.lua`](lua/theme/palettes/lackluster.lua) file is the canonical complete example.

### UI roles

- Accents: `primary`, `on_primary`, `secondary`, and `tertiary`.
- Base UI: `background`, `foreground`, `surface`, `surface_variant`, `surface_container`, `surface_container_high`, and `surface_container_highest`.
- Surface content: `on_surface`, `on_surface_variant`, `muted`, and `outline`.
- Inverse UI: `inverse_surface` and `inverse_on_surface`.
- Selection: `selection` and `on_selection`.
- State colors: `error`, `warning`, `success`, and `info`.

### Editor-specific roles

Neovim needs syntax and editor roles that are not expressible using general UI colors alone. Schema version 1 explicitly defines:

- editor chrome: `comment`, `whitespace`, `nontext`, `line_number`, `line_number_active`, `parameter`, and `diagnostic_text`;
- syntax: `keyword`, `keyword_return`, `keyword_exception`, `string`, `string_escape`, `function_definition`, `function_call`, `variable`, `member`, `constant`, `builtin_constant`, `builtin`, `type`, `type_definition`, `primitive_type`, `punctuation`, `tag`, and `special`;
- diffs: `add`, `change`, `delete`, and `context`; and
- delimiter nesting: `rainbow.level_1` through `rainbow.level_7`.

### Terminal roles

`terminal.normal` and `terminal.bright` must each provide the eight named ANSI colors: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, and `white`.

## External palette boundary

`theme.nvim` deliberately performs no JSON or filesystem access. A Neovim configuration bridge may read generated data from a stable external location, decode it into the schema above, and pass the resulting table to `theme.apply()`.

The renderer has no knowledge of personal-system paths, generated filenames, theme selectors, or the tool that produced a palette.

## Integrations

All supported highlight groups are defined on every application. Rendering does not inspect Lazy, query installed plugins, or require plugin modules to be loaded.

The retained integrations cover Bufferline, nvim-cmp-compatible groups, Dashboard, Flash, GitGutter, Gitsigns, Headlines, IndentMini, Lazy, Lightbulb, LSPConfig, Mason, Mini, Navic, Noice, Notify, Oil, Rainbow Delimiters, Scrollbar, Telescope, Todo Comments, NvimTree, Trouble, Which Key, and Yanky.

## Development

```sh
make format
make lint
make test
```

Tests start Neovim headlessly with isolated XDG directories and no user configuration. See [`DEVELOPMENT.md`](DEVELOPMENT.md) for the internal rendering pipeline.

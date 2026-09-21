local theme = require("theme")

local failures = {}
local assertions = 0

local function fail(message)
    table.insert(failures, message)
end

local function equal(actual, expected, message)
    assertions = assertions + 1
    if not vim.deep_equal(actual, expected) then
        fail(("%s\nexpected: %s\nactual:   %s"):format(message, vim.inspect(expected), vim.inspect(actual)))
    end
end

local function truthy(value, message)
    assertions = assertions + 1
    if not value then
        fail(message)
    end
end

local function hex(value)
    return tonumber(value:sub(2), 16)
end

local function hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
end

local function all_highlights()
    return vim.api.nvim_get_hl(0, {})
end

local function canonical(value)
    if type(value) ~= "table" then
        return type(value) == "string" and string.format("%q", value) or tostring(value)
    end

    local keys = vim.tbl_keys(value)
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)
    local parts = { "{" }
    for _, key in ipairs(keys) do
        table.insert(parts, string.format("%q", tostring(key)))
        table.insert(parts, ":")
        table.insert(parts, canonical(value[key]))
        table.insert(parts, ",")
    end
    table.insert(parts, "}")
    return table.concat(parts)
end

local event_count = 0
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(args)
        event_count = event_count + 1
        equal(args.match, "lackluster", "ColorScheme uses the public colorscheme name")
    end,
})

vim.cmd.colorscheme("lackluster")
equal(event_count, 1, ":colorscheme emits ColorScheme exactly once")
equal(vim.g.colors_name, "lackluster", "colorscheme name is accurate")
equal(
    vim.fn.sha256(canonical(theme.default_palette())),
    "8c60a4e9b8a71c2e45873aee77cff73fcf287f2b001e4f8c7ef635593dde1f60",
    "built-in palette matches the complete golden definition"
)

equal(hl("Normal").fg, hex("#cccccc"), "built-in Normal foreground")
equal(hl("Normal").bg, nil, "built-in Normal is transparent")
equal(hl("Pmenu").fg, hex("#7a7a7a"), "built-in menu foreground")
equal(hl("Pmenu").bg, nil, "built-in menu is transparent")
equal(hl("NormalFloat").fg, hex("#cccccc"), "built-in popup foreground")
equal(hl("NormalFloat").bg, nil, "built-in popup is transparent")
equal(hl("TelescopeNormal").bg, hex("#101010"), "Telescope keeps its explicit background")

equal(hl("@keyword").fg, hex("#789978"), "Treesitter keyword uses Lackluster green")
equal(hl("@keyword.return").fg, hex("#789978"), "Treesitter return keyword uses Lackluster green")
equal(hl("@keyword.exception").fg, hex("#7788aa"), "Treesitter exception keyword uses Lackluster blue")
equal(hl("Comment").fg, hex("#444444"), "legacy comment color")
equal(hl("Comment").italic, true, "legacy comments are italic")
equal(hl("@comment").fg, hex("#444444"), "Treesitter comment color")
equal(hl("@comment").italic, true, "Treesitter comments are italic")

equal(hl("DiagnosticError").fg, hex("#d70000"), "diagnostic error color")
equal(hl("DiagnosticUnderlineWarn").undercurl, true, "diagnostics use undercurl")
equal(hl("@lsp.type.function").fg, hl("@function").fg, "LSP function resolves to Treesitter function")
equal(hl("GitSignsAdd").fg, hex("#555555"), "Gitsigns integration")
equal(hl("OilDir").fg, hex("#555555"), "Oil integration")
equal(hl("LazyNormal").bg, nil, "Lazy popup follows popup transparency")
equal(hl("MiniSurround").bg, hex("#708090"), "Mini integration")
equal(hl("TroubleTextError").fg, hex("#d70000"), "Trouble integration")

equal(vim.g.terminal_color_0, "#000000", "normal ANSI black")
equal(vim.g.terminal_color_15, "#dddddd", "bright ANSI white")

local ok, err = theme.apply()
truthy(ok, "direct built-in apply succeeds: " .. tostring(err))
equal(event_count, 2, "direct apply emits ColorScheme exactly once")

local palette_a = theme.default_palette()
palette_a.ui.background = "#111111"
palette_a.ui.foreground = "#eeeeee"
palette_a.ui.primary = "#123456"
palette_a.ui.error = "#aa0000"
palette_a.editor.keyword = "#abcdef"
palette_a.editor.function_definition = "#fedcba"
palette_a.diff.add = "#22aa44"
palette_a.terminal.normal.black = "#010203"

local palette_b = theme.default_palette()
palette_b.ui.background = "#222222"
palette_b.ui.foreground = "#dddddd"
palette_b.ui.primary = "#654321"
palette_b.ui.error = "#ff3300"
palette_b.editor.keyword = "#102030"
palette_b.editor.function_definition = "#405060"
palette_b.diff.add = "#44bb66"
palette_b.terminal.normal.black = "#030201"

ok, err = theme.apply(palette_a)
truthy(ok, "synthetic palette A succeeds: " .. tostring(err))
equal(hl("Normal").fg, hex("#eeeeee"), "palette A reaches core highlights")
equal(hl("TelescopeNormal").bg, hex("#111111"), "palette A reaches plugin backgrounds")
equal(hl("Search").bg, hex("#123456"), "palette A reaches UI highlights")
equal(hl("@keyword").fg, hex("#abcdef"), "palette A reaches Treesitter highlights")
equal(hl("@function").fg, hex("#fedcba"), "palette A reaches function highlights")
equal(hl("DiagnosticError").fg, hex("#aa0000"), "palette A reaches diagnostics")
equal(hl("OilCreate").fg, hex("#22aa44"), "palette A reaches plugin diff highlights")
equal(vim.g.terminal_color_0, "#010203", "palette A reaches terminal colors")
local palette_a_highlights = all_highlights()

ok, err = theme.apply(palette_b)
truthy(ok, "synthetic palette B succeeds: " .. tostring(err))
equal(hl("Normal").fg, hex("#dddddd"), "palette B replaces core colors")
equal(hl("@keyword").fg, hex("#102030"), "palette B replaces syntax colors")
equal(hl("DiagnosticError").fg, hex("#ff3300"), "palette B replaces diagnostic colors")
equal(vim.g.terminal_color_0, "#030201", "palette B replaces terminal colors")

ok, err = theme.apply(palette_a)
truthy(ok, "return to synthetic palette A succeeds: " .. tostring(err))
equal(all_highlights(), palette_a_highlights, "A -> B -> A leaves no stale highlights")
equal(vim.g.terminal_color_0, "#010203", "A -> B -> A leaves no stale terminal color")

local before_invalid = all_highlights()
local before_invalid_name = vim.g.colors_name
local before_invalid_event_count = event_count
local incomplete_ok = theme.apply({ schema_version = 1 })
equal(incomplete_ok, nil, "incomplete palette is rejected")
equal(all_highlights(), before_invalid, "incomplete palette does not mutate highlights")
equal(vim.g.colors_name, before_invalid_name, "incomplete palette does not mutate colors_name")
equal(event_count, before_invalid_event_count, "incomplete palette emits no event")

local invalid = theme.default_palette()
invalid.ui.primary = "not-a-color"
invalid.ui.unstable_role = "#ffffff"
local invalid_ok = theme.apply(invalid)
equal(invalid_ok, nil, "invalid and unknown palette roles are rejected")
equal(all_highlights(), before_invalid, "invalid palette does not mutate highlights")
equal(event_count, before_invalid_event_count, "invalid palette emits no event")

local invalid_option_ok = theme.apply(theme.default_palette(), { transparent = { normal = "yes" } })
equal(invalid_option_ok, nil, "invalid presentation options are rejected")
equal(all_highlights(), before_invalid, "invalid presentation options do not mutate highlights")
equal(event_count, before_invalid_event_count, "invalid presentation options emit no event")

local renderer = require("theme.renderer")
local original_compile = renderer.compile
renderer.compile = function()
    error("intentional renderer failure")
end
local render_failure_ok = theme.apply(palette_b)
renderer.compile = original_compile
equal(render_failure_ok, nil, "renderer failure is reported")
equal(all_highlights(), before_invalid, "renderer failure does not mutate highlights")
equal(event_count, before_invalid_event_count, "renderer failure emits no event")

ok, err = theme.apply(theme.default_palette(), {
    transparent = {
        normal = false,
        menu = false,
        popup = false,
        telescope = true,
    },
    styles = {
        comments = { italic = false },
        diagnostics = { undercurl = false },
    },
    ui = { hide_end_of_buffer = false },
})
truthy(ok, "style and transparency override succeeds: " .. tostring(err))
equal(hl("Normal").bg, hex("#101010"), "normal transparency is independent from palette")
equal(hl("Pmenu").bg, hex("#191919"), "menu transparency is independent from palette")
equal(hl("NormalFloat").bg, hex("#1a1a1a"), "popup transparency is independent from palette")
equal(hl("TelescopeNormal").bg, nil, "Telescope transparency is independent from palette")
equal(hl("Comment").italic, nil, "comment style can be disabled")
equal(hl("DiagnosticUnderlineWarn").underline, true, "diagnostic underline replaces disabled undercurl")

ok, err = theme.apply(palette_a)
truthy(ok, "palette A is restored before rollback test: " .. tostring(err))
local before_failure = all_highlights()
local before_failure_event_count = event_count
local before_failure_palette = theme.active_palette()
local original_set_hl = vim.api.nvim_set_hl
local set_hl_calls = 0
vim.api.nvim_set_hl = function(...)
    set_hl_calls = set_hl_calls + 1
    if set_hl_calls == 2 then
        error("intentional apply failure")
    end
    return original_set_hl(...)
end
local failure_ok = theme.apply(palette_b)
vim.api.nvim_set_hl = original_set_hl
equal(failure_ok, nil, "highlight application failure is reported")
equal(all_highlights(), before_failure, "highlight application failure rolls back highlights")
equal(theme.active_palette(), before_failure_palette, "highlight application failure preserves active palette")
equal(event_count, before_failure_event_count, "highlight application failure emits no event")

local caller_palette = theme.default_palette()
ok, err = theme.apply(caller_palette)
truthy(ok, "caller palette applies: " .. tostring(err))
caller_palette.editor.keyword = "#000000"
equal(hl("@keyword").fg, hex("#789978"), "active palette is isolated from caller mutation")

if #failures > 0 then
    for _, message in ipairs(failures) do
        vim.api.nvim_err_writeln(message)
    end
    vim.api.nvim_err_writeln(("%d of %d assertions failed"):format(#failures, assertions))
    vim.cmd.cquit({ args = { 1 }, bang = true })
end

print(("theme.nvim: %d assertions passed"):format(assertions))
vim.cmd.quitall({ bang = true })

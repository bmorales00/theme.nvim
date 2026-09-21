local options = require("theme.options")
local renderer = require("theme.renderer")
local schema = require("theme.schema")

local M = {
    name = "lackluster",
}

local state = {
    config = vim.deepcopy(options.defaults),
    owned = {},
    active_palette = nil,
    active_options = nil,
    base_fillchars = vim.o.fillchars,
}

local function builtin_palette()
    return vim.deepcopy(require("theme.palettes.lackluster"))
end

local function capture(compiled)
    local names = {}
    for name in pairs(state.owned) do
        names[name] = true
    end
    for name in pairs(compiled.names) do
        names[name] = true
    end

    local highlights = {}
    for name in pairs(names) do
        highlights[name] = vim.api.nvim_get_hl(0, {
            name = name,
            link = true,
            create = false,
        })
    end

    local terminal = {}
    for index = 0, 15 do
        terminal[index] = vim.g["terminal_color_" .. index]
    end

    return {
        highlights = highlights,
        terminal = terminal,
        colors_name = vim.g.colors_name,
        termguicolors = vim.o.termguicolors,
        fillchars = vim.o.fillchars,
    }
end

local function restore(snapshot)
    for name, value in pairs(snapshot.highlights) do
        vim.api.nvim_set_hl(0, name, value)
    end
    for index = 0, 15 do
        vim.g["terminal_color_" .. index] = snapshot.terminal[index]
    end
    vim.g.colors_name = snapshot.colors_name
    vim.o.termguicolors = snapshot.termguicolors
    vim.o.fillchars = snapshot.fillchars
end

local function commit(compiled, config)
    for name in pairs(state.owned) do
        if not compiled.names[name] then
            vim.api.nvim_set_hl(0, name, {})
        end
    end

    for _, highlight in ipairs(compiled.highlights) do
        vim.api.nvim_set_hl(0, highlight.name, highlight.value)
    end

    for index = 0, 15 do
        vim.g["terminal_color_" .. index] = compiled.terminal[index]
    end

    vim.o.termguicolors = true
    if config.ui.hide_end_of_buffer then
        vim.opt.fillchars:append({ eob = " " })
    else
        vim.o.fillchars = state.base_fillchars
    end
    vim.g.colors_name = M.name
end

local function apply(palette, override_options, emit_event)
    local normalized, validation_error = schema.validate(palette)
    if not normalized then
        return nil, validation_error
    end

    local config, option_error = options.normalize(override_options, state.config)
    if not config then
        return nil, option_error
    end

    local compiled_ok, compiled, render_error = pcall(renderer.compile, normalized, config)
    if not compiled_ok then
        return nil, compiled
    end
    if not compiled then
        return nil, render_error
    end

    local snapshot_ok, snapshot = pcall(capture, compiled)
    if not snapshot_ok then
        return nil, snapshot
    end

    local commit_ok, commit_error = xpcall(function()
        commit(compiled, config)
    end, debug.traceback)

    if not commit_ok then
        local rollback_ok, rollback_error = pcall(restore, snapshot)
        if not rollback_ok then
            return nil, ("%s\nrollback failed: %s"):format(commit_error, rollback_error)
        end
        return nil, commit_error
    end

    state.owned = vim.deepcopy(compiled.names)
    state.active_palette = normalized
    state.active_options = config

    if emit_event then
        local event_ok, event_error = pcall(vim.api.nvim_exec_autocmds, "ColorScheme", {
            pattern = M.name,
            modeline = false,
        })
        if not event_ok then
            vim.schedule(function()
                vim.notify("theme.nvim ColorScheme callback failed: " .. event_error, vim.log.levels.ERROR)
            end)
        end
    end
    return true
end

function M.setup(config)
    local normalized, err = options.normalize(config, options.defaults)
    if not normalized then
        return nil, err
    end
    state.config = normalized
    return true
end

function M.apply(palette, override_options)
    return apply(palette or builtin_palette(), override_options, true)
end

function M.reload(palette, override_options)
    local selected = palette or state.active_palette or builtin_palette()
    return apply(selected, override_options, true)
end

function M.validate_palette(palette)
    local normalized, err = schema.validate(palette)
    if not normalized then
        return nil, err
    end
    return true
end

function M.default_palette()
    return builtin_palette()
end

function M.active_palette()
    if not state.active_palette then
        return nil
    end
    return vim.deepcopy(state.active_palette)
end

function M.lualine()
    local palette = state.active_palette or select(1, schema.validate(builtin_palette()))
    local ui = palette.ui
    return {
        normal = {
            a = { bg = ui.surface_container_high, fg = ui.on_surface, gui = "bold" },
            b = { bg = ui.surface_container_high, fg = ui.on_surface },
            c = { bg = ui.surface_container_high, fg = ui.on_surface },
        },
        insert = {
            a = { bg = ui.primary, fg = ui.inverse_surface, gui = "bold" },
            b = { bg = ui.surface_container_high, fg = ui.on_surface },
            c = { bg = ui.surface_container_high, fg = ui.on_surface },
        },
        command = {
            a = { bg = ui.primary, fg = ui.inverse_surface, gui = "bold" },
            b = { bg = ui.surface_container_high, fg = ui.on_surface },
            c = { bg = ui.surface_container_high, fg = ui.on_surface },
        },
        visual = {
            a = { bg = ui.inverse_surface, fg = ui.inverse_on_surface, gui = "bold" },
            b = { bg = ui.surface_container_high, fg = ui.on_surface },
            c = { bg = ui.surface_container_high, fg = ui.on_surface },
        },
        replace = {
            a = { bg = ui.inverse_surface, fg = ui.inverse_on_surface, gui = "bold" },
            b = { bg = ui.surface_container_high, fg = ui.on_surface },
            c = { bg = ui.surface_container_high, fg = ui.on_surface },
        },
        inactive = {
            a = { bg = ui.surface, fg = ui.outline, gui = "bold" },
            b = { bg = ui.surface, fg = ui.outline },
            c = { bg = ui.surface, fg = ui.outline },
        },
    }
end

function M._load_colorscheme()
    return apply(builtin_palette(), nil, false)
end

return M

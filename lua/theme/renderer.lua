local build = require("theme.build")
local highlight = require("theme.highlights")

local M = {}

local terminal_names = {
    "black",
    "red",
    "green",
    "yellow",
    "blue",
    "magenta",
    "cyan",
    "white",
}

local highlight_keys = {
    bg = true,
    blend = true,
    bold = true,
    cterm = true,
    ctermbg = true,
    ctermfg = true,
    default = true,
    fg = true,
    force = true,
    italic = true,
    link = true,
    nocombine = true,
    reverse = true,
    sp = true,
    standout = true,
    strikethrough = true,
    undercurl = true,
    underdashed = true,
    underdotted = true,
    underdouble = true,
    underline = true,
}

local function valid_color(value)
    return value == "none" or (type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil)
end

local function validate_highlight(name, spec)
    for key, value in pairs(spec) do
        if not highlight_keys[key] then
            return nil, ("highlight %s has unsupported field %s"):format(name, tostring(key))
        end
        if (key == "fg" or key == "bg" or key == "sp") and not valid_color(value) then
            return nil, ("highlight %s has invalid %s color"):format(name, key)
        end
    end

    if spec.link ~= nil and type(spec.link) ~= "string" then
        return nil, ("highlight %s has a non-string link"):format(name)
    end
    return true
end

function M.compile(palette, options)
    local theme, color = build.from_palette(palette, options)
    local sections = highlight(theme, color)
    local specs = {}
    local names = {}

    for _, section in ipairs(sections) do
        for _, source in ipairs(section.highlight) do
            local name = source.name
            if type(name) ~= "string" or name == "" then
                return nil, "renderer produced a highlight without a name"
            end
            if names[name] then
                return nil, "renderer produced duplicate highlight " .. name
            end

            local spec = {}
            for key, value in pairs(source) do
                if key ~= "name" then
                    spec[key] = value
                end
            end

            local ok, err = validate_highlight(name, spec)
            if not ok then
                return nil, err
            end
            names[name] = true
            table.insert(specs, { name = name, value = spec })
        end
    end

    local terminal = {}
    for index, name in ipairs(terminal_names) do
        terminal[index - 1] = palette.terminal.normal[name]
        terminal[index + 7] = palette.terminal.bright[name]
    end

    return {
        highlights = specs,
        names = names,
        terminal = terminal,
    }
end

return M

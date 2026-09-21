local spec = require("theme.spec")
---@param theme ThemeDefinition
---@return ThemeHighlightGroup
return function(theme, color)
    return {
        plugin_name = "indentmini",
        highlight = {
            -- https://github.com/nvimdev/indentmini.nvim
            spec.fg("IndentLine", color.gray3),
            spec.fg("IndentLineCurrent", color.gray5),
        },
    }
end

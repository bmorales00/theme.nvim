local spec = require("theme.spec")

---@param theme ThemeDefinition
---@return ThemeHighlightGroup
return function(theme)
    return {
        plugin_name = "lightbulb",
        highlight = {
            spec.fg("lightbulbSign", theme.diagnostic.text),
        },
    }
end

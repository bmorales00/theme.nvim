local spec = require("theme.spec")

---@param theme ThemeDefinition
---@return ThemeHighlightGroup
return function(theme)
    return {
        plugin_name = "yanky",
        highlight = {
            spec.ln("YankyPut", "Visual"),
            spec.ln("YankyYanked", "Visual"),
        },
    }
end

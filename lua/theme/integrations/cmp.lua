local spec = require("theme.spec")

---@param theme ThemeDefinition
---@return ThemeHighlightGroup
return function(theme)
    local cmp = theme.plugin_cmp
    return {
        plugin_name = "cmp",
        highlight = {
            spec.fg("CmpItemKind", cmp.kind),
            spec.fg("CmpItemKindSnippet", cmp.snippet),
            spec.fg("CmpItemAbbrDeprecated", cmp.deprecated),
        },
    }
end

local spec = require("theme.spec")

---@param theme ThemeDefinition
---@return ThemeHighlightGroup
return function(theme)
    return {
        plugin_name = "headlines",
        highlight = {
            spec.co("Headline", theme.plugin_headline.fg_headline, theme.plugin_headline.bg_headline),
            spec.fg("Dash", theme.plugin_headline.fg_dash),
            spec.bg("CodeBlock", theme.plugin_headline.bg_code_block),
        },
    }
end

local spec = require("theme.spec")

---@param theme ThemeDefinition
---@return ThemeHighlightGroup
return function(theme)
    return {
        plugin_name = "lsp_config",
        highlight = {
            spec.fg("lspInfoTip", theme.diagnostic.info),
        },
    }
end

local create_theme = require("theme.foundation")

local M = {}

local function compatibility_colors(palette)
    local ui = palette.ui
    return {
        lack = ui.primary,
        luster = ui.secondary,
        orange = ui.warning,
        yellow = palette.terminal.normal.yellow,
        green = ui.success,
        blue = ui.tertiary,
        red = ui.error,
        none = "none",
        black = ui.inverse_on_surface,
        gray1 = ui.surface,
        gray2 = ui.surface_variant,
        gray3 = ui.surface_container_highest,
        gray4 = ui.outline,
        gray5 = ui.muted,
        gray6 = ui.on_surface_variant,
        gray7 = ui.on_surface,
        gray8 = ui.foreground,
        gray9 = ui.inverse_surface,
    }
end

local function compatibility_special(palette)
    local ui = palette.ui
    local editor = palette.editor
    return {
        main_background = ui.background,
        menu_background = ui.surface_variant,
        popup_background = ui.surface_container,
        statusline = ui.surface_container_high,
        comment = editor.comment,
        exception = editor.keyword_exception,
        keyword = editor.keyword,
        param = editor.parameter,
        whitespace = editor.whitespace,
    }
end

function M.from_palette(palette, options)
    local color = compatibility_colors(palette)
    local theme = create_theme(color, compatibility_special(palette))
    local ui = palette.ui
    local editor = palette.editor

    theme.syntax = {
        tag = editor.tag,
        var = editor.variable,
        var_member = editor.member,
        const = editor.constant,
        const_builtin = editor.builtin_constant,
        func_def = editor.function_definition,
        func_call = editor.function_call,
        func_param = editor.parameter,
        special = editor.special,
        type = editor.type,
        type_def = editor.type_definition,
        type_primitive = editor.primitive_type,
        builtin = editor.builtin,
        keyword = editor.keyword,
        keyword_return = editor.keyword_return,
        keyword_exception = editor.keyword_exception,
        string = editor.string,
        string_escape = editor.string_escape,
        punctuation = editor.punctuation,
        comment = editor.comment,
    }

    theme.ui.fg_whitespace = editor.whitespace
    theme.ui.fg_nontext = editor.nontext
    theme.ui.fg_line_num = editor.line_number
    theme.ui.fg_line_num_cur = editor.line_number_active
    theme.ui.bg_visual = ui.selection
    theme.ui.fg_visual = ui.on_selection
    theme.ui.fg_search = ui.on_primary
    theme.ui.use_undercurl = options.styles.diagnostics.undercurl

    theme.diff = {
        add = palette.diff.add,
        change = palette.diff.change,
        delete = palette.diff.delete,
        info = palette.diff.context,
    }
    theme.diagnostic = {
        text = editor.diagnostic_text,
        ok = ui.success,
        hint = ui.info,
        error = ui.error,
        info = ui.info,
        warn = ui.warning,
        unnecessary = editor.diagnostic_text,
        deprecated = ui.warning,
    }

    theme.log = {
        success = ui.success,
        info = ui.secondary,
        warn = ui.warning,
        error = ui.error,
        debug = ui.tertiary,
        hint = ui.info,
    }
    theme.plugin_rainbow = {
        red = palette.rainbow.level_1,
        yellow = palette.rainbow.level_2,
        blue = palette.rainbow.level_3,
        orange = palette.rainbow.level_4,
        green = palette.rainbow.level_5,
        violet = palette.rainbow.level_6,
        cyan = palette.rainbow.level_7,
    }

    if options.transparent.normal then
        theme.ui.bg_normal = "none"
    end
    if options.transparent.menu then
        theme.ui.bg_menu = "none"
    end
    if options.transparent.popup then
        theme.ui.bg_popup = "none"
    end
    if options.transparent.telescope then
        theme.plugin_telescope.bg_normal = "none"
    end

    theme.styles = vim.deepcopy(options.styles)
    return theme, color
end

return M

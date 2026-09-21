local M = {}

local COLOR = "color"
local VERSION = "version"

local shape = {
    schema_version = VERSION,
    ui = {
        primary = COLOR,
        on_primary = COLOR,
        secondary = COLOR,
        tertiary = COLOR,
        background = COLOR,
        foreground = COLOR,
        surface = COLOR,
        surface_variant = COLOR,
        surface_container = COLOR,
        surface_container_high = COLOR,
        surface_container_highest = COLOR,
        on_surface = COLOR,
        on_surface_variant = COLOR,
        muted = COLOR,
        outline = COLOR,
        inverse_surface = COLOR,
        inverse_on_surface = COLOR,
        selection = COLOR,
        on_selection = COLOR,
        error = COLOR,
        warning = COLOR,
        success = COLOR,
        info = COLOR,
    },
    editor = {
        comment = COLOR,
        whitespace = COLOR,
        nontext = COLOR,
        line_number = COLOR,
        line_number_active = COLOR,
        parameter = COLOR,
        keyword = COLOR,
        keyword_return = COLOR,
        keyword_exception = COLOR,
        string = COLOR,
        string_escape = COLOR,
        function_definition = COLOR,
        function_call = COLOR,
        variable = COLOR,
        member = COLOR,
        constant = COLOR,
        builtin_constant = COLOR,
        builtin = COLOR,
        type = COLOR,
        type_definition = COLOR,
        primitive_type = COLOR,
        punctuation = COLOR,
        tag = COLOR,
        special = COLOR,
        diagnostic_text = COLOR,
    },
    diff = {
        add = COLOR,
        change = COLOR,
        delete = COLOR,
        context = COLOR,
    },
    rainbow = {
        level_1 = COLOR,
        level_2 = COLOR,
        level_3 = COLOR,
        level_4 = COLOR,
        level_5 = COLOR,
        level_6 = COLOR,
        level_7 = COLOR,
    },
    terminal = {
        normal = {
            black = COLOR,
            red = COLOR,
            green = COLOR,
            yellow = COLOR,
            blue = COLOR,
            magenta = COLOR,
            cyan = COLOR,
            white = COLOR,
        },
        bright = {
            black = COLOR,
            red = COLOR,
            green = COLOR,
            yellow = COLOR,
            blue = COLOR,
            magenta = COLOR,
            cyan = COLOR,
            white = COLOR,
        },
    },
}

local function sorted_keys(value)
    local keys = {}
    for key in pairs(value) do
        table.insert(keys, key)
    end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)
    return keys
end

local function validate_node(value, expected, path, errors)
    if expected == COLOR then
        if type(value) ~= "string" or not value:match("^#%x%x%x%x%x%x$") then
            table.insert(errors, path .. " must be a color in #RRGGBB form")
            return nil
        end
        return value:lower()
    end

    if expected == VERSION then
        if value ~= 1 then
            table.insert(errors, path .. " must equal 1")
            return nil
        end
        return value
    end

    if type(value) ~= "table" then
        table.insert(errors, path .. " must be a table")
        return nil
    end

    local result = {}
    for _, key in ipairs(sorted_keys(expected)) do
        local child_path = path == "" and key or (path .. "." .. key)
        if value[key] == nil then
            table.insert(errors, child_path .. " is required")
        else
            result[key] = validate_node(value[key], expected[key], child_path, errors)
        end
    end

    for _, key in ipairs(sorted_keys(value)) do
        if expected[key] == nil then
            local child_path = path == "" and tostring(key) or (path .. "." .. tostring(key))
            table.insert(errors, child_path .. " is not a supported role")
        end
    end

    return result
end

function M.validate(palette)
    if type(palette) ~= "table" then
        return nil, "palette must be a table"
    end

    local errors = {}
    local normalized = validate_node(palette, shape, "", errors)
    if #errors > 0 then
        return nil, table.concat(errors, "\n")
    end
    return normalized
end

return M

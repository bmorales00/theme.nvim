local M = {}

M.defaults = {
    transparent = {
        normal = true,
        menu = true,
        popup = true,
        telescope = false,
    },
    styles = {
        comments = {
            italic = true,
        },
        diagnostics = {
            undercurl = true,
        },
    },
    ui = {
        hide_end_of_buffer = true,
    },
}

local function merge(input, defaults, path, errors)
    if input ~= nil and type(input) ~= "table" then
        table.insert(errors, path .. " must be a table")
        return vim.deepcopy(defaults)
    end

    input = input or {}
    local result = {}
    for key, default in pairs(defaults) do
        local child_path = path == "" and key or (path .. "." .. key)
        local value = input[key]
        if type(default) == "table" then
            result[key] = merge(value, default, child_path, errors)
        elseif value == nil then
            result[key] = default
        elseif type(value) ~= "boolean" then
            table.insert(errors, child_path .. " must be a boolean")
            result[key] = default
        else
            result[key] = value
        end
    end

    for key in pairs(input) do
        if defaults[key] == nil then
            local child_path = path == "" and tostring(key) or (path .. "." .. tostring(key))
            table.insert(errors, child_path .. " is not a supported option")
        end
    end
    return result
end

function M.normalize(input, base)
    local errors = {}
    local normalized_base = vim.deepcopy(base or M.defaults)
    local result = merge(input, normalized_base, "", errors)
    if #errors > 0 then
        return nil, table.concat(errors, "\n")
    end
    return result
end

return M

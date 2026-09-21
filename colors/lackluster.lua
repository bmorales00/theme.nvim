local ok, err = require("theme")._load_colorscheme()

if not ok then
    error(err)
end

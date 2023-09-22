---@type yue.gui
local gui = require("yue.gui")

local export = {}

export.fonts = {
    header = gui.Font.default():derive(24, "bold", "normal"),
    subheader = gui.Font.default():derive(16, "normal", "normal"),
}

return export

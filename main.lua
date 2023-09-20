package.cpath = "lua_modules/lib/lua/5.1/?.so;"..package.cpath

---@type yue.gui
local gui = require("yue.gui")
local timer = require("timer")
local uv = require("uv")

---@type { enqueue: fun(callback: (fun(): boolean), interval: number?), clock: fun(): number }
local utilities = require("utilities")

local window = gui.Window.create {
    frame = true;
    transparent = false;
    showtrafficlights = true;
}

function window:onclose()
    uv.stop()
    gui.MessageLoop.quit()
end

local container = gui.Container.create()
container:setstyle {
    padding = 25,
}

local lbl = gui.Label.create("Hello, World!")
local header = gui.Font.default():derive(24, "bold", "normal")
lbl:setfont(header)

container:addchildview(lbl)

window:setcontentview(container)
window:setcontentsize(container:getpreferredsize())
window:activate()

--runs when the event loop is ready
timer.setTimeout(0, function ()
    uv.stop()

    utilities.enqueue(function ()
        uv.run("nowait")
        return true
    end)

    gui.MessageLoop.run()
end)


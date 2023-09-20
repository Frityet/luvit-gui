package.cpath = "lua_modules/lib/lua/5.1/?.so;"..package.cpath

---@type yue.gui
local gui = require("yue.gui")
local https = require("https")
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
    padding = 10,
    width = 480;
    height = 480;
}

local label = gui.Label.create "Received"
container:addchildview(label)

local progress = gui.ProgressBar.create()
container:addchildview(progress)

timer.setTimeout(3333, function (...)
    progress:setvalue(33)
end)

timer.setTimeout(6666, function (...)
    progress:setvalue(66)
end)

timer.setTimeout(10000, function (...)
    progress:setvalue(1000)
end)


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


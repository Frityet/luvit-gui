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
    padding = 25,
}

local input = gui.Entry.create()
container:addchildview(input)
gui.globalshortcut:register("CmdOrCtrl+V", function ()
    input:settext(gui.Clipboard.get():gettext())
end)

local out = ""
local out_picker = gui.Button.create "Choose file"
function out_picker:onclick()
    local dialog = gui.FileSaveDialog.create()
    dialog:settitle("Select out file")
    if dialog:runforwindow(window) then
        out = dialog:getresult()
        out_picker:settitle(out)
        window:setcontentsize(container:getpreferredsize())
    end
end
container:addchildview(out_picker)

local progress = gui.ProgressBar.create()
container:addchildview(progress)

local bytes_dled = gui.Label.create "Downloaded "
container:addchildview(bytes_dled)
bytes_dled:setvisible(false)

local get = gui.Button.create "GET"
function get:onclick()
    progress:setvalue(0)
    bytes_dled:setvisible(true)
    local downloaded = 0
    local f = assert(io.open(out, "w+b"))
    https.get(input:gettext(), function (res)
        local size = tonumber(res.headers["Content-Length"])
        res:on("data", function (chunk)
            downloaded = downloaded + #chunk

            if size ~= nil and size ~= 0 then
                progress:setvalue(downloaded/size * 100)
            end

            bytes_dled:settext("Downloaded "..downloaded.."/"..(size or 1).." bytes!")
            f:write(chunk)
        end)

        res:on("close", function ()
            f:close()
        end)
    end)
end
container:addchildview(get)

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


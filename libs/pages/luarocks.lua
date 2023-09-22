---@type yue.gui
local gui = require("yue.gui")
local Luarocks = require("Package/Luarocks")
local Version = require("Package/Version")
local common = require("pages/common")

local pkg = Luarocks:create()

local function ui()
    local container = gui.Container.create()

    ---@type Package.Version?
    local selected_luarocks_version = nil

    local lua_header = gui.Label.create("Select Luarocks version")
    -- lua_header:setfont(common.fonts.subheader)
    container:addchildview(lua_header)

    local fetching_text = gui.Label.create("Fetching versions...")
    container:addchildview(fetching_text)

    local fetching_prgb = gui.ProgressBar.create()
    container:addchildview(fetching_prgb)

    local picker = gui.Picker.create()
    picker:setstyle {
        height = 25,
        ["margin-top"] = 10,
    }

    pkg:fetch_versions (nil,
        function(version, checked, total)
            local percent = checked / total * 100
            fetching_text:settext(string.format("Fetching versions... %d/%d (%.2f%%)", checked, total, percent))
            fetching_prgb:setvalue(percent)
            --hide the progress bar when we're at 100
            if percent >= 100 then
                fetching_text:setvisible(false)
                fetching_prgb:setvisible(false)
            end

            picker:additem(tostring(version))

            ---@type string[]
            local sel = picker:getitems()

            ---@type Package.Version[]
            local vers = {}

            for i, v in ipairs(sel) do
                if v == "None" then goto next end
                vers[i] = Version:from_string(v, pkg.url_format)
                ::next::
            end

            --Sort, newest first (greatest major), then greatest minor, then greatest build
            table.sort(vers, function(a, b)
                if a.major ~= b.major then
                    return a.major > b.major
                elseif a.minor ~= b.minor then
                    return a.minor > b.minor
                else
                    return a.build > b.build
                end
            end)

            picker:clear()

            for i, v in ipairs(vers) do
                picker:additem(tostring(v))
            end

            picker:additem("None")
        end
    )

    function picker:onselectionchange()
        local sel = picker:getselecteditem()
        if sel == "None" then selected_luarocks_version = nil; return; end
        selected_luarocks_version = Version:from_string(sel, pkg.url_format)
        print("Selected Luarocks version: " .. tostring(selected_luarocks_version))
    end

    container:addchildview(picker)

    return container
end

---@param progress nu.ProgressBar
local function on_download(progress)

end

---@param to string
local function on_install(to)

end

---@type Page
return {
    name = "Luarocks",
    ui = ui,
    on_download = on_download,
    on_install = on_install,
}

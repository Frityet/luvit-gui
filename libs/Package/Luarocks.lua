local Package = require("Package")

---@class Luarocks : Package
local Luarocks = {
    url_format = "https://luarocks.github.io/luarocks/releases/luarocks-%d.%d.%d-win32.zip"
}
Luarocks.__index = Luarocks
Luarocks.__name = "Luarocks"
setmetatable(Luarocks, Package)

---@return Luarocks
function Luarocks:create()
    return Package.create(self) --[[@as Luarocks]]
end

---@param on_request fun(url: url_parsed, checked: integer, total: integer)?
---@param on_get fun(ver: Package.Version?, checked: integer, total: integer)?
function Luarocks:fetch_versions(on_request, on_get)
    return Package.fetch_versions(self, { 2, 0, 0 }, { 3, 10, 10 }, on_request, on_get)
end

return Luarocks

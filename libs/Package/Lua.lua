local Package = require("Package")
local https = require("https")
local fs = require("fs")

---@class Package.Lua : Package
local Lua = {
    url_format = "https://www.lua.org/ftp/lua-%d.%d.%d.tar.gz"
}
Lua.__index = Lua
Lua.__name = "Lua"
setmetatable(Lua, Package)

---@return Package.Lua
function Lua:create()
    return Package.create(self) --[[@as Package.Lua]]
end

---@param on_request fun(url: url_parsed, checked: integer, total: integer)?
---@param on_get fun(ver: Package.Version?, checked: integer, total: integer)?
function Lua:fetch_versions(on_request, on_get)
    return Package.fetch_versions(self, { 5, 1, 0 }, { 5, 10, 10 }, on_request, on_get)
end

return Lua

local Package = require("Package")
local Version = require("Package/Version")

---@alias MinGW.Type
---| '"MinGW"'
---| '"LLVM"'
---| '"w64devkit"' NOT IMPLEMENTED

---@class MinGW : Package
local MinGW = {
    ---@type MinGW.Type
    type = "MinGW",
    ---@type MinGW.Type[]
    TYPES = { "MinGW", "LLVM", "w64devkit" }
}
MinGW.__index = MinGW
MinGW.__name = "MinGW"
setmetatable(MinGW, Package)

---@return MinGW
function MinGW:create()
    return setmetatable(Package.create(self), MinGW) --[[@as MinGW]]
end

---@param on_request fun(url: url_parsed, checked: integer, total: integer)?
---@param on_get fun(ver: Package.Version?, checked: integer, total: integer)?
function MinGW:fetch_versions(on_request, on_get)

end



return MinGW

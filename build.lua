#!/usr/bin/env lua

local function execute(...)
    local cmd = table.concat({...}, " ")
    print("$ "..cmd)
    local ok, err = os.execute(cmd)

    if not ok then error(err) end

    return ok
end


execute("luarocks", "--lua-version=5.1", "init")
execute("lit", "install")
execute("./luarocks", "make")

if arg[1] then
    print("Building standalone")
    execute("lit", "make", "./")
end

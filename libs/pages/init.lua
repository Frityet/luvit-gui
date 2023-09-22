---@class Page
---@field name string
---@field ui fun(): nu.Container
---@field on_download fun(progress_bar: nu.ProgressBar)
---@field on_install fun(to: string)

---@type Page[]
local pages = {
    require("pages/lua"),
    require("pages/luarocks"),
}

return pages

local Version = require("Package/Version")
---@type luvit.https
local https = require("https")
---@type luvit.fs
local fs = require("fs")
---@type luvit.url
local url_utils = require("url")

---@type luvit.prettyPrint
local pretty = require("pretty-print")


---@class Package
---@field install fun(to: string)
local Package = {
    name = "";
    ---@type Package.Version[]
    versions = {};
    url_format = "";
    file_path = ""
}
Package.__index = Package
Package.__name = "Package"

---@return Package
function Package:create()
    return setmetatable({
        name = self.__name,
        versions = {}
    }, self)
end

---@class VersionTuple
---@field [1] integer major
---@field [2] integer minor
---@field [3] integer build


---@param min VersionTuple
---@param max VersionTuple
---@param on_request fun(url: url_parsed, checked: integer, total: integer)?
---@param on_get fun(ver: Package.Version?, checked: integer, total: integer)?
function Package:fetch_versions(min, max, on_request, on_get)

    --Total = number of versions to check
    local checked, total = 0, 0

    for _ = min[1], max[1] do
        for _ = min[2], max[2] do
            for _ = min[3], max[3] do
                total = total + 1
            end
        end
    end

    for major = min[1], max[1] do
        for minor = min[2], max[2] do
            for build = min[3], max[3] do

                local url = url_utils.parse(self.url_format:format(major, minor, build))
                if on_request then on_request(url, checked, total) end
                local req = https.request({ method = "HEAD", host = url.host, path = url.path },
                function (req)
                    checked = checked + 1
                    if req.statusCode == 200 then
                        local ver = Version:create(major, minor, build)
                        if on_get then on_get(ver, checked, total) end
                        self.versions[#self.versions+1] = ver
                    end

                    req:setTimeout(10000, function ()
                        checked = checked + 1
                        if on_get then on_get(nil, checked, total) end
                        print("Timeout on "..url.href)
                        req:destroy()
                    end)
                end)

                req:on("error", function (err)
                    if type(err) == "string" then
                        error("An error has occured whilst checking URL "..url.href.."!\nError: "..err)
                    else
                        error("An error has occured whilst checking URL "..url.href.."! Error info: "..pretty.dump(err, true, true))
                    end
                end)

                req:flushHeaders()
                req:done()
            end
        end
    end
end

---@param to string
---@param version Package.Version
---@param report_progress fun(recved: integer, total_dled: integer, total_size: integer?)?
---@param on_finish fun(file: luvit.fs.WriteStream)?
---@return luvit.http.ClientRequest
function Package:download(to, version, report_progress, on_finish)
    local req = https.request(version:url(self.url_format), function (req)
        local total_size, total_dled = req.headers["Content-Length"] or req.headers["content-length"], 0
        req:on("error", error)
        local file_handle = fs.WriteStream:new(to)

        req:on("data", function (chunk)
            total_dled = total_dled + #chunk
            if report_progress then report_progress(#chunk, total_dled, total_size) end
            file_handle:write(chunk, function (err)
                if err then error(err) end
            end)
        end)

        req:on("close", function ()
            if on_finish then on_finish(file_handle) end
            file_handle:close()
        end)
    end)

    req:done()
    return req
end

return Package

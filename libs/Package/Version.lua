---@class Package.Version
local Version = {
    major = 0;
    minor = 0;
    build = 0;
}
Version.__index = Version
Version.__name = "Version"

---@param major integer
---@param minor integer
---@param build integer
---@return Package.Version
function Version:create(major, minor, build)
    return setmetatable({
        major = major,
        minor = minor,
        build = build,
    }, self)
end

---@param string string
---@param url_fmt string?
---@return Package.Version? ok, string? error
function Version:from_string(string, url_fmt)
    local major_str, minor_str, build_str = string:match(url_fmt or "(%d+)%.(%d+)%.(%d+)")
    local major, minor, build = tonumber(major_str), tonumber(minor_str), tonumber(build_str)
    if not major or not minor or not build then
        return nil, "Invalid version string"
    end

    return self:create(major, minor, build), nil
end

---@param fmt string
---@return string
function Version:url(fmt)
    return fmt:format(self.major, self.minor, self.build)
end

function Version:__tostring()
    return ("%d.%d.%d"):format(self.major, self.minor, self.build)
end

return Version

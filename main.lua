return require('luvit')(function (...)
    local ok, err = pcall(require, "./app")
    if not ok then error(err) end
end, ...)

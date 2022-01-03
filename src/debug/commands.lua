local Console = require 'debug/console'

--[[
    This file registers all commands to the console
]]
function reloadPath(path)
    package.loaded[path] = nil
    require(path)
    print(path .. " reloaded!")
end

Console.registerCommand('reload','hot-reloads a script file','reload <file>',function(args)
    if #args < 2 then
        return print("Please specify a file path to reload")
    end
    local path = args[2]
    if package.loaded[path] then
        reloadPath(path)
    else
        return print("That file does not exist")
    end
end)
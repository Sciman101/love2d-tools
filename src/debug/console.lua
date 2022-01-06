--[[
    Console system integrated into main.lua
    This is present throughout the entire game and can be accessed via a keybind (~ by default)

    print() and error() are both modified to also output to the game's console
]]

local Console = {
    height = love.graphics.getHeight() * 0.4,

    visible = false, -- Is the console visible?
    lines = {}, -- Lines of text output
    linesContext = {}, -- Used for formatting
    scrollAmount = 0, -- How far up are we scrolled in the lines of text

    history = {},

    currentInput = "", -- The command being currently edited
}

local consoleColors = {
    ERROR = {1,0.1,0}
}

local commands = {}
-- Register a new command to the console
--[[
    name: the thing you need to type
    desc: a description
    callback: a function to call (only parameter is args)
]]
function Console.registerCommand(name,desc,usage,callback)
    commands[name] = {
        name = name,
        desc = desc,
        usage = usage,
        callback = callback
    }
end

-- note that the console is NOT drawn according to the mainCanvas, and uses the actual resolution of the window
-- this is because tiny pixel text sucks imo
function Console.draw()
    if not Console.visible then return end

    love.graphics.setBlendMode("alpha")

    -- Draw box
    local w = love.graphics.getWidth()

    love.graphics.setColor(0,0,0,0.8)
    love.graphics.rectangle('fill',0,0,w,Console.height)

    -- Draw user input
    love.graphics.setColor(1,1,1)
    love.graphics.print("> " .. Console.currentInput,4,Console.height-20)

    -- Draw the remaining text
    love.graphics.setScissor(0,0,w,Console.height-20)
    local offset = 4
    for line=1,#Console.lines do
        -- set color based on context
        local context = Console.linesContext[line]
        love.graphics.setColor(consoleColors[context] or {1,1,1})
        love.graphics.print(Console.lines[line],4,offset-Console.scrollAmount)
        -- shift text down
        offset = offset + 20
    end

    -- clear clipping region
    love.graphics.setScissor()
end

-- Callback for love2d keypress
function Console.keypressed(key,code,isRepeat)
    if not Console.visible then return end

    -- Copy and paste
    if love.keyboard.isDown('lctrl') then
        if key == 'c' then
            love.system.setClipboardText(Console.currentInput)
            Console.print("Text copied to clipboard!","INFO")
        elseif key == 'v' then
            Console.currentInput = Console.currentInput .. love.system.getClipboardText()
        end
    end

    -- handle backspace and enter
    if #Console.currentInput > 0 then
        -- Delete
        if code == 'backspace' then
            Console.currentInput = string.sub(Console.currentInput,1,#Console.currentInput-1)
        -- Submit
        elseif code == 'return' then
            Console.execute()
        end
    end
end

-- Calback for love2d text input
function Console.textinput(text)
    -- toggle visibility
    -- this code goes here because if it went in Console.keypressed, it would type the letter after 
    if text == '`' then
        Console.visible = not Console.visible
        love.keyboard.setKeyRepeat(Console.visible)
        return
    end
    if not Console.visible then return end
    -- Append input
    Console.currentInput = Console.currentInput .. text
end

-- Put a message in the console
function Console.print(message,context)
    context = context or "DEBUG"
    Console.lines[#Console.lines+1] = message
    Console.linesContext[#Console.linesContext+1] = context

    -- errors are important!
    if context == "ERROR" then
        Console.visible = true
        love.keyboard.setKeyRepeat(true)
    end
end

function Console.scroll(amt)
    Console.scrollAmount = Console.scrollAmount - amt

    -- don't scroll if we have a small amount of messages
    local lineCount = #Console.lines
    if lineCount * 20 < Console.height then
        Console.scrollAmount = 0

    -- clamp
    elseif Console.scrollAmount < 0 then
        Console.scrollAmount = 0
    elseif Console.scrollAmount > lineCount * 20 - Console.height + 20 then
        Console.scrollAmount = lineCount * 20 - Console.height + 20
    end
end

-- Command handling
function Console.execute()
    local text = Console.currentInput

    -- clear current input and put in history
    Console.currentInput = ""
    Console.history[#Console.history+1] = text
    -- scroll to bottom
    local h = #Console.lines * 20
    if h > Console.height - 20 then
        Console.scrollAmount = h - Console.height + 40
    end

    -- This code is basically a long-winded 'split' function on our input string
    -- The difference being, it keeps arguments "in quotation marks" together as one string
    local args = {}
    local currentArg = ""
    local index = 1
    -- iterate over the characters in the text
    while index <= #text do
        
        -- get character
        local c = text:sub(index,index)

        -- we started a string, find the end
        if c == '"' then
            local argStart = index + 1
            local argEnd = argStart + 1
            while argEnd <= #text do
                if text:sub(argEnd,argEnd) == '"' then
                    break
                end
                -- move on
                argEnd = argEnd + 1
            end
            args[#args+1] = text:sub(argStart,argEnd-1)
            currentArg = ""

            -- skip ahead
            index = argEnd

        -- whitespace
        elseif c == " " or c == "\t" then
            -- add to argument list
            if #currentArg > 0 then
                args[#args+1] = currentArg
                currentArg = ""
            end
        -- any other character, append to argument
        else
            currentArg = currentArg .. c
        end

        -- iterate
        index = index + 1
        -- add last argument
        if index == #text+1 and #currentArg > 0 then
            args[#args+1] = currentArg
        end
    end

    -- find the command we want
    if #args > 0 then
        local cmd = commands[args[1]]
        -- try and execute
        if cmd then
            cmd.callback(args)
        else
            Console.print("Unknown command '" .. args[1] .. "'","ERROR")
        end
    end
end

-- edit normal print
do
    local oldPrint = print
    print = function(...)
        -- concatenate multiple args
        local result = ""
        local msg = {...}
        for i,v in ipairs(msg) do
            result = result .. tostring(v) .. "\t"
        end
        Console.print(result,"INFO")
        -- do normal print
        oldPrint(...)
    end
end

-- BASIC COMMANDS --
-- Register help command
Console.registerCommand('help','lists all commands','help [command]',function(args)
    if #args == 1 then
        -- show all commands
        print("Commands:")
        for k, v in pairs(commands) do
            print("\t" .. k .. " - " .. v.desc)
        end
    else
        -- show one command
        local cmd = commands[args[2]]
        print(cmd.name .. " - " .. cmd.desc .. "\n" .. cmd.usage)
    end
end)
Console.registerCommand('quit','quits the game','quit',function(args) love.event.quit(0) end)
Console.registerCommand('clear','clear the console','clear',function() Console.lines = {} Console.linesContext = {} end)

return Console
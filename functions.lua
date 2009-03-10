-------------------------------------------------------------------------------
-- @file functions.lua
-- @author Gigamo &lt;gigamo@gmail.com&gt;
-------------------------------------------------------------------------------

-- {{{1 Environment
local os = os
local io = io
local math = math
local string = string
local type = type
local tonumber = tonumber
local spacer = ' '
local awful = require('awful')
local beautiful = require('beautiful')
local naughty = require('naughty')

module('functions')

-- {{{1 Markup

function set_bg(bgcolor, text)
    if text then return '<span background="'..bgcolor..'">'..text..'</span>' end
end

function set_fg(fgcolor, text)
    if text then return '<span color="'..fgcolor..'">'..text..'</span>' end
end

function set_focus_fg(text)
    if text then return set_fg(beautiful.fg_focus, text) end
end

function set_font(font, text)
    if text then return '<span font_desc="'..font..'">'..text..'</span>' end
end

-- {{{1 Clock

function clock(cwidget, dateformat, timeformat)
    cwidget.text = spacer..os.date(dateformat)..spacer..set_fg(beautiful.fg_focus, os.date(timeformat))..spacer
end

-- {{{1 Battery

function battery(bwidget, adapter)
    local level = io.popen('hal-get-property --udi /org/freedesktop/Hal/devices/computer_power_supply_battery_'..adapter..' --key battery.charge_level.percentage')

    if level then
        charge = level:read()
        level:close()
    end

    bwidget.text = '['..charge..'%] '

    -- Naughtify me when battery gets really low
    if tonumber(charge) <= 10 then
        naughty.notify({ text = 'Battery low! '..charge..'% left!' })
    end
end

-- {{{1 Memory

function memory(mwidget, used_for)
    local memfile = io.open('/proc/meminfo')

    if memfile then
        for line in memfile:lines() do
            if line:match("^MemTotal.*") then
                mem_total = math.floor(tonumber(line:match("(%d+)")) / 1024)
            elseif line:match("^MemFree.*") then
                mem_free = math.floor(tonumber(line:match("(%d+)")) / 1024)
            elseif line:match("^Buffers.*") then
                mem_buffers = math.floor(tonumber(line:match("(%d+)")) / 1024)
            elseif line:match("^Cached.*") then
                mem_cached = math.floor(tonumber(line:match("(%d+)")) / 1024)
            end
        end
        memfile:close()
    end

    mem_free = mem_free + mem_buffers + mem_cached
    mem_in_use = mem_total - mem_free
    mem_usage_percentage = math.floor(mem_in_use / mem_total * 100)

    mwidget.text = spacer..mem_in_use..'Mb '..set_fg('#4C4C4C', '|')
end

-- {{{1 CPU

function cpu(cpwidget)
    local temperature = 0
    local howmany = 0
    local sensors = io.popen('sensors')

    if sensors then
        for line in sensors:lines() do
            if line:match(':%s+%+([.%d]+)') then
                howmany = howmany + 1
                temperature = temperature + tonumber(line:match(':%s+%+([.%d]+)'))
            end
        end
        sensors:close()
    end

    temperature = temperature / howmany

    cpwidget.text = spacer..temperature..'°C '..set_fg('#4C4C4C', '|')
end

-- {{{1 Load Average

function loadavg(lwidget)
    local palette =
    {
        "#888888",
        "#999988",
        "#AAAA88",
        "#BBBB88",
        "#CCCC88",
        "#CCBB88",
        "#CCAA88",
        "#DD9988",
        "#EE8888",
        "#FF4444",
    }
    local loadavg = io.open('/proc/loadavg')

    if loadavg then
        local txt = loadavg:read('*all')
        loadavg:close()
        if type(txt) == 'string' then
            local one, five, ten = txt:match("^([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)%s+")
            if type(one) == 'string' then
                loadtext = string.format('%.2f %.2f %.2f', one, five, ten)
            end
            local current_avg = tonumber(one)
            if type(current_avg) == 'number' then
                local index  = math.min(math.floor(current_avg * (#palette-1)) + 1, #palette)
                colors = palette[index]
            end
        end
    end

    lwidget.text = spacer..set_fg(colors, loadtext)..spacer..set_fg('#4C4C4C', '|')
end

-------------------------------------------------------------------------------
-- @file functions.lua
-- @author Gigamo &lt;gigamo@gmail.com&gt;
-------------------------------------------------------------------------------

local os = os
local io = io
local math = math
local tonumber = tonumber
local spacer = ' '
local awful = require('awful')
local beautiful = require('beautiful')
local naughty = require('naughty')

module('functions')

-- {{{1 Markup

function set_bg(bgcolor, text)
    if text ~= nil then
        return '<span background="'..bgcolor..'">'..text..'</span>'
    end
end

function set_fg(fgcolor, text)
    if text ~= nil then
        return '<span color="'..fgcolor..'">'..text..'</span>'
    end
end

function set_focus_fg(text)
    if text ~= nil then
        return set_fg(beautiful.fg_focus, text)
    end
end

function set_font(font, text)
    if text ~= nil then
        return '<span font_desc="'..font..'">'..text..'</span>'
    end
end

-- {{{1 Clock

function clock(dateformat, timeformat, cwidget)
    cwidget.text = spacer..os.date(dateformat)..spacer..set_fg(beautiful.fg_focus, os.date(timeformat))..spacer
end

-- {{{1 Battery

function battery(adapter, bwidget)
    local level = io.popen('hal-get-property --udi /org/freedesktop/Hal/devices/computer_power_supply_battery_'..adapter..' --key battery.charge_level.percentage')
    local discharging = io.popen('hal-get-property --udi /org/freedesktop/Hal/devices/computer_power_supply_battery_'..adapter..' --key battery.rechargeable.is_discharging')
    local charging = io.popen('hal-get-property --udi /org/freedesktop/Hal/devices/computer_power_supply_battery_'..adapter..' --key battery.rechargeable.is_charging')

    if level ~= nil then
        charge = level:read()
        level:close()
    else
        charge = '?'
    end

    if discharging ~= nil and charging ~= nil then
        discharging_state = discharging:read()
        discharging:close()
        charging_state = charging:read()
        charging:close()
        if discharging_state == 'true' then
            dir = 'v'
        elseif charging_state == 'true' then
            dir = '^'
        else
            dir = '↯'
        end
    else
        dir = '?'
    end

    bwidget.text = spacer..dir..charge..'%'..spacer..set_fg(beautiful.fg_focus, '|')

    -- Naughtify me when battery gets really low
    if tonumber(charge) <= 10 then
        naughty.notify({ text = 'Battery low!'..spacer..charge..'%'..spacer..'left!' })
    end
end

-- {{{1 Memory

function memory(mwidget, used_for)
    local f = io.open('/proc/meminfo')

    for line in f:lines() do
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
    f:close()

    mem_free = mem_free + mem_buffers + mem_cached
    mem_in_use = mem_total - mem_free
    mem_usage_percentage = math.floor(mem_in_use / mem_total * 100)

    mwidget.text = spacer..mem_in_use..'Mb'..spacer..set_fg(beautiful.fg_focus, '|')
end

-- {{{1 CPU

function cpu(cpwidget)
    local temperature = 0
    local howmany = 0
    local f = io.popen('sensors')
    
    for line in f:lines() do
        if line:match(':%s+%+([.%d]+)') then
            howmany = howmany + 1
            temperature = temperature + tonumber(line:match(':%s+%+([.%d]+)'))
        end
    end
    f:close()

    temperature = temperature / howmany

    cpwidget.text = spacer..temperature..'°C'..spacer..set_fg(beautiful.fg_focus, '|')
end

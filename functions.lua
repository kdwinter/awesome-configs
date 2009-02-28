-------------------------------------------------------------------------------
-- @file functions.lua
-- @author Gigamo &lt;gigamo@gmail.com&gt;
-------------------------------------------------------------------------------

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

function clock_info(dateformat, timeformat)
    return spacer..set_fg(beautiful.fg_focus, os.date(dateformat))..spacer..os.date(timeformat)..spacer
end

-- {{{1 Battery

function battery_info(adapter, used_for)
    local fcur = io.open('/sys/class/power_supply/'..adapter..'/charge_now')    
    local fcap = io.open('/sys/class/power_supply/'..adapter..'/charge_full')
    local fsta = io.open('/sys/class/power_supply/'..adapter..'/status')
    local cur = fcur:read()
    fcur:close()
    local cap = fcap:read()
    fcap:close()
    local sta = fsta:read()
    fsta:close()
    
    local battery = math.floor(cur * 100 / cap)

    if used_for == 'progressbar' then
        return tonumber(battery)
    elseif used_for == 'popup' then
        if sta:match('Unknown') then sta = 'A/C' end
        return 'Percent:'..spacer..battery.."%\n"..'State:'..spacer..sta
    elseif used_for == 'textbox' then
        if sta:match('Charging') then
            dir = '▲'
        elseif sta:match('Discharging') then
            dir = '▼'
        else
            dir = '↯'
        end

        return spacer..dir..battery..'%'..spacer
    end

    -- Naughtify me when battery gets really low
    if tonumber(battery) <= 10 then
        naughty.notify({ text       = 'Battery low!'..spacer..battery..'%'..spacer..'left!' })
    end
end

-- {{{1 Memory

function mem_info(used_for)
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

    if used_for == 'progressbar' then
        return tonumber(mem_usage_percentage)
    elseif used_for == 'popup' then
        return 'Percent:'..spacer..mem_usage_percentage..'%'.."\n"..'Total:'..spacer..mem_in_use..'Mb'
    elseif used_for == 'textbox' then
        if tonumber(mem_usage_percentage) >= 15 and tonumber(mem_in_use) >= 306 then
            mem_usage_percentage = set_fg('#FF6565', mem_usage_percentage)
            mem_in_use = set_fg('#FF6565', mem_in_use)
        end

        return spacer..mem_usage_percentage..'%'..spacer..'('..mem_in_use..'M)'..spacer
    end
end

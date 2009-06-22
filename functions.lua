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

module('functions')

-- {{{1 Markup

function set_bg(bgcolor, text)
    if text then return '<span background="'..bgcolor..'">'..text..'</span>' end
end

function set_fg(fgcolor, text)
    if text then return '<span color="'..fgcolor..'">'..text..'</span>' end
end

function set_font(font, text)
    if text then return '<span font_desc="'..font..'">'..text..'</span>' end
end

-- {{{1 Util

function escape(text)
    return awful.util.escape(text or 'nil')
end

-- Copy from awful.util
function pread(cmd)
    if cmd and cmd ~= '' then
        local f, err = io.popen(cmd, 'r')
        if f then
            local s = f:read('*all')
            f:close()
            return s
        else
            print(err)
        end
    end
end

-- Same as pread, but files instead of processes
function fread(file)
    if file and file ~= '' then
        local f, err = io.open(file, 'r')
        if f then
            local s = f:read('*all')
            f:close()
            return s
        else
            print(err)
        end
    end
end

-- {{{1 Clock

function clock(widget, format)
    local date = os.date(format)

    widget.text = set_bg('#000000', spacer..date..spacer)
end

-- {{{1 Battery

function battery(widget, adapter)
    local charge = pread('hal-get-property --udi /org/freedesktop/Hal/devices/computer_power_supply_battery_'..adapter..' --key battery.charge_level.percentage'):gsub("\n", '')

    widget.text = spacer..charge..'%'..set_fg('#4C4C4C', ' |')
end

-- {{{1 Memory

function memory(widget)
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
    end
    local mem_in_use = mem_total - (mem_free + mem_buffers + mem_cached)
    local mem_usage_percentage = math.floor(mem_in_use / mem_total * 100)

    widget.text = spacer..mem_in_use..'Mb'..set_fg('#4C4C4C', ' |')
end

-- {{{1 CPU

function cpu(widget)
    local temperature, howmany = 0, 0
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
    local freq = {}
    for i = 0, 1 do
        freq[i] = fread('/sys/devices/system/cpu/cpu'..i..'/cpufreq/scaling_cur_freq'):match('(.*)000')
    end

    widget.text = spacer..freq[0]..'/'..freq[1]..'MHz @ '..temperature..'C'..set_fg('#4C4C4C', ' |')
end

-- {{{1 Load Average

function loadavg(widget)
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
    local txt = fread('/proc/loadavg')
    local one, five, ten = txt:match('^([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)%s+')
    local loadtext = string.format('%.2f %.2f %.2f', one, five, ten)
    local current_avg = tonumber(one)
    local index = math.min(math.floor(current_avg * (#palette-1)) + 1, #palette)
    local color = palette[index]

    widget.text = spacer..set_fg(color, loadtext)..set_fg('#4C4C4C', ' |')
end

-- {{{1 Volume

function volume(widget, mixer)
    local vol = ''
    local txt = pread('amixer get '..mixer)
    if txt:match('%[off%]') then
        vol = 'Mute'
    else
        vol = txt:match('%[(%d+%%)%]')
    end

    widget.text = set_bg('#000000', '['..vol..'] ')
end

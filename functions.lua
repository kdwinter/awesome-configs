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

-- {{{1 Clock

function clock(cwidget, format)
    cwidget.text = spacer..os.date(format)..spacer
end

-- {{{1 Battery

function battery(bwidget, adapter)
    local hal = io.popen('hal-get-property --udi /org/freedesktop/Hal/devices/computer_power_supply_battery_'..adapter..' --key battery.charge_level.percentage')
    if hal then
        charge = hal:read()
        hal:close()
    end

    bwidget.text = spacer..charge..'% '..set_fg('#4C4C4C', '|')
end

-- {{{1 Memory

function memory(mwidget)
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

    mem_in_use = mem_total - (mem_free + mem_buffers + mem_cached)
    mem_usage_percentage = math.floor(mem_in_use / mem_total * 100)

    mwidget.text = spacer..mem_in_use..'Mb '..set_fg('#4C4C4C', '|')
end

-- {{{1 CPU

function cpu(cpwidget)
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

    local freq, gov = {}, {}
    for i = 0, 1 do
        local frequency = io.open('/sys/devices/system/cpu/cpu'..i..'/cpufreq/scaling_cur_freq')
        if frequency then
            freq[i] = frequency:read()
            frequency:close()
            local mhz = freq[i]:match('(.*)000')
            if mhz then
                freq[i] = mhz
            end
        end
        local governor = io.open('/sys/devices/system/cpu/cpu'..i..'/cpufreq/scaling_governor')
        if governor then
            gov[i] = governor:read()
            governor:close()
        end
    end

    cpwidget.text = spacer..freq[0]..'/'..freq[1]..'MHz ('..gov[0]..') @ '..temperature..'°C '..set_fg('#4C4C4C', '|')
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
        local txt = loadavg:read()
        loadavg:close()
        if type(txt) == 'string' then
            local one, five, ten = txt:match("^([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)%s+") -- so ugly :[
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

-- {{{1 Volume

function volume(vwidget, mixer)
    local volume = io.popen('amixer get '..mixer)
    if volume then
        local txt = volume:read('*a')
        volume:close()
        vol = txt:match("%[(%d+%%)%]")
        if txt:match("%[off%]") then
            vol = 'Mute'
        end
    end

    vwidget.text = '['..vol..'] '
end

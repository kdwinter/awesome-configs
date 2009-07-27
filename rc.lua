-------------------------------------------------------------------------------
-- @file awesomerc.lua
-- @author Gigamo &lt;gigamo@gmail.com&gt;
-------------------------------------------------------------------------------

-- {{{1 Tables

local tags      = { }
local statusbar = { }
local promptbox = { }
local taglist   = { }
local layoutbox = { }
local settings  = { }

-- {{{1 Imports

require('awful')
require('beautiful')
require('naughty')
require('functions')

-- Load theme
beautiful.init(awful.util.getdir('config')..'/themes/bluish.lua')

-- {{{1 Variables

settings.modkey  = 'Mod4'
settings.term    = 'urxvtc'
settings.browser = 'firefox-nightly'
settings.layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
settings.app_rules =
{  -- Class         Instance        Title               Screen      Tag     Floating
    { 'xterm',      nil,            nil,                1,          9,      false },
    { 'Firefox',    nil,            nil,                1,          2,      false },
    { 'Firefox',    'Download',     nil,                1,          nil,    true  },
    { 'Firefox',    'Places',       nil,                1,          nil,    true  },
    { 'MPlayer',    nil,            nil,                1,          5,      true  },
    { 'Pidgin',     nil,            nil,                1,          4,      false },
    { nil,          nil,            'VLC media player', 1,          5,      true  },
}
settings.tag_properties =
{
    { name = '01-main  ', layout = settings.layouts[1], mwfact = 0.550 },
    { name = '02-web  ',  layout = settings.layouts[3] },
    { name = '03-dev  ',  layout = settings.layouts[1] },
    { name = '04-chat  ', layout = settings.layouts[1] },
    { name = '05-misc  ', layout = settings.layouts[5], mwfact = 0.225 },
    --{ name = '6', layout = settings.layouts[1] },
    --{ name = '7', layout = settings.layouts[1] },
    --{ name = '8', layout = settings.layouts[1] },
    --{ name = '9', layout = settings.layouts[1] }
}

-- {{{1 Tags

for s = 1, screen.count() do
    tags[s] = { }
    for i, v in ipairs(settings.tag_properties) do
        tags[s][i] = tag(v.name)
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], 'layout', v.layout)
        awful.tag.setproperty(tags[s][i], 'mwfact', v.mwfact)
        awful.tag.setproperty(tags[s][i], 'nmaster', v.nmaster)
        awful.tag.setproperty(tags[s][i], 'ncols', v.ncols)
        awful.tag.setproperty(tags[s][i], 'icon', v.icon)
    end
    tags[s][1].selected = true
end

-- {{{1 Widgets

systray  = widget({ type = 'systray', align = 'right' })
cpubox   = widget({ type = 'textbox', align = 'right' })
loadbox  = widget({ type = 'textbox', align = 'right' })
membox   = widget({ type = 'textbox', align = 'right' })
clockbox = widget({ type = 'textbox', align = 'right' })
batbox   = widget({ type = 'textbox', align = 'right' })
volbox   = widget({ type = 'textbox', align = 'right' })

taglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ }, 3, function (tag) tag.selected = not tag.selected end),
    awful.button({ settings.modkey }, 1, awful.client.movetotag),
    awful.button({ settings.modkey }, 3, awful.client.toggletag)
    )

for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt({ align = 'left' })
    layoutbox[s] = awful.widget.layoutbox(s, { align = 'left' })
    layoutbox[s]:buttons(awful.util.table.join(
                         awful.button({ }, 1, function () awful.layout.inc(settings.layouts, 1) end),
                         awful.button({ }, 3, function () awful.layout.inc(settings.layouts, -1) end)
    ))
    taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, taglist.buttons)
    statusbar[s] = awful.wibox(
    {
        position = 'top',
        height = '14',
        fg = beautiful.fg_normal,
        bg = beautiful.bg_normal,
        screen = s
    })
    statusbar[s].widgets =
    {
        {
            taglist[s],
            layoutbox[s],
            promptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        --taglist[s],
        --layoutbox[s],
        --promptbox[s],
        systray,
        volbox,
        clockbox,
        batbox,
        membox,
        loadbox,
        cpubox,
        layout = awful.widget.layout.horizontal.rightleft
    }
end

-- {{{1 Binds

root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

local globalkeys = awful.util.table.join(
    awful.key({ settings.modkey            }, 'Left',  awful.tag.viewprev),
    awful.key({ settings.modkey            }, 'Right', awful.tag.viewnext),
    awful.key({ settings.modkey            }, 'x',     function () awful.util.spawn(settings.term) end),
    awful.key({ settings.modkey            }, 'f',     function () awful.util.spawn(settings.browser) end),
    awful.key({ settings.modkey, 'Control' }, 'r',     awesome.restart),
    awful.key({ settings.modkey, 'Shift'   }, 'q',     awesome.quit),
    awful.key({ settings.modkey            }, 'j',     function ()
        awful.client.focus.byidx( 1)
        if client.focus then
            client.focus:raise()
        end
    end),
    awful.key({ settings.modkey            }, 'k',     function ()
        awful.client.focus.byidx(-1)
        if client.focus then
            client.focus:raise()
        end
    end),
    awful.key({ settings.modkey            }, 'Tab',   function ()
        local allclients = awful.client.visible(client.focus.screen)
        for i,v in ipairs(allclients) do
            if allclients[i+1] then
                allclients[i+1]:swap(v)
            end
        end
        awful.client.focus.byidx(-1)
    end),
    awful.key({ settings.modkey            }, 'l',     function () awful.tag.incmwfact(0.025) end),
    awful.key({ settings.modkey            }, 'h',     function () awful.tag.incmwfact(-0.025) end),
    awful.key({ settings.modkey, 'Shift'   }, 'h',     function () awful.client.incwfact(0.05) end),
    awful.key({ settings.modkey, 'Shift'   }, 'l',     function () awful.client.incwfact(-0.05) end),
    awful.key({ settings.modkey, 'Control' }, 'h',     function () awful.tag.incnmaster(1) end),
    awful.key({ settings.modkey, 'Control' }, 'l',     function () awful.tag.incnmaster(-1) end),
    awful.key({ settings.modkey            }, 'space', function () awful.layout.inc(settings.layouts, 1) end),
    awful.key({ settings.modkey, 'Shift'   }, 'space', function () awful.layout.inc(settings.layouts, -1) end),
    awful.key({ settings.modkey            }, 'r',     function () promptbox[mouse.screen]:run() end),
    awful.key({ }, '#121',  function () awful.util.spawn_with_shell('dvol -t') end),
    awful.key({ }, '#122',  function () awful.util.spawn_with_shell('dvol -d 2') end),
    awful.key({ }, '#123',  function () awful.util.spawn_with_shell('dvol -i 2') end)
)

local clientkeys = awful.util.table.join(
    awful.key({ settings.modkey            }, "c",     function (c) c:kill() end),
    awful.key({ settings.modkey, "Control" }, "space", awful.client.floating.toggle),
    awful.key({ settings.modkey, "Shift"   }, "r",     function (c) c:redraw() end),
    awful.key({ settings.modkey            }, "t",     awful.client.togglemarked),
    awful.key({ settings.modkey            }, "m",     function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
)

-- Using keynumbers instead of 1->9 because of my stupid azerty keyboard
local key_list = { '#10', '#11', '#12', '#13', '#14', '#15', '#16', '#17', '#18' }
local keynumber = table.getn(key_list)
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ settings.modkey }, key_list[i], function ()
            local screen = mouse.screen
            if tags[screen][i] then
                awful.tag.viewonly(tags[screen][i])
            end
        end),
        awful.key({ settings.modkey, 'Control' }, key_list[i], function ()
            local screen = mouse.screen
            if tags[screen][i] then
                tags[screen][i].selected = not tags[screen][i].selected
            end
        end),
        awful.key({ settings.modkey, 'Shift'   }, key_list[i], function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
            end
        end),
        awful.key({ settings.modkey, 'Control', 'Shift' }, key_list[i], function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.toggletag(tags[client.focus.screen][i])
            end
        end)
    )
end

root.keys(globalkeys)

-- {{{1 Hooks

-- Gets executed when focusing a client
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)

-- Gets executed when unfocusing a client
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Gets executed when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Gets executed when unmarking a client
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Gets executed when the mouse enters a client
awful.hooks.mouse_enter.register(function (c)
    if awful.client.focus.filter(c)
    and awful.layout.get(c.screen) ~= awful.layout.suit.magnifier then
        client.focus = c
    end
end)

-- Gets executed when a new client appears
awful.hooks.manage.register(function (c)
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    c:buttons(awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ settings.modkey }, 1, awful.mouse.client.move),
        awful.button({ settings.modkey }, 3, awful.mouse.client.resize)
    ))

    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Check application->screen/tag mappings and floating state
    local target_screen, target_tag, target_float
    for index, rule in pairs(settings.app_rules) do
        if  (((rule[1] == nil) or (c.class    and c.class    == rule[1]))
        and  ((rule[2] == nil) or (c.instance and c.instance == rule[2]))
        and  ((rule[3] == nil) or (c.name     and string.find(c.name, rule[3], 1, true)))) then
            target_screen = rule[4]
            target_tag    = rule[5]
            target_float  = rule[6]
        end
    end
    -- Apply mappings, if any
    if target_float  then
        awful.client.floating.set(c, target_float)
    end
    if target_screen then
        c.screen = target_screen
        awful.client.movetotag(tags[target_screen][target_tag], c)
    end

    client.focus = c

    c:keys(clientkeys)

    -- Prevent new clients from becoming master
    awful.client.setslave(c)

    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)

    -- Ignore size hints usually given out by terminals (prevent gaps between windows)
    c.size_hints_honor = false
end)

-- Gets executed when arranging the screen (as in, tag switch, new client, etc)
awful.hooks.tags.register(function (screen)
    if not client.focus or not client.focus:isvisible() then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)

-- Runonce
functions.cpu(cpubox)
functions.loadavg(loadbox)
functions.memory(membox)
functions.battery(batbox, 'BAT1')
functions.clock(clockbox, '%B %d %H:%M')
functions.volume(volbox, 'Master')

-- 10 seconds
awful.hooks.timer.register(10, function ()
    functions.cpu(cpubox)
    functions.loadavg(loadbox)
end)

-- 20 seconds
awful.hooks.timer.register(20, function ()
    functions.memory(membox)
    functions.battery(batbox, 'BAT1')
    functions.volume(volbox, 'Master')
end)

-- 1 minute
awful.hooks.timer.register(60, function ()
    functions.clock(clockbox, '%B %d %H:%M')
end)

io.stderr:write("\n\rAwesome loaded at "..os.date("%B %d, %H:%M").."\r\n\n")

-------------------------------------------------------------------------------
-- @file awesomerc.lua
-- @author Gigamo &lt;gigamo@gmail.com&gt;
-------------------------------------------------------------------------------

-- {{{1 Tables

local tags = { }
local statusbar = { }
local promptbox = { }
local taglist = { }
local tasklist = { }
local layoutbox = { }

-- {{{1 Imports

-- Standard awesome libraries
require('awful')
require('beautiful')
-- Notification library
require('naughty')
-- My own functions
require('functions')

-- {{{1 Variables

local modkey = 'Mod4'
local term = 'urxvtc'
local browser = 'firefox'
local music = "wine ~/.wine/drive_c/Program\\ Files/Spotify/spotify.exe"
local theme_path = awful.util.getdir('config')..'/themes/bluish'
beautiful.init(theme_path)


local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

local app_rules =
{  -- Class         Instance        Name                Screen          Tag     Floating
    { 'Firefox',    nil,            nil,                screen.count(), 2,      false },
    { 'Firefox',    'Download',     nil,                nil,            nil,    true  },
    { 'Firefox',    'Places',       nil,                nil,            nil,    true  },
    { 'Firefox',    'Extension',    nil,                nil,            nil,    true  },
    { 'MPlayer',    nil,            nil,                nil,            4,      true  },
    { nil,          nil,            'VLC media player', nil,            4,      true  },
    { nil,          'Spotify.exe',  'Spotify',          nil,            4,      true  }
}

-- {{{1 Tags

local tag_properties =
{
    { name = '1', layout = layouts[1], mwfact = 0.618033988769 },
    { name = '2', layout = layouts[3]                          },
    { name = '3', layout = layouts[1]                          },
    { name = '4', layout = layouts[1]                          },
    { name = '5', layout = layouts[1]                          },
    { name = '6', layout = layouts[1]                          },
    { name = '7', layout = layouts[1]                          },
    { name = '8', layout = layouts[1]                          },
    { name = '9', layout = layouts[1]                          }
}


for s = 1, screen.count() do
    tags[s] = { }
    for i, v in ipairs(tag_properties) do
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
local awesome_submenu =
{
    { 'restart', awesome.restart },
    { 'quit', awesome.quit }
}

local main_menu = awful.menu.new(
{
    items =
    {
        { 'Terminal', term            },
        { 'gVim',     gvim            },
        { 'Gimp',     gimp            },
        { 'Firefox',  browser         },
        { 'Spotify',  music           },
        { 'Awesome',  awesome_submenu }
    }
})

local systray = widget({ type = 'systray', align = 'right' })

spacer = ' '

clockbox = widget({ type = 'textbox', align = 'right' })

batprogressbar = widget({ type = 'progressbar', align = 'right' })
batprogressbar.width = 9
batprogressbar.height = 1
batprogressbar.gap = 1
batprogressbar.border_padding = 1
batprogressbar.border_width = 0
batprogressbar.ticks_count = 4
batprogressbar.vertical = true
batprogressbar:bar_properties_set('bat',
{
    bg = '#333333',
    fg = beautiful.fg_focus,
    border_color = '#888888',
    min_value = 0,
    max_value = 100
})
batprogressbar.mouse_enter = function ()
    bat_detailedinfo = naughty.notify(
    {
        text = functions.battery('BAT1', batprogressbar, 'popup'),
        timeout = 0,
        hover_timeout = 0.5,
        width = 135
    })
end
batprogressbar.mouse_leave = function () naughty.destroy(bat_detailedinfo) end

memprogressbar = widget({ type = 'progressbar', align = 'right' })
memprogressbar.width = 9
memprogressbar.height = 1
memprogressbar.gap = 1
memprogressbar.border_padding = 1
memprogressbar.border_width = 0
memprogressbar.ticks_count = 4
memprogressbar.vertical = true
memprogressbar:bar_properties_set('mem',
{
    bg = '#333333',
    fg = beautiful.fg_focus,
    border_color = '#888888',
    min_value = 0,
    max_value = 100 
})
memprogressbar.mouse_enter = function ()
    mem_detailedinfo = naughty.notify(
    {
        text = functions.memory(memprogressbar, 'popup'),
        timeout = 0,
        hover_timeout = 0.5,
        width = 100
    })
end
memprogressbar.mouse_leave = function () naughty.destroy(mem_detailedinfo) end

taglist.buttons =
{
    button({        }, 1, awful.tag.viewonly),
    button({ modkey }, 1, awful.client.movetotag),
    button({        }, 3, function (tag) tag.selected = not tag.selected end),
    button({ modkey }, 3, awful.client.toggletag),
    button({        }, 4, awful.tag.viewnext),
    button({        }, 5, awful.tag.viewprev) 
}
tasklist.buttons =
{
    button({ }, 1, function (c) client.focus = c; c:raise() end),
    button({ }, 4, function () awful.client.focus.byidx(1) end),
    button({ }, 5, function () awful.client.focus.byidx(-1) end) 
}

for s = 1, screen.count() do
    promptbox[s] = widget({ type = 'textbox', align = 'left' })
    layoutbox[s] = widget({ type = 'textbox', align = 'left' })
    layoutbox[s]:buttons(
    {
        button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        button({ }, 4, function () awful.layout.inc(layouts, 1) end),
        button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    })
    taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, taglist.buttons)
    tasklist[s] = awful.widget.tasklist.new(function(c)
        if c == client.focus and c ~= nil then 
            return spacer..awful.util.escape(c.name)
        end
        -- return awful.widget.tasklist.label.currenttags(c, s)
    end, tasklist.buttons)

    statusbar[s] = wibox(
    {
        position = 'top',
        height = '14',
        fg = beautiful.fg_normal,
        bg = beautiful.bg_normal
    })
    statusbar[s].widgets =
    {
        taglist[s],
        layoutbox[s],
        promptbox[s],
        tasklist[s],
        clockbox,
        memprogressbar,
        batprogressbar,
        s == 1 and systray or nil
    }
    statusbar[s].screen = s
end

-- {{{1 Binds

root.buttons(
{
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})

local globalkeys =
{
    key({ modkey            }, 'Left',  awful.tag.viewprev),
    key({ modkey            }, 'Right', awful.tag.viewnext),
    key({ modkey            }, 'x',     function () awful.util.spawn(term) end),
    key({ modkey            }, 'f',     function () awful.util.spawn(browser) end),
    key({ modkey            }, 't',     function () awful.util.spawn(filemanager) end),
    key({ modkey            }, 'a',     function () main_menu:toggle() end),
    key({ modkey, 'Control' }, 'r',     awesome.restart),
    key({ modkey, 'Shift'   }, 'q',     awesome.quit),
    key({ modkey            }, 'j',     function ()
        awful.client.focus.byidx( 1)
        if client.focus then
            client.focus:raise()
        end
    end),
    key({ modkey            }, 'k',     function ()
        awful.client.focus.byidx(-1)
        if client.focus then
            client.focus:raise()
        end
    end),
    key({ modkey            }, 'Tab',   function ()
        local allclients = awful.client.visible(client.focus.screen)
        for i,v in ipairs(allclients) do
            if allclients[i+1] then
                allclients[i+1]:swap(v)
            end
        end
        awful.client.focus.byidx(-1)
    end),
    key({ modkey            }, 'l',     function () awful.tag.incmwfact(0.025) end),
    key({ modkey            }, 'h',     function () awful.tag.incmwfact(-0.025) end),
    key({ modkey, 'Shift'   }, 'h',     function () awful.client.incwfact(0.05) end),
    key({ modkey, 'Shift'   }, 'l',     function () awful.client.incwfact(-0.05) end),
    key({ modkey, 'Control' }, 'h',     function () awful.tag.incnmaster(1) end),
    key({ modkey, 'Control' }, 'l',     function () awful.tag.incnmaster(-1) end),
    key({ modkey            }, 'space', function () awful.layout.inc(layouts, 1) end),
    key({ modkey, 'Shift'   }, 'space', function () awful.layout.inc(layouts, -1) end),
    key({ modkey }, 'r',function ()
        awful.prompt.run({ prompt = spacer..'Run:'..spacer },
        promptbox[mouse.screen], awful.util.spawn,
        awful.completion.bash, awful.util.getdir('cache')..'/history')
    end),
    key({                   }, '#121',  function () awful.util.spawn('rvol -t') end),
    key({                   }, '#122',  function () awful.util.spawn('rvol -d 2') end),
    key({                   }, '#123',  function () awful.util.spawn('rvol -i 2') end)
}

local clientkeys =
{
    key({ modkey            }, "c",     function (c) c:kill() end),
    key({ modkey, "Control" }, "space", awful.client.floating.toggle),
    key({ modkey, "Shift"   }, "r",     function (c) c:redraw() end),
    key({ modkey            }, "t",     awful.client.togglemarked),
    key({ modkey            }, "m",     function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
}

-- Using keynumbers instead of 1->9 because of my stupid azerty keyboard
local key_list = { '#10', '#11', '#12', '#13', '#14', '#15', '#16', '#17', '#18' }
local keynumber = table.getn(key_list)
for i = 1, keynumber do
    table.insert(globalkeys, key({ modkey }, key_list[i], function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewonly(tags[screen][i])
        end
    end))
    table.insert(globalkeys, key({ modkey, 'Control' }, key_list[i], function ()
        local screen = mouse.screen
        if tags[screen][i] then
            tags[screen][i].selected = not tags[screen][i].selected
        end
    end))
    table.insert(globalkeys, key({ modkey, 'Shift'   }, key_list[i], function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.movetotag(tags[client.focus.screen][i])
        end
    end))
    table.insert(globalkeys, key({ modkey, 'Control', 'Shift' }, key_list[i], function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.toggletag(tags[client.focus.screen][i])
        end
    end))
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
    if awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Gets executed when a new client appears
awful.hooks.manage.register(function (c)
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    c:buttons(
    {
        button({                   }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey            }, 1, awful.mouse.client.move),
        button({ modkey, 'Control' }, 1, awful.mouse.client.dragtotag.widget),
        button({ modkey            }, 3, awful.mouse.client.resize)
    })

    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Check application->screen/tag mappings and floating state
    local target_screen
    local target_float = false
    local target_tag   = awful.tag.selected(mouse.screen)
    -- 1 = class, 2 = instance, 3 = title, 4 = screen, 5 = tag, 6 = [is] floating
    for index, rule in pairs(app_rules) do
        if  (((rule[1] == nil) or (c.class    and c.class    == rule[1]))
        and  ((rule[2] == nil) or (c.instance and c.instance == rule[2]))
        and  ((rule[3] == nil) or string.find(c.name, rule[3], 1, true))) then
            target_float = rule[6]
            if rule[4] ~= nil then   target_screen = rule[4] end
            if rule[5] ~= nil then   target_tag    = rule[5] end
        end
    end
    if target_float then
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

    -- Inogre size hints usually given out by terminals (prevent gaps between windows)
    c.size_hints_honor = false

    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
end)

-- Gets exeucted when arranging the screen (as in, tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout then
        layoutbox[screen].text = '.'..functions.set_fg(beautiful.fg_focus, layout)..'.'
    else
        layoutbox[screen].text = nil
    end

    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)

-- 20 seconds
awful.hooks.timer.register(20, function ()
    functions.battery('BAT1', batprogressbar, 'progressbar')
    functions.memory(memprogressbar, 'progressbar')
end)

-- 1 minute
awful.hooks.timer.register(60, function ()
    functions.clock('%B %d,', '%H:%M', clockbox)
end)

io.stderr:write("\n\rAwesome loaded at "..os.date("%B %d, %H:%M").."\r\n\n")

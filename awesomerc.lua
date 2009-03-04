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
{  -- Class         Instance        Title               Screen          Tag     Floating
    { 'Firefox',    nil,            nil,                screen.count(), 2,      nil  },
    { 'Firefox',    'Download',     nil,                screen.count(), nil,    true },
    { 'Firefox',    'Places',       nil,                screen.count(), nil,    true },
    { 'Firefox',    'Extension',    nil,                screen.count(), nil,    true },
    { 'MPlayer',    nil,            nil,                screen.count(), 4,      true },
    { nil,          nil,            'VLC media player', screen.count(), 4,      true },
    { nil,          'Spotify.exe',  'Spotify',          screen.count(), 4,      true }
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

cpubox = widget({ type = 'textbox', align = 'right' })

membox = widget({ type = 'textbox', align = 'right' })

batbox = widget({ type = 'textbox', align = 'right' })

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
        cpubox,
        membox,
        batbox,
        clockbox,
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
    c:keys(clientkeys)

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

    -- Prevent new clients from becoming master
    awful.client.setslave(c)

    -- Check application->screen/tag mappings and floating state
    local isfloat, isscreen, istag
    for index, rule in pairs(app_rules) do
        if (((rule[1] == nil) or (c.class and c.class == rule[1]))
        and ((rule[2] == nil) or (c.instance and c.instance == rule[2]))
        and ((rule[3] == nil) or (c.name and string.find(c.name, rule[3], 1, true)))) then
            isscreen = rule[4]
            istag = rule[5]
            isfloat = rule[6]
        end
    end
 
    if isscreen then
        awful.client.movetoscreen(c, isscreen)
        c.screen = isscreen
    else
        isscreen = mouse.screen
        c.screen = isscreen
    end
 
    if istag then
        awful.client.movetotag(tags[isscreen][istag], c)
        c.tag = istag
    end
 
    if isfloat then
      awful.client.floating.set(c, isfloat)
    end

    client.focus = c

    -- Inogre size hints usually given out by terminals (prevent gaps between windows)
    c.size_hints_honor = false

    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
end)

-- Gets executed when arranging the screen (as in, tag switch, new client, etc)
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

    local tiledclients = awful.client.tiled(screen)
    if (#tiledclients == 0) then return end
    if (#tiledclients == 1) or (layout == 'max') then
        tiledclients[1].border_width = 0
    else
        for unused, current in pairs(tiledclients) do
            current.border_width = beautiful.border_width
        end
    end
end)

-- Runonce
functions.clock('%B %d,', '%H:%M', clockbox)
functions.cpu(cpubox)
functions.battery('BAT1', batbox)
functions.memory(membox)

-- 20 seconds
awful.hooks.timer.register(20, function ()
    functions.cpu(cpubox)
    functions.battery('BAT1', batbox)
    functions.memory(membox)
end)

-- 1 minute
awful.hooks.timer.register(60, function ()
    functions.clock('%B %d,', '%H:%M', clockbox)
end)

io.stderr:write("\n\rAwesome loaded at "..os.date("%B %d, %H:%M").."\r\n\n")

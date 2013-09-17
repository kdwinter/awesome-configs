local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

beautiful.init(awful.util.getdir("config") .. "/gigamo.lua")

terminal = "urxvtc"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.max,
  awful.layout.suit.magnifier,
  awful.layout.suit.floating
}

if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

tags = {
  names = {
    "main",
    "web",
    "dev",
    "misc"
  },
  layouts = {
    layouts[1],
    layouts[3],
    layouts[1],
    layouts[5]
  }
}

for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layouts)
end


-- Widgets
textclock = awful.widget.textclock()

memico = wibox.widget.imagebox()
memico:set_image(awful.util.getdir("config") .. "/icons/mem.png")
membox = wibox.widget.textbox()

batico = wibox.widget.imagebox()
batico:set_image(awful.util.getdir("config") .. "/icons/bat.png")
batbox = wibox.widget.textbox()

spacer = wibox.widget.textbox()
spacer:set_text("  ")

-- Create a wibox for each screen and add it
statusbar = {}
promptbox = {}
layoutbox = {}
taglist = {}
taglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, awful.client.toggletag)
)

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  promptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we"re using.
  -- We need one layoutbox per screen.
  layoutbox[s] = awful.widget.layoutbox(s)
  layoutbox[s]:buttons(awful.util.table.join(
     awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
     awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end)
  ))
  -- Create a taglist widget
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

  -- Create the wibox
  statusbar[s] = awful.wibox({ position = "top", screen = s })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(taglist[s])
  left_layout:add(layoutbox[s])
  left_layout:add(promptbox[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(batico)
  right_layout:add(batbox)
  right_layout:add(spacer)
  right_layout:add(memico)
  right_layout:add(membox)
  right_layout:add(spacer)
  right_layout:add(textclock)

  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)

  statusbar[s]:set_widget(layout)
end

-- Mouse bindings
root.buttons(awful.util.table.join(
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings
globalkeys = awful.util.table.join(
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev),
  awful.key({ modkey,           }, "Right",  awful.tag.viewnext),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

  awful.key({ modkey,           }, "j",
    function()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end
  ),
  awful.key({ modkey,           }, "k",
    function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end
  ),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j",      function() awful.client.swap.byidx(  1)  end),
  awful.key({ modkey, "Shift"   }, "k",      function() awful.client.swap.byidx( -1)  end),
  awful.key({ modkey,           }, "u",      awful.client.urgent.jumpto),
  awful.key({ modkey,           }, "Tab",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end
  ),

  -- Standard program
  awful.key({ modkey,           }, "Return", function() awful.util.spawn(terminal)    end),
  awful.key({ modkey, "Control" }, "r",      awesome.restart),
  awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

  awful.key({ modkey,           }, "l",      function() awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey,           }, "h",      function() awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, "Shift"   }, "h",      function() awful.tag.incnmaster( 1)      end),
  awful.key({ modkey, "Shift"   }, "l",      function() awful.tag.incnmaster(-1)      end),
  awful.key({ modkey, "Control" }, "h",      function() awful.tag.incncol( 1)         end),
  awful.key({ modkey, "Control" }, "l",      function() awful.tag.incncol(-1)         end),
  awful.key({ modkey,           }, "space",  function() awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, "Shift"   }, "space",  function() awful.layout.inc(layouts, -1) end),

  awful.key({ modkey, "Control" }, "n",      awful.client.restore),

  -- Prompt
  awful.key({ modkey            }, "r",      function() promptbox[mouse.screen]:run() end)
)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, "f",      function(c) c.fullscreen = not c.fullscreen  end),
  awful.key({ modkey,           }, "w",      function(c) c:kill()                         end),
  awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
         awful.tag.viewonly(tag)
        end
      end
    ),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
         awful.tag.viewtoggle(tag)
        end
      end
    ),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if client.focus and tag then
          awful.client.movetotag(tag)
        end
      end
    ),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if client.focus and tag then
          awful.client.toggletag(tag)
        end
      end
    )
  )
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)

-- Rules
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = { border_width = beautiful.border_width,
                   border_color = beautiful.border_normal,
                   focus = awful.client.focus.filter,
                   keys = clientkeys,
                   buttons = clientbuttons }
  },
  { rule = { class = "MPlayer" },
    properties = { floating = true }
  },
  { rule = { class = "gimp" },
    properties = { floating = true }
  },
  { rule = { class = "firefox-aurora" },
    properties = { tag = tags[1][2] }
  }
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)
  -- Enable sloppy focus
  --c:connect_signal("mouse::enter", function(c)
  --    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
  --        and awful.client.focus.filter(c) then
  --        client.focus = c
  --    end
  --end)

  if not startup then
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Functions
function memory()
  local memfile = io.open("/proc/meminfo")

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

  local mem_in_use = mem_total - (mem_free + mem_buffers + mem_cached)
  local mem_usage_percentage = math.floor(mem_in_use / mem_total * 100)

  return mem_in_use .. "M (" .. mem_usage_percentage .. "%)"
end
membox:set_text(memory())

function battery()
  local acpi = io.popen("acpi -i")
  local charge = "??"

  if acpi then
    for line in acpi:lines() do
      if not line:match("design") then
        charge = line:match("(%d+)%%")
      end
    end

    acpi:close()
  end
  
  return charge .. "%"
end
batbox:set_text(battery())

memwidget = timer({ timeout = 60 })
memwidget:connect_signal("timeout", function() membox:set_text(memory()) end)
memwidget:start()

batwidget = timer({ timeout = 60 })
batwidget:connect_signal("timeout", function() batbox:set_text(battery()) end)
batwidget:start()

io.stderr:write("\n\rawesome loaded at "..os.date('%B %d, %H:%M').."\r\n\n")

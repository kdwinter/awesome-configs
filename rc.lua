-------------------------------------------------------------------------------
-- @file rc.lua
-- @author Matthew Wild &lt;mwild1@gmail.com&gt;
-------------------------------------------------------------------------------

local rc, err = loadfile(os.getenv("HOME").."/.config/awesome/awesomerc.lua");
if rc then
	rc, err = pcall(rc);
	if rc then
		return;
	end
end
 
dofile("/etc/xdg/awesome/rc.lua");
 
for s = 1,screen.count() do
	mypromptbox[s].text = awful.util.escape(err:match("[^\n]*"));
end
 
local f = io.open(os.getenv("HOME").."/.awesome.err", "w+")
f:write("Awesome crashed during startup on ", os.date("%B %d, %H:%M:\n\n"))
f:write(err, "\n");
f:close();

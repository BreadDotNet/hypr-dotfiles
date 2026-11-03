-- Example monitor configuration. Copy it to a later-numbered conf.d Lua
-- fragment or require it from one, then adjust it for the machine.

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@165",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-3",
    mode = "1920x1080@71.91",
    position = "1920x0",
    scale = 1,
})

for workspace = 1, 5 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = "HDMI-A-1" })
end

for workspace = 6, 10 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-3" })
end

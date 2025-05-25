local side = "left"  -- modem side
local monitor = peripheral.find("monitor")

rednet.open(side)

local logFile = "logs.txt"
local lastSeenFile = "last_seen"

local function loadLastSeen()
    if not fs.exists(lastSeenFile) then return {} end
    local f = fs.open(lastSeenFile, "r")
    local data = textutils.unserialize(f.readAll())
    f.close()
    return data or {}
end

local function saveLastSeen(data)
    local f = fs.open(lastSeenFile, "w")
    f.write(textutils.serialize(data))
    f.close()
end

local function writeMonitor(line)
    if monitor then
        local h = monitor.getSize()
        local old = {}
        for i = 1, h - 1 do
            monitor.setCursorPos(1, i)
            old[i] = monitor.read() or ""
        end
        monitor.clear()
        for i = 1, h - 1 do
            monitor.setCursorPos(1, i)
            monitor.write(old[i])
        end
        monitor.setCursorPos(1, h)
        monitor.write(line)
    end
end

local lastSeen = loadLastSeen()
writeMonitor("Log server running...")

while true do
    local _, msg = rednet.receive()
    if type(msg) == "table" and msg.player and msg.checkpoint and msg.time then
        local line = string.format("%s | %s entered %s", msg.time, msg.player, msg.checkpoint)
        local f = fs.open(logFile, "a") f.writeLine(line) f.close()
        lastSeen[msg.player] = { time = msg.time, checkpoint = msg.checkpoint }
        saveLastSeen(lastSeen)
        writeMonitor(line)
    else
        writeMonitor("Invalid message")
    end
end

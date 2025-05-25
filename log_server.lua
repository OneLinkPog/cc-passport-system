local side = "left"  -- Side where modem is attached
rednet.open(side)

local monitor = peripheral.find("monitor")
if monitor then
    monitor.setTextScale(0.5)
end

local logFile = "logs.txt"
local lastSeenFile = "last_seen"
local lastLogLines = {}  -- Holds recent log lines
local maxLines = 10      -- Number of lines to display on monitor

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

local function updateMonitor()
    if not monitor then return end
    monitor.clear()
    monitor.setCursorPos(1, 1)
    for i, line in ipairs(lastLogLines) do
        monitor.setCursorPos(1, i)
        monitor.write(line:sub(1, 39))  -- Trim to fit width if needed
    end
end

local function addLogLine(line)
    table.insert(lastLogLines, line)
    if #lastLogLines > maxLines then
        table.remove(lastLogLines, 1)
    end
    updateMonitor()
end

local lastSeen = loadLastSeen()
addLogLine("Log server running...")

while true do
    local _, msg = rednet.receive()
    if type(msg) == "table" and msg.player and msg.checkpoint and msg.time then
        local line = string.format("%s | %s -> %s", msg.time, msg.player, msg.checkpoint)
        local f = fs.open(logFile, "a") f.writeLine(line) f.close()
        lastSeen[msg.player] = { time = msg.time, checkpoint = msg.checkpoint }
        saveLastSeen(lastSeen)
        addLogLine(line)
    else
        addLogLine("Invalid message received.")
    end
end

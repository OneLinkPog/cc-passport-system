local modemSide = "left"  -- Change to whatever side the modem is on
rednet.open(modemSide)

-- Try to find a monitor
local monitor = peripheral.find("monitor")
if monitor then
    monitor.setTextScale(0.5)
end

local logFile = "logs.txt"
local lastSeenFile = "last_seen"
local lastLogLines = {}
local maxLines = 10

-- Load last seen data from file
local function loadLastSeen()
    if not fs.exists(lastSeenFile) then return {} end
    local f = fs.open(lastSeenFile, "r")
    local data = textutils.unserialize(f.readAll())
    f.close()
    return data or {}
end

-- Save last seen data to file
local function saveLastSeen(data)
    local f = fs.open(lastSeenFile, "w")
    f.write(textutils.serialize(data))
    f.close()
end

-- Update the monitor with the latest lines
local function updateMonitor()
    if not monitor then return end
    monitor.clear()
    for i, line in ipairs(lastLogLines) do
        monitor.setCursorPos(1, i)
        monitor.write(line:sub(1, 39))  -- Trim to 39 characters for small monitors
    end
end

-- Add a line to the log buffer and update display
local function addLogLine(line)
    table.insert(lastLogLines, line)
    if #lastLogLines > maxLines then
        table.remove(lastLogLines, 1)
    end
    updateMonitor()
end

-- Load saved player checkpoint data
local lastSeen = loadLastSeen()

-- Display startup message
addLogLine("Passport Log Server Active")

-- Main loop
while true do
    local _, msg = rednet.receive()
    if type(msg) == "table" and msg.player and msg.checkpoint and msg.time then
        local logEntry = string.format("%s | %s → %s", msg.time, msg.player, msg.checkpoint)
        
        -- Append to logs.txt
        local f = fs.open(logFile, "a")
        f.writeLine(logEntry)
        f.close()

        -- Update last seen
        lastSeen[msg.player] = {
            checkpoint = msg.checkpoint,
            time = msg.time
        }
        saveLastSeen(lastSeen)

        -- Update monitor
        addLogLine(logEntry)
    else
        addLogLine("Invalid rednet message received.")
    end
end

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
        local w, _ = monitor.getSize()
        monitor.write(line:sub(1, w))
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
  local id, msg = rednet.receive("passport_log")

  if type(msg) == "table" then
    local player = msg.player
    local checkpoint = msg.checkpoint
    local time = msg.time

    if type(player) == "string" and type(checkpoint) == "string" and type(time) == "string" then
  print("Received log from", player, "->", checkpoint)

  -- Update lastSeen table
  lastSeen[player] = {
    checkpoint = checkpoint,
    time = time
  }
  saveLastSeen(lastSeen)

  -- Add a log line to the monitor
  local line = string.format("%s | %s -> %s", time, player, checkpoint)
  addLogLine(line)

else
  print("Received malformed table:", textutils.serialize(msg))
end
  else
    print("Invalid rednet message received:", textutils.serialize(msg))
  end
end

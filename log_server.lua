rednet.open("left")  -- Change to the side where the modem is attached

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

local lastSeen = loadLastSeen()
print("Log server running...")

while true do
    local _, msg = rednet.receive()
    if type(msg) == "table" and msg.player and msg.checkpoint and msg.time then
        local line = string.format("%s | %s entered %s", msg.time, msg.player, msg.checkpoint)
        local f = fs.open(logFile, "a") f.writeLine(line) f.close()
        lastSeen[msg.player] = { time = msg.time, checkpoint = msg.checkpoint }
        saveLastSeen(lastSeen)
        print("Logged: " .. line)
    else
        print("Invalid message")
    end
end

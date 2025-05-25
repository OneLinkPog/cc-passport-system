local checkpointName = "BorderGate1"  -- Your checkpoint name
local detectorSide = "top"           -- The side of the player detector
local modemSide = "right"             -- The side of the wireless modem
local scanRange = 5                   -- Detection range in blocks (radius)

rednet.open(modemSide)

print("Checkpoint active at " .. checkpointName)

while true do
    local players = peripheral.call(detectorSide, "getPlayersInRange", scanRange)
    for _, player in ipairs(players) do
        local now = textutils.formatTime(os.time(), true)
        local data = {
            player = player,
            checkpoint = checkpointName,
            time = now
        }
        rednet.broadcast(data)
        print("Sent: " .. player .. " -> " .. checkpointName)
    end
    sleep(2)
end

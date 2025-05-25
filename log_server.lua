local modemSide = "right"  -- Change if your modem is on a different side
rednet.open(modemSide)

-- Table to store last checkpoint per player
local lastCheckpoints = {}

print("Log server started. Waiting for checkpoint updates...")

while true do
    local senderId, message, protocol = rednet.receive()

    if type(message) == "table" and message.player and message.checkpoint and message.time then
        -- Update last checkpoint info
        lastCheckpoints[message.player] = {
            checkpoint = message.checkpoint,
            time = message.time
        }
        print(("Updated %s: %s at %s"):format(message.player, message.checkpoint, message.time))

    elseif type(message) == "string" and message:sub(1,5) == "query" then
        -- Query command format: query playerName
        local _, _, playerName = message:find("^query%s+(%S+)")
        if playerName then
            local info = lastCheckpoints[playerName]
            if info then
                print(("Last checkpoint of %s: %s at %s"):format(playerName, info.checkpoint, info.time))
            else
                print("No record found for player: " .. playerName)
            end
        else
            print("Usage: query <playerName>")
        end
    else
        print("Unknown message received.")
    end
end

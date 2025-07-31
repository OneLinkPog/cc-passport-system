-- checkpoint.lua
-- Run this on a checkpoint computer with player detector and modem
local COUNTRY_CODE = "BLIS"  -- Replace with the code for this country

-- Get peripherals
local modem = peripheral.find("modem") or error("No modem found")
local detector = peripheral.find("playerDetector") or error("No player detector found")

-- Utility functions
local function getUsername()
    local players = detector.getOnlinePlayers()
    if #players == 0 then
        print("No players nearby.")
        return nil
    elseif #players > 1 then
        print("Multiple players detected. Closest one will be used.")
    end

    -- Sort players by distance
    table.sort(players, function(a, b)
        return a.distance < b.distance
    end)

    return players[1].name
end

local function requestPassportCode(username)
    modem.transmit(1001, 1001, {
        type = "get_passport",
        username = username
    })

    local timer = os.startTimer(3)
    while true do
        local event, side, channel, replyChannel, message = os.pullEvent()
        if event == "modem_message" and channel == 1001 and type(message) == "table" then
            if message.type == "passport_data" and message.username == username then
                return message.passportCode, message.data
            end
        elseif event == "timer" and side == timer then
            print("Passport server did not respond.")
            return nil, nil
        end
    end
end

local function logAccess(passportCode, username, allowed)
    modem.transmit(1001, 1001, {
        type = "log_access",
        passportCode = passportCode,
        username = username,
        allowed = allowed,
        location = COUNTRY_CODE,
        timestamp = os.epoch("utc")
    })
end

-- Main Loop
while true do
    print("\n--- Passport Checkpoint ---")
    print("Waiting for player...")

    local username = getUsername()
    if not username then
        sleep(2)
        goto continue
    end

    print("Detected player: " .. username)

    local passportCode, passportData = requestPassportCode(username)

    if passportData then
        if passportData.nationality == COUNTRY_CODE then
            print("Welcome home, " .. username .. "!")
            logAccess(passportCode, username, true)
        else
            local hasVisa = false
            for _, visa in ipairs(passportData.visas) do
                if visa == COUNTRY_CODE then
                    hasVisa = true
                    break
                end
            end

            if hasVisa then
                print("Access granted (visa found).")
                logAccess(passportCode, username, true)
            else
                print("Access denied (no visa for " .. COUNTRY_CODE .. ").")
                logAccess(passportCode, username, false)
            end
        end
    else
        print("Invalid passport.")
        logAccess("unknown", use

local modem = peripheral.find("modem") or error("No modem attached")
modem.open(300)

local detector = peripheral.find("playerDetector") or error("No player detector attached")
local countryCode = "BLIS" -- Country this checkpoint is located in

while true do

  print("Enter player name:")
  local name = read()

  print("Enter passport code:")
  local code = read()

  -- Detect players nearby within 1 block
  local players = detector.getPlayersInRange(1)
  if #players == 0 then
    print("No player detected nearby. Please stand on the detector.")
  else
    local playerPresent = false
    for _, playerName in ipairs(players) do
      if playerName == name then
        playerPresent = true
        break
      end
    end

    if not playerPresent then
      print("The player '" .. name .. "' is not standing at the checkpoint.")
    else
      -- Get passport info and verify name matches
      modem.transmit(100, 300, {action = "get_passport_info", code = code})
      local _, _, _, _, response = os.pullEvent("modem_message")

      if response.status ~= "success" then
        print("Passport not found.")
      elseif response.info.name ~= name then
        print("Name does not match passport!")
      else
        local nationality = response.info.nationality

        if nationality == countryCode then
          print("Welcome home, " .. name .. "!")
          print("Access Granted to " .. name)
        else
          -- Check visa for non-citizens
          modem.transmit(100, 300, {action = "check_visa", code = code, target = countryCode})
          _, _, _, _, response = os.pullEvent("modem_message")

          if response.allowed then
            print("Visa found! Thank you and have a nice visit.")
            print("Access Granted to " .. name)
          else
            print("Access Denied. No visa was found for this country.")
          end
        end
      end
    end
  end
end

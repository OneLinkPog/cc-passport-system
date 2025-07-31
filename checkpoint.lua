local modem = peripheral.find("modem") or error("No modem attached")
modem.open(300)

local countryCode = "BLIS" -- Country this checkpoint is located in

while true do
  print("Enter player name:")
  local name = read()

  print("Enter passport code:")
  local code = read()

  -- First, get passport info and verify name
  modem.transmit(100, 300, {action = "get_passport_info", code = code})
  local _, _, _, _, response = os.pullEvent("modem_message")

  if response.status ~= "success" then
    print("Passport not found.")
  elseif response.info.name ~= name then
    print("Name does not match passport!")
  else
    local nationality = response.info.nationality

    if nationality == countryCode then
      -- Citizen: welcome home, access granted without visa
      print("Welcome home, " .. name .. "!")
      print("Access Granted to " .. name)
    else
      -- Non-citizen: check visa
      modem.transmit(100, 300, {action = "check_visa", code = code, target = countryCode})
      _, _, _, _, response = os.pullEvent("modem_message")

      if response.allowed then
        print("Access Granted to " .. name)
      else
        print("Access Denied. No visa for this country.")
      end
    end
  end
end

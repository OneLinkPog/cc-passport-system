local modem = peripheral.find("modem") or error("No modem attached")
modem.open(300)

local canRunCommands = commands and type(commands.run) == "function"

print("=== Passport Issuing Terminal ===")

while true do
  print("Enter your Minecraft username:")
  local username = read()

  print("Enter your passport code:")
  local passportCode = read()

  -- Send request to get passport info from server
  modem.transmit(100, 300, {action = "get_passport_info", code = passportCode})

  -- Wait for server response on channel 300
  local event, side, channel, replyChannel, response = os.pullEvent("modem_message")

  while channel ~= 300 do
    event, side, channel, replyChannel, response = os.pullEvent("modem_message")
  end

  if response.status ~= "success" then
    print("Passport code not found.")
  elseif response.info.name ~= username then
    print("Passport code does not belong to username " .. username)
  else
    print("Passport verified! Welcome, " .. username)
    local country = response.info.nationality
    print("Nationality: " .. country)

    local giveCmd = ('give @p minecraft:written_book{title:"Passport",author:"Passport Office",pages:[\'{"text":"Name: %s\\nNationality: %s\\nPassport ID: %s"}\']} 1')
      :format(username, country, passportCode)

    if canRunCommands then
      print("Giving passport book to nearest player...")
      commands.run(giveCmd)
      print("Passport book given!")
    else
      print("Cannot run commands automatically.")
      print("Run this command manually in server console or chat:")
      print(giveCmd)
    end
  end
end

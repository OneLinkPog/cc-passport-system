local modem = peripheral.find("modem") or error("No modem attached")
modem.open(100)

-- Check if 'commands' API is available
local canRunCommands = commands and type(commands.run) == "function"

print("=== Passport Issuing Terminal ===")

while true do
  print("\nEnter player Minecraft username:")
  local name = read()

  print("Enter nationality country code (e.g., BLIS):")
  local country = read():upper()

  -- Request passport issuance from server
  modem.transmit(300, 100, {action = "issue_passport", name = name, nationality = country})

  print("Waiting for passport code from server...")
  local event, side, channel, replyChannel, message = os.pullEvent("modem_message")

  if message.status == "success" and message.code then
    local passportCode = message.code
    print("Passport issued! Code:", passportCode)

    local giveCmd = ('give @p minecraft:written_book{title:"Passport",author:"Passport Office",pages:[\'{"text":"Name: %s\\nNationality: %s\\nPassport ID: %s"}\']} 1')
      :format(name, country, passportCode)

    if canRunCommands then
      print("Giving passport book to nearest player...")
      commands.run(giveCmd)
      print("Passport book given!")
    else
      print("Cannot run commands automatically.")
      print("Run this command manually in server console or chat:")
      print(giveCmd)
    end

  else
    print("Failed to issue passport. Try again.")
  end

end

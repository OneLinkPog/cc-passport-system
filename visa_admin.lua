-- visa_admin.lua
local modem = peripheral.find("modem") or error("No modem attached")
modem.open(400)

print("Visa Admin Console")
while true do
  print("Enter passport code:")
  local code = read()

  print("Enter country code to grant visa for:")
  local target = read()

  modem.transmit(100, 400, {action = "add_visa", code = code, target = target})
  local _, _, _, _, response = os.pullEvent("modem_message")

  if response.status == "visa_added" then
    print("Visa granted for", target)
  else
    print("Error")
  end
end

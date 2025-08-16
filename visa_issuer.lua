-- visa_issuer.lua
local modem = peripheral.find("modem") or error("No modem attached")
modem.open(400)
local country = "BLIS"

print("Visa Issuing Console")
while true do
  print("Issuing visas for country:", country)
  print("Enter passport code:")
  local code = read()

  modem.transmit(100, 400, {action = "add_visa", code = code, target = country})
  local _, _, _, _, response = os.pullEvent("modem_message")

  if response.status == "visa_added" then
    print("Visa granted for", code, "in country", country)
  else
    print("Error")
  end
end

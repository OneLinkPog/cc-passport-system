-- issuer.lua
local modem = peripheral.find("modem") or error("No modem attached")
modem.open(200)

local countryCode = "BLIS" -- Change to your country code

print("Passport Issuer for", countryCode)
while true do
  print("Enter player name to issue passport:")
  local name = read()

  modem.transmit(100, 200, {action = "issue_passport", nationality = countryCode, name = name})
  local _, _, _, _, response = os.pullEvent("modem_message")

  if response.status == "success" then
    print("Issued Passport Code:", response.code)
  else
    print("Error issuing passport")
  end
end

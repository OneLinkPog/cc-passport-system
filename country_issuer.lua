-- country_issuer.lua
-- For issuing passports in one country

-- CHANGE THIS TO YOUR COUNTRY CODE (4 letters)
local COUNTRY_CODE = "BLIS"

rednet.open("back")

print("== Passport Issuer for " .. COUNTRY_CODE .. " ==")

while true do
  print("Enter your Minecraft username:")
  local name = read()

  rednet.send(0, {
    cmd = "register",
    name = name,
    nationalityCode = COUNTRY_CODE
  })

  local id, response = rednet.receive()

  if response.status == "ok" then
    print("✅ Passport issued: " .. response.code)
  elseif response.status == "exists" then
    print("ℹ️ Already registered. Code: " .. response.code)
  else
    print("❌ Error: " .. (response.message or "unknown"))
  end

  print("\n---\n")
end

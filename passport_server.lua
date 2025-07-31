-- passport_server.lua
local modem = peripheral.find("modem") or error("No modem attached")
modem.open(100)

local passports = {}
local visaPermissions = {} -- [passportCode] = { COUNTRY = true, ... }
local countryCounts = {} -- [countryCode] = count

local function save()
  local file = fs.open("passport_data", "w")
  file.write(textutils.serialize({passports = passports, visaPermissions = visaPermissions, countryCounts = countryCounts}))
  file.close()
end

local function load()
  if fs.exists("passport_data") then
    local file = fs.open("passport_data", "r")
    local data = textutils.unserialize(file.readAll())
    file.close()
    passports = data.passports or {}
    visaPermissions = data.visaPermissions or {}
    countryCounts = data.countryCounts or {}
  end
end

load()

while true do
  local _, side, channel, replyChannel, message = os.pullEvent("modem_message")

  if message.action == "issue_passport" then
    local country = message.nationality
    local name = message.name

    if not countryCounts[country] then countryCounts[country] = 0 end
    countryCounts[country] = countryCounts[country] + 1

    local passportCode = country .. "-" .. countryCounts[country]
    passports[passportCode] = {name = name, nationality = country}
    save()
    modem.transmit(replyChannel, 100, {status = "success", code = passportCode})

  elseif message.action == "get_passport_info" then
    local code = message.code
    local data = passports[code]
    if data then
      modem.transmit(replyChannel, 100, {status = "success", info = data})
    else
      modem.transmit(replyChannel, 100, {status = "error", error = "Not found"})
    end

  elseif message.action == "add_visa" then
    local code = message.code
    local targetCountry = message.target
    visaPermissions[code] = visaPermissions[code] or {}
    visaPermissions[code][targetCountry] = true
    save()
    modem.transmit(replyChannel, 100, {status = "visa_added"})

  elseif message.action == "check_visa" then
    local code = message.code
    local targetCountry = message.target
    local allowed = visaPermissions[code] and visaPermissions[code][targetCountry]
    modem.transmit(replyChannel, 100, {status = "success", allowed = allowed == true})
  end
end

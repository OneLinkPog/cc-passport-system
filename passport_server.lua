-- passport_server.lua
-- Place this on ONE central server with a modem

local passports = {}
local visaPermissions = {}
local nationalityCounts = {}

-- === Data Persistence ===
local function saveData()
  local file = fs.open("passport_data", "w")
  file.write(textutils.serialize({
    passports = passports,
    visaPermissions = visaPermissions,
    nationalityCounts = nationalityCounts
  }))
  file.close()
end

local function loadData()
  if fs.exists("passport_data") then
    local file = fs.open("passport_data", "r")
    local data = textutils.unserialize(file.readAll())
    passports = data.passports or {}
    visaPermissions = data.visaPermissions or {}
    nationalityCounts = data.nationalityCounts or {}
    file.close()
  end
end

-- === Code Generation ===
local function findCodeByName(name)
  for code, data in pairs(passports) do
    if data.name == name then return code end
  end
  return nil
end

local function generatePassportCode(nationalityCode)
  nationalityCounts[nationalityCode] = (nationalityCounts[nationalityCode] or 0) + 1
  return nationalityCode .. "-" .. tostring(nationalityCounts[nationalityCode])
end

-- === Command Handler ===
local function handleMessage(senderID, message)
  local cmd = message.cmd
  local response = {}

  if cmd == "register" then
    local name = message.name
    local nationalityCode = message.nationalityCode
    local existing = findCodeByName(name)

    if existing then
      response = { status = "exists", code = existing }
    else
      local code = generatePassportCode(nationalityCode)
      passports[code] = {
        name = name,
        nationality = nationalityCode
      }
      saveData()
      response = { status = "ok", code = code }
    end

  elseif cmd == "get_passport" then
    local code = message.code
    local data = passports[code]
    if data then
      response = {
        status = "ok",
        passport = {
          name = data.name,
          nationality = data.nationality,
          code = code
        }
      }
    else
      response = { status = "not_found" }
    end

  elseif cmd == "check_visa" then
    local code = message.code
    local country = message.country
    local allowed = visaPermissions[code]

    if allowed then
      for _, c in ipairs(allowed) do
        if c == country then
          response = { status = "allowed" }
          break
        end
      end
    end
    response = response.status and response or { status = "denied" }

  elseif cmd == "grant_visa" then
    local code = message.code
    local country = message.country
    visaPermissions[code] = visaPermissions[code] or {}
    table.insert(visaPermissions[code], country)
    saveData()
    response = { status = "granted" }

  elseif cmd == "list_visas" then
    local code = message.code
    response = { status = "ok", visas = visaPermissions[code] or {} }

  else
    response = { status = "error", message = "unknown command" }
  end

  rednet.send(senderID, response)
end

-- === Main Loop ===
local function start()
  local modemSide = nil
  for _, side in ipairs({"left", "right", "top", "bottom", "front", "back"}) do
    if peripheral.getType(side) == "modem" then
      modemSide = side
      break
    end
  end

  if not modemSide then
    print("No modem found!")
    return
  end

  rednet.open(modemSide)
  loadData()
  print("📡 Passport Server Online.")

  while true do
    local senderID, message = rednet.receive()
    if type(message) == "table" and message.cmd then
      handleMessage(senderID, message)
    end
  end
end

start()

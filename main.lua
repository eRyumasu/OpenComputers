local component = require("component")
local fs = require("filesystem")
local computer = require("computer")
local bridge = component.openperipheral_bridge
tps = require("tps")
local gpu = component.gpu
local items = {
  {"dwcity:Materia", 0},
  {"minecraft:iron_ingot", 0},
  {"IC2:itemIngot", 0},
  {"IC2:itemIngot", 1},
  {"minecraft:gold_ingot", 0},
  {"minecraft:nether_star", 0},
  {"minecraft:diamond", 0},
  {"dwcity:SmallPalladium", 0},
  {"dwcity:SmallNeptunium", 0}
}

local players = {
  {"Ryumasu", false},
  {"MrRastok", false},
  {"Mihasich", false},
  {"boonya93", false},
  {"Vengeance", false},
  {"SouveRain", false}
}
local chat_box, me, radar, counter
local average, me_a, cb, r = false, false, false, false
-------------{TIME OPTIONS}------------------
local TIME_ZONE = 3 --Ваш часовой пояс
---------------------------------------------

---------------------------------------------
local t_correction = TIME_ZONE * 3600
local chat_box_name = "§8[§4Алиса§8]"
local adm = "Ryumasu" -- Ник админа компа
local allow_mem = false -- Отображать на экране кол-во памяти или нет
local localize = {
  time = "§9Время МСК:",
  join_in_game = " §7вошел в игру!",
  left_from_game = " §7покинул игру!",
  user_online = "online",
  user_offline = "offline",
  near_ME = "Игроки около МЭ"
}
local colors = {
  item_size = 0x05F5F0, -- кол-во предметов
  eu = 0x5555FF, -- еу/т
  mem = 0xFFFFFF, -- память
  time = 0x55F055, --Время
  time_text = 0x00FFFF, -- текст "Время МСК:"(пример)
  online = 0x008000, --оналайн на очках
  offline = 0xB22222, -- оффлайн на очках
  near = 0x0000CD, --текст "Игроки рядом с МЭ"
  players_near = 0xFF4500, -- цвет игроков рядом
  players = 0x228B22 -- цвет игроков в Online/offline
}
--------------------------------------------

function numR(n)
  if n / 1000 <= 1 then
    av = string.format("%.3f", tostring(n))
  elseif n / 1000000 >= 1 then
    av = string.format("%.3f", tostring(n / 1000000)) .. "M"
  else
    av = string.format("%.1f", tostring(n / 1000)) .. "k"
  end
  return av
end

function round(n)
  if n >= math.floor(n)+0.5 then
    n = math.ceil(n)
  else
    n = math.floor(n)
  end
  return n
end

function check()
  if component.isAvailable("average_counter") then
    average = true
    counter = component.average_counter
  end
  if component.isAvailable("chat_box") then
    cb = true
    chat_box = component.chat_box
    chat_box.setName(chat_box_name)
  end
  if component.isAvailable("me_controller") then
    me_a = true
    me = component.me_controller
  end
  if component.isAvailable("radar") then
    r = true
    radar = component.radar
  end
  componentsOnScreen()
end

local function getTimeHost()
  local file = io.open('/tmp/UNIX.tmp', 'w')
  file:write('TIME_ZONE = '..TIME_ZONE)
  file:close()
  local lastmod = tonumber(string.sub(fs.lastModified('/tmp/UNIX.tmp'), 1, -4)) + t_correction
  local dt = os.date('%H:%M:%S', lastmod)
  return dt
end

function addBox(x, y, w, h, color, tran)
  bridge.addBox(x, y, w, h, color, tran)
end

function addText(x, y, text, color)
  bridge.addText(x, y, text, color)
end

function addIcon(x, y, name, meta)
  bridge.addIcon(x, y, name, meta)
end

function gui()
  w, h = gpu.maxResolution()
  gpu.fill(1, 1, w, h, " ")
end

function componentsOnScreen()
  gpu.set(1, 1, "Chat-box: " .. tostring(cb))
  gpu.set(1, 2, "ME: " .. tostring(me_a))
  gpu.set(1, 3, "Radar: " .. tostring(r))
  gpu.set(1, 4, "Counter: " .. tostring(average))
end

function addAllIcons()
  y = 25
  for i = 1, #items do
    y = y + 15
    addIcon(5, y, items[i][1], items[i][2])
  end
end

function getSize(name,dmg)
 for _, item in ipairs(me.getItemsInNetwork()) do
  if item.name == name and item.damage == dmg then
   return item.size
  end
 end
 return 0
end

function setEnergy()
  addIcon(5, 25, "AdvancedSolarPanel:BlockMolecularTransformer", 0)
  addText(25, 27, numR(counter.getAverage()) .. "EU/t", colors.eu)
end

function setTime()
  addText(0, 2, localize.time, colors.time_text)
  addText(55, 2, getTimeHost(), colors.time)
  addText(0, 12, "TPS: "..round(tps()), colors.time)
end

function freeMemory()
  if allow_mem then
    addText(0, 12, "MEM: "..math.floor((computer.freeMemory() / 1000)).."mb".."/"..math.floor((computer.totalMemory() / 1000)).."mb".." "..math.floor(((computer.freeMemory() / computer.totalMemory()) * 100)).."%", colors.mem)
  end
end

function checkOnline(n)
  computer.removeUser(adm)
  if computer.addUser(players[n][1]) then
    computer.removeUser(players[n][1])
    if players[n][2] == false then
      if cb then
        chat_box.say("§a"..players[n][1] .. localize.join_in_game)
      end
      players[n][2] = true
    end
    return true
  else
    if players[n][2] == true then
      if cb then
        chat_box.say("§c"..players[n][1] .. localize.left_from_game)
      end
      players[n][2] = false
    end
    computer.removeUser(players[n][1])
    return false
  end
end

function drawOnline()
  yy = 17
  for i = 1, #players do
    yy = yy + 8
--    addText(90, yy, players[i][1], colors.players)
    if checkOnline(i) then
      addText(90, yy, players[i][1], colors.online)
--      addText(140, yy, localize.user_online, colors.online)
    else
      addText(90, yy, players[i][1], colors.offline)
--      addText(140, yy, localize.user_offline, colors.offline)
    end
  end
end

function getPlayersNearME()
  addText(90, 75, localize.near_ME, colors.near)
  a = 75
  temp = radar.getPlayers()
  for i = 1, #temp do
    a = a + 10
    for j = 1, #players do
      if temp[i].name == players[j][1] then
        return
      else
        addText(90, a, temp[i].name.." "..math.floor(temp[i].distance), colors.players_near)
      end
    end
  end
end

check()
bridge.clear()
addBox(25, 0, 100, 100, 0xFFFFFF, 0)
addAllIcons()
bridge.sync()
gui()

while true do
  check()
  computer.addUser(adm)
  bridge.clear()
  if me_a then
    addAllIcons()
    y = 32
    tps = require("tps")
    per_second = counter.getAverage() * tps()
    if per_second then
      interval = 60000000 / per_second
    end
    y = y + 15
    addText(25, y, getSize(items[1][1], items[1][2]).. " " .. round(interval) .. "s", colors.item_size)
    for i = 2, #items do
      y = y + 15
      addText(25, y, numR(getSize(items[i][1], items[i][2])), colors.item_size)
--      item_number = getSize(items[i][1], items[i][2])
--      if item_number / 1000 <= 1 then
--        nm = string.format("%.3f", tostring(item_number))
--      elseif item_number / 1000000 >= 1 then
--        nm = string.format("%.3f", tostring(item_number / 1000000)) .. "m"
--      else
--        nm = string.format("%.1f", tostring(item_number / 1000)) .. "k"
--      addText(25, y, mn, colors.item_size)
--      end
    end
  end
  if average then
    setEnergy()
  end
  setTime()
  drawOnline()
  freeMemory()
  if r then
    getPlayersNearME()
  end
  os.sleep(0.001)
  bridge.sync()
end

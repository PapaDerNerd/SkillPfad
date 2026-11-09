local ADDON, ns = ...
SkillPfadDB = SkillPfadDB or {}

-- Wegpunkte: bevorzugt TomTom, sonst der Blizzard-Wegpunkt, sonst nur eine Chatzeile.

local function say(msg) ns.print("|cffffd100SkillPfad:|r " .. msg) end
ns.say = say

local uids = {}

local function mapName(m)
  local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(m)
  return info and info.name
end

function ns.HasTomTom()
  return TomTom ~= nil and type(TomTom.AddWaypoint) == "function"
end

function ns.ClearWaypoints()
  if TomTom and TomTom.RemoveWaypoint then
    for _, uid in ipairs(uids) do pcall(TomTom.RemoveWaypoint, TomTom, uid) end
  end
  wipe(uids)
end

-- loc = { uiMapID, x, y, Beschriftung, Art }; x/y in Prozent (0-100)
local function setOne(loc, arrow)
  local m, x, y, label = loc[1], loc[2], loc[3], loc[4]

  -- Weg 1: TomTom-Befehl /way (wenn in den Optionen gewaehlt)
  if SkillPfadDB.wayMode and SlashCmdList and SlashCmdList["TOMTOM_WAY"] then
    local ok = pcall(SlashCmdList["TOMTOM_WAY"], ns.fmt("#%d %.1f %.1f %s", m, x, y, label))
    if ok then return true end
  end

  -- Weg 2: TomTom-Programmierschnittstelle (Koordinaten 0-1)
  if ns.HasTomTom() then
    local ok, uid = pcall(TomTom.AddWaypoint, TomTom, m, x / 100, y / 100, {
      title = label, from = "SkillPfad", source = "SkillPfad", persistent = false,
      minimap = true, world = true, crazy = arrow,
    })
    if ok and uid then uids[#uids + 1] = uid; return true end
  end

  -- Weg 3: Blizzard-Wegpunkt
  if C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
    if not C_Map.CanSetUserWaypointOnMap or C_Map.CanSetUserWaypointOnMap(m) then
      C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(m, x / 100, y / 100))
      if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
      end
      return true
    end
  end
  return false
end

local function report(list, n)
  local first = list[1]
  local parts = {}
  for i = 1, math.min(#list, 3) do
    parts[#parts + 1] = ns.fmt("%s %.1f, %.1f", list[i][4], list[i][2], list[i][3])
  end
  if n > 0 then
    say(ns.fmt("%d Wegpunkt%s gesetzt: %s", n, n == 1 and "" or (ns.lang == "en" and "s" or "e"), table.concat(parts, " | ")))
    if not ns.HasTomTom() then say("TomTom nicht gefunden: es wird nur der Blizzard-Wegpunkt genutzt.") end
  else
    say("Konnte keinen Wegpunkt setzen. Ziel: " .. (first and (first[4] .. ns.fmt(" %.1f, %.1f", first[2], first[3])) or "?"))
  end
end

-- Fraktion: Allianz-Spieler nutzen LocationsA.lua
function ns.IsAlly()
  local f = UnitFactionGroup and UnitFactionGroup("player")
  return f == "Alliance"
end
function ns.LocFor(id)
  if ns.IsAlly() and ns.locA and ns.locA[id] then return ns.locA[id] end
  return ns.loc and ns.loc[id]
end
local function trainerLoc(name)
  if ns.IsAlly() and ns.trainerA and ns.trainerA[name] then return ns.trainerA[name] end
  return ns.trainer and ns.trainer[name]
end

-- Alle bekannten Orte zu einem Item (Haendler und Vorkommen)
function ns.GoToItem(id)
  local list = ns.LocFor(id)
  if not list or #list == 0 then say("Zu diesem Material kenne ich keinen Ort."); return end
  ns.ClearWaypoints()
  local n = 0
  for i, l in ipairs(list) do if setOne(l, i == 1) then n = n + 1 end end
  if n > 1 and TomTom and TomTom.SetClosestWaypoint then pcall(TomTom.SetClosestWaypoint, TomTom) end
  report(list, n)
end

-- Ein einzelner Ort, z.B. ein Lehrer
function ns.GoToLoc(loc)
  ns.ClearWaypoints()
  local n = setOne(loc, true) and 1 or 0
  report({ loc }, n)
end

------------------------------------------------------------ Lehrer
-- { von, bis, Lehrer (englischer Name), Rolle }: wird angezeigt, wenn dein Skill im Bereich liegt
ns.profTrainers = {
  leder     = { {1, 149, "Karolek", "Lehrer (Geselle ab Skill 50)"}, {125, 224, "Una", "Experte (Skill 125)"},
                {200, 300, "Hahrana Ironhide", "Artisan (Skill 200)"} },
  skin      = { {1, 74, "Kagil", "Starter-Lehrer (nur bis 75)"}, {50, 300, "Thuwd", "Lehrer in Orgrimmar"} },
  kochen    = { {1, 224, "Cook Torka", "Lehrer in Razor Hill"}, {125, 224, "Wulan", "Expertenkochbuch"},
                {200, 300, "Zamja", "Artisan-Quest starten"}, {225, 300, "Dirge Quikcleave", "Artisan-Lehrer (Tanaris)"},
                {225, 300, "Gikkix", "Rezepte (Steamwheedle)"} },
  ersthilfe = { {1, 124, "Arnok", "Lehrer in Orgrimmar"}, {125, 224, "Balai Lok'Wein", "Expertenbuch"},
                {200, 300, "Doctor Gregory Victor", "Artisan-Quest Triage"} },
  schmied   = { {200, 300, "Brikk Keencraft", "Artisan-Lehrer (Booty Bay)"} },
  ingenieur = { {125, 199, "Roxxik", "Experte (Orgrimmar)"}, {200, 300, "Buzzek Bracketswing", "Artisan-Lehrer (Tanaris)"} },
  schneider = { {1, 124, "Magar", "Lehrer in Orgrimmar"}, {125, 199, "Josef Gregorian", "Experte (Unterstadt)"},
                {200, 300, "Daryl Stack", "Artisan-Lehrer (Tarrens Mühle)"} },
  verzauber = { {1, 124, "Godan", "Lehrer in Orgrimmar"}, {125, 224, "Hgarth", "Experte (Steinkrallengebirge)"} },
  bergbau   = { {1, 300, "Krunn", "Lehrer in Razor Hill"} },
  kraeuter  = { {1, 74, "Mishiki", "Starter-Lehrer (Sen'jin)"}, {50, 300, "Jandi", "Lehrer in Orgrimmar"} },
  angeln    = { {125, 224, "Old Man Heming", "Expertenbuch (Booty Bay)"}, {200, 300, "Nat Pagle", "Artisan-Quest"} },
}

-- Buttons fuer Lehrer, passend zum Skill
function ns.TrainerActions(key, rank)
  local out = {}
  local tbl = (ns.IsAlly() and ns.profTrainersA) or ns.profTrainers
  for _, t in ipairs(tbl[key] or {}) do
    local loc = trainerLoc(t[3])
    if loc and rank >= t[1] and rank <= t[2] then
      out[#out + 1] = {
        text = ns.fmt("Weg: %s - %s", t[3], t[4]),
        fn = function() ns.GoToLoc(loc) end,
      }
    end
  end
  return out
end

------------------------------------------------------------ Sammelziele pro Phase (Kraeuter, Bergbau)
ns.phaseItems = {
  kraeuter = { {2447, 765, 2449}, {785, 2450, 3820}, {2453, 3355, 3356, 3357}, {3818, 3821, 3358},
               {8831, 4625}, {8838, 8845, 13464}, {8846, 13463, 13465, 13466} },
  bergbau  = { {2770}, {2771, 2775}, {2772, 2776}, {3858, 7911}, {10620}, {10620} },
}

function ns.PhaseItemActions(key, phaseIndex)
  local out = {}
  for _, id in ipairs((ns.phaseItems[key] or {})[phaseIndex] or {}) do
    if ns.LocFor(id) then
      local nm = ns.locName and ns.locName[id] or tostring(id)
      out[#out + 1] = { text = ns.fmt("Weg: %s finden", nm), fn = function() ns.GoToItem(id) end }
    end
  end
  return out
end

------------------------------------------------------------ Befehle: /sp weg <Name oder Link>
local function findItem(q)
  local id = tonumber(q:match("[Ii]tem:(%d+)"))
  if id and ns.LocFor(id) then return id end
  q = q:lower()
  local exact, part
  local ids = {}
  for iid in pairs(ns.loc or {}) do ids[iid] = true end
  if ns.IsAlly() then for iid in pairs(ns.locA or {}) do ids[iid] = true end end
  for iid in pairs(ids) do
    local de = ns.locName[iid] or ""
    local names = { de:lower() }
    if ns.lang == "en" and de ~= "" then names[#names + 1] = ns.tr(de):lower() end   -- englischer Name aus dem Woerterbuch
    local cn = GetItemInfo and GetItemInfo(iid)
    if cn then names[#names + 1] = cn:lower() end
    for _, n in ipairs(names) do
      if n == q then exact = exact or iid elseif n ~= "" and n:find(q, 1, true) then part = part or iid end
    end
  end
  return exact or part
end

local function findTrainer(q)
  q = q:lower()
  local function search(tbl)
    for en, loc in pairs(tbl or {}) do
      if en:lower():find(q, 1, true) or loc[4]:lower():find(q, 1, true) then return loc end
    end
  end
  return (ns.IsAlly() and search(ns.trainerA)) or search(ns.trainer)
end

function ns.WegCommand(arg)
  arg = (arg or ""):match("^%s*(.-)%s*$")
  if arg == "" then
    say("Benutzung: /sp weg <Material oder Lehrer>   z.B. /sp weg grober faden   oder   /sp weg karolek")
    say("Mit /sp weg aus löschst du die Wegpunkte wieder.")
    return
  end
  if arg:lower() == "aus" then ns.ClearWaypoints(); say("Wegpunkte gelöscht."); return end
  local id = findItem(arg)
  if id then ns.GoToItem(id); return end
  local t = findTrainer(arg)
  if t then ns.GoToLoc(t); return end
  say("Nichts gefunden für: " .. arg)
end

-- /sp mapcheck: zeigt die Kartennamen der genutzten Karten-IDs, damit du Abweichungen sofort siehst
function ns.MapCheck()
  local seen, ids = {}, {}
  local function add(m) if not seen[m] then seen[m] = true; ids[#ids + 1] = m end end
  for _, list in pairs(ns.loc or {}) do for _, e in ipairs(list) do add(e[1]) end end
  for _, e in pairs(ns.trainer or {}) do add(e[1]) end
  table.sort(ids)
  local bad, parts = 0, {}
  for _, m in ipairs(ids) do
    local n = mapName(m)
    if not n then bad = bad + 1 end
    parts[#parts + 1] = m .. "=" .. (n or "|cffff4040?|r")
  end
  say(ns.fmt("%d Karten genutzt, %d unbekannt:", #ids, bad))
  local line = ""
  for _, p in ipairs(parts) do
    if #line + #p > 200 then ns.print(line); line = "" end
    line = line .. p .. ", "
  end
  if line ~= "" then ns.print(line) end
  say("TomTom: " .. (ns.HasTomTom() and "gefunden" or "NICHT gefunden"))
end

local ADDON, ns = ...
SkillPfadDB = SkillPfadDB or {}

function ns.phaseFor(key, rank)
  local d = ns.defs[key]
  for _, p in ipairs(d.phases) do
    if rank >= p[1] and rank < p[2] then return p end
  end
  return d.phases[#d.phases]
end

function ns.RankOf(key)
  local r = (SkillPfadDB.ranks or {})[key]
  if not r and key == "leder" then r = SkillPfadDB.rank end   -- alte Version
  return r
end
local function setRank(key, r)
  SkillPfadDB.ranks = SkillPfadDB.ranks or {}
  SkillPfadDB.ranks[key] = r
end

-- Schluessel des gerade geoeffneten Berufsfensters (oder nil)
local function openKeyClassic()
  if GetTradeSkillLine and TradeSkillFrame and TradeSkillFrame:IsShown() then
    local n = GetTradeSkillLine()
    return n and ns.profs[n] or nil
  end
end

local function scanClassic()
  local name, rank, maxRank = GetTradeSkillLine()
  local key = name and ns.profs[name]
  if not key then return nil end
  for i = GetNumTradeSkills(), 1, -1 do
    local _, t, _, expanded = GetTradeSkillInfo(i)
    if t == "header" and not expanded then ExpandTradeSkillSubClass(i) end
  end
  local list, anyPrice = {}, false
  for i = 1, GetNumTradeSkills() do
    local n, t = GetTradeSkillInfo(i)
    if t == "optimal" or t == "medium" then
      local weight, money, miss, reag, crafts = 0, 0, 0, {}, math.huge
      for j = 1, GetTradeSkillNumReagents(i) do
        local rn, _, rc, have = GetTradeSkillReagentInfo(i, j)
        if rn then
          local link = GetTradeSkillReagentItemLink(i, j)
          local id = link and tonumber(link:match("item:(%d+)"))
          ns.seen[rn] = id or true
          weight = weight + ns.WeightOf(id) * rc
          local p = ns.GetPrice(rn, id)
          if p then money = money + p * rc; anyPrice = true else miss = miss + 1 end
          reag[#reag + 1] = { rn, rc, have or 0, id }
          crafts = math.min(crafts, math.floor((have or 0) / rc))
        end
      end
      if crafts == math.huge then crafts = 0 end
      local chance = (t == "optimal") and 1 or 0.75
      list[#list + 1] = { name = n, type = t, reag = reag, crafts = crafts,
        wscore = weight / chance, mscore = money / chance, money = money, miss = miss }
    end
  end
  local usePrice = SkillPfadDB.price and anyPrice
  table.sort(list, function(a, b)
    if usePrice and a.mscore ~= b.mscore then return a.mscore < b.mscore end
    return a.wscore < b.wscore
  end)
  return key, rank, maxRank, list, usePrice
end


-- Modernes Handwerksfenster (C_TradeSkillUI) - so ist es im Forever-Client
local function modernInfo()
  if not (C_TradeSkillUI and C_TradeSkillUI.GetBaseProfessionInfo) then return nil end
  local ok, info = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
  if not ok or type(info) ~= "table" then return nil end
  local n = info.professionName or info.parentProfessionName
  local key = n and (ns.profs[n] or (info.parentProfessionName and ns.profs[info.parentProfessionName]))
  if not key then return nil end
  return key, info.skillLevel or 0, info.maxSkillLevel or 0
end

local function frameShown()
  return (ProfessionsFrame and ProfessionsFrame:IsShown())
      or (TradeSkillFrame and TradeSkillFrame:IsShown()) or false
end
ns.TradeFrameShown = frameShown

local function itemName(id)
  local n = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id)
  if not n and GetItemInfo then n = GetItemInfo(id) end
  return n or ns.locName[id] or ("item:" .. id)
end
local function itemCount(id)
  if C_Item and C_Item.GetItemCount then return C_Item.GetItemCount(id, true) or 0 end
  return GetItemCount and GetItemCount(id, true) or 0
end

local function scanModern()
  local key, rank, maxRank = modernInfo()
  if not key then return nil end
  local list, anyPrice = {}, false
  local ids = C_TradeSkillUI.GetAllRecipeIDs and C_TradeSkillUI.GetAllRecipeIDs() or {}
  for _, rid in ipairs(ids) do
    local ri = C_TradeSkillUI.GetRecipeInfo(rid)
    local d = ri and ri.learned and ri.relativeDifficulty
    -- 0 = optimal (orange), 1 = medium (gelb)
    if d == 0 or d == 1 then
      local sch = C_TradeSkillUI.GetRecipeSchematic(rid, false)
      local weight, money, miss, reag, crafts = 0, 0, 0, {}, math.huge
      for _, slot in ipairs(sch and sch.reagentSlotSchematics or {}) do
        local r1 = slot.reagents and slot.reagents[1]
        local id = r1 and r1.itemID
        local rc = slot.quantityRequired or 1
        if id then
          local rn = itemName(id)
          local have = itemCount(id)
          ns.seen[rn] = id
          weight = weight + ns.WeightOf(id) * rc
          local p = ns.GetPrice(rn, id)
          if p then money = money + p * rc; anyPrice = true else miss = miss + 1 end
          reag[#reag + 1] = { rn, rc, have, id }
          crafts = math.min(crafts, math.floor(have / rc))
        end
      end
      if crafts == math.huge then crafts = 0 end
      local t = (d == 0) and "optimal" or "medium"
      local chance = (d == 0) and 1 or 0.75
      list[#list + 1] = { name = ri.name, type = t, reag = reag, crafts = crafts,
        wscore = weight / chance, mscore = money / chance, money = money, miss = miss }
    end
  end
  local usePrice = SkillPfadDB.price and anyPrice
  table.sort(list, function(a, b)
    if usePrice and a.mscore ~= b.mscore then return a.mscore < b.mscore end
    return a.wscore < b.wscore
  end)
  return key, rank, maxRank, list, usePrice
end

local function openKey()
  if GetTradeSkillLine and TradeSkillFrame and TradeSkillFrame:IsShown() then return openKeyClassic() end
  if frameShown() then return (modernInfo()) end
end

local scanErrShown = false
local function scan()
  if GetTradeSkillLine and GetNumTradeSkills and TradeSkillFrame and TradeSkillFrame:IsShown() then
    return scanClassic()
  end
  local r = { pcall(scanModern) }
  if not r[1] then
    if not scanErrShown then
      scanErrShown = true
      print("|cffff4040SkillPfad Scanfehler:|r " .. tostring(r[2]))
    end
    return nil
  end
  return unpack(r, 2)
end

-- fuer /sp check: Scan ohne Anzeige
function ns.CheckScan()
  if not frameShown() then return nil end
  local key, rank, maxRank, list = scan()
  if not key then return nil end
  local nrec = (C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs and #C_TradeSkillUI.GetAllRecipeIDs()) or (GetNumTradeSkills and GetNumTradeSkills()) or "?"
  return key, rank, nrec, list and #list or 0
end

local pending, wantOpen = false, false

local function refresh()
  pending = false
  local key, rank, maxRank, list, usePrice = scan()
  if not key then wantOpen = false; return end
  setRank(key, rank)
  local def = ns.defs[key]
  local ph = ns.phaseFor(key, rank)
  local L = {}
  L[#L + 1] = string.format("|cffffd100%s – Skill: %d / %d|r", def.label, rank, maxRank)
  if rank >= maxRank and maxRank < 300 then
    L[#L + 1] = "|cffff8040Maximum erreicht: Lerne beim Lehrer die nächste Stufe.|r"
  end
  L[#L + 1] = string.format("Aktuelle Phase: |cff00ff00%s|r", ph[3])
  L[#L + 1] = "Material holen: " .. ph[4]
  for _, h in ipairs(def.hints or {}) do
    if rank >= h[1] and rank <= h[2] then
      L[#L + 1] = "|cff999999Tipp: " .. h[3] .. "|r"
    end
  end
  for _, wl in ipairs(ns.WarnLines(key, rank)) do L[#L + 1] = wl end
  for _, ql in ipairs(ns.QuestLines(key, rank)) do L[#L + 1] = ql end
  if usePrice then
    L[#L + 1] = "Sortierung: |cffffd100AH-Preise|r"
  elseif SkillPfadDB.price then
    L[#L + 1] = "Sortierung: Farm-Aufwand (noch keine Preise, siehe Optionen)"
  else
    L[#L + 1] = "Sortierung: |cffffd100Farm-Aufwand|r"
  end
  L[#L + 1] = " "
  if #list == 0 then
    L[#L + 1] = "Keine orangenen/gelben Rezepte gefunden."
  else
    L[#L + 1] = "|cffffd100Beste Rezepte zum Skillen:|r"
    for k = 1, math.min(SkillPfadDB.topN or 3, #list) do
      local r = list[k]
      local col = (r.type == "optimal") and "|cffff8040" or "|cffffff00"
      L[#L + 1] = string.format("%d. %s%s|r  (Material für %dx)", k, col, r.name, r.crafts)
      if usePrice then
        local note = (r.miss > 0) and " (ohne Händlerware)" or ""
        L[#L + 1] = "   Kosten/Herstellung: ~" .. (GetCoinTextureString or GetMoneyString or tostring)(math.floor(r.money)) .. note
      end
      for _, m in ipairs(r.reag) do
        local rn, rc, have = m[1], m[2], m[3]
        local c = (have >= rc) and "|cff00ff00" or "|cffff4040"
        L[#L + 1] = string.format("   %s%s: %d/%d|r", c, rn, have, rc)
        local src = have < rc and ns.SourceOf(m[4])
        if src then
          L[#L + 1] = "      |cff999999-> " .. src .. "|r"
        end
      end
    end
  end
  if #list > 0 then
    for _, sl in ipairs(ns.ShoppingLines(list, rank, ph, maxRank, usePrice)) do L[#L + 1] = sl end
  end
  for _, pl in ipairs(ns.CraftPlanLines(key, rank)) do L[#L + 1] = pl end
  ns.SetLines(key, L)

  local acts, seenId = {}, {}
  for k = 1, math.min(SkillPfadDB.topN or 3, #list) do
    for _, m in ipairs(list[k].reag) do
      local id = m[4]
      if id and m[3] < m[2] and ns.LocFor(id) and not seenId[id] and #acts < 6 then
        seenId[id] = true
        acts[#acts + 1] = { text = "Weg: " .. m[1] .. " besorgen", fn = function() ns.GoToItem(id) end }
      end
    end
  end
  for _, a in ipairs(ns.TrainerActions(key, rank)) do acts[#acts + 1] = a end
  for _, a in ipairs(ns.QuestActions(key, rank or 1)) do acts[#acts + 1] = a end
  for _, a in ipairs(ns.ShoppingActions(key, rank, ph and ph[2])) do acts[#acts + 1] = a end
  ns.SetActions(key, acts)
  if wantOpen then
    wantOpen = false
    if SkillPfadDB.autoShow and ns.Enabled(key) then
      local was = ns.WindowShown()
      ns.OpenWindow(key, (not was) or ns.autoOpened)
    end
  end
end

local function queue()
  if pending then return end
  pending = true
  C_Timer.After(0.2, refresh)
end

function ns.Refresh()
  if openKey() then queue() end
end

-- Wird beim Wechsel auf einen Berufs-Tab aufgerufen
for key, def in pairs(ns.defs) do
 if not def.gather then
  ns.tabRefresh[key] = function()
    if openKey() == key then queue(); return end
    local r = ns.RankOf(key)
    local L = { "Öffne dein " .. def.label .. "-Fenster für Empfehlungen." }
    if r then
      local ph = ns.phaseFor(key, r)
      L[#L + 1] = " "
      L[#L + 1] = string.format("Zuletzt bekannter Skill: %d", r)
      L[#L + 1] = "Phase: |cff00ff00" .. ph[3] .. "|r"
      L[#L + 1] = "Material holen: " .. ph[4]
    end
    ns.SetLines(key, L)
    ns.SetActions(key, ns.TrainerActions(key, r or 1))
  end
 end
end

local ev = CreateFrame("Frame")
ns.Reg(ev, "TRADE_SKILL_SHOW")
ns.Reg(ev, "TRADE_SKILL_UPDATE")
ns.Reg(ev, "BAG_UPDATE_DELAYED")
ns.Reg(ev, "TRADE_SKILL_CLOSE")
ns.Reg(ev, "TRADE_SKILL_LIST_UPDATE")
ns.Reg(ev, "TRADE_SKILL_DATA_SOURCE_CHANGED")
ns.Reg(ev, "SKILL_LINES_CHANGED")
-- Der Client kennt evtl. nicht alle Klassik-Ereignisse: Fenster zusaetzlich per Abfrage beobachten
local wasOpen = false
C_Timer.NewTicker(0.7, function()
  local shown = ns.TradeFrameShown()
  if shown and not wasOpen then wantOpen = true; wasOpen = true; if openKey() then queue() end
  elseif not shown and wasOpen then
    wasOpen = false; wantOpen = false
    if ns.autoOpened and ns.WindowShown() then ns.CloseWindow() end
  elseif shown and openKey() and ns.WindowShown() then queue() end
end)
if hooksecurefunc and TradeSkillFrame_SetSelection then
  hooksecurefunc("TradeSkillFrame_SetSelection", function() if openKey() then queue() end end)
end
ev:SetScript("OnEvent", function(_, e)
  if e == "TRADE_SKILL_SHOW" then
    wantOpen = true
  elseif e == "TRADE_SKILL_CLOSE" then
    wantOpen = false
    if ns.autoOpened and ns.WindowShown() then ns.CloseWindow() end
    return
  elseif e == "BAG_UPDATE_DELAYED" and not ns.WindowShown() then
    return
  end
  if openKey() then queue() end
end)

------------------------------------------------------------ Befehle
local function handle(msg, default)
  msg = (msg or ""):lower():match("^%s*(.-)%s*$")
  if msg == "reset" then
    ns.ResetPos(); print("SkillPfad: Position zurückgesetzt.")
  elseif msg == "api" then
    local function has(n) return (_G[n] ~= nil) and "ja" or "NEIN" end
    print("SkillPfad API: GetTradeSkillLine " .. has("GetTradeSkillLine") ..
      ", GetNumTradeSkills " .. has("GetNumTradeSkills") .. ", TradeSkillFrame " .. has("TradeSkillFrame") ..
      ", C_TradeSkillUI " .. has("C_TradeSkillUI") .. ", C_SkillInfo " .. has("C_SkillInfo") ..
      ", TomTom " .. has("TomTom"))
    do
      local k, r, m = modernInfo()
      local nrec = (C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs and #C_TradeSkillUI.GetAllRecipeIDs()) or "?"
      print("SkillPfad: Fenster sichtbar " .. tostring(frameShown()) .. ", erkannter Beruf " .. tostring(k) ..
        " " .. tostring(r) .. "/" .. tostring(m) .. ", Rezepte " .. tostring(nrec) ..
        ", ProfessionsFrame " .. has("ProfessionsFrame"))
      local ok, res = pcall(scanModern)
      print("SkillPfad: Scan " .. tostring(ok) .. " " .. (ok and (res and "ok" or "nil") or tostring(res)))
    end
    if C_TradeSkillUI and C_TradeSkillUI.GetBaseProfessionInfo then
      local ok, p = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
      if ok and p then print("Aktuelles Handwerk: " .. tostring(p.professionName) .. " " .. tostring(p.skillLevel) .. "/" .. tostring(p.maxSkillLevel)) end
    end
  elseif msg == "scan" then
    ns.StartScan()
  elseif msg == "preis" then
    SkillPfadDB.price = not SkillPfadDB.price
    print("SkillPfad: Sortierung nach " .. (SkillPfadDB.price and "AH-Preisen" or "Farm-Aufwand"))
    ns.Refresh()
  elseif msg == "weg" or msg:match("^weg%s") then ns.WegCommand(msg:sub(4))
  elseif msg == "mapcheck" then ns.MapCheck()
  elseif msg == "check" or msg == "test" then ns.Check()
  elseif ns.alias[msg] then ns.OpenWindow(ns.alias[msg])
  elseif msg == "route" or msg:match("^route%s") then
    local arg = msg:sub(6):gsub("^%s+", "")
    local key = (arg ~= "" and (ns.alias[arg] or arg)) or "leder"
    local r = ns.NextRoute(key)
    if r then
      print("|cffffd100SkillPfad:|r Route für " .. key .. ": " .. r.name)
      if ns.RefreshAll then ns.RefreshAll() end
    else
      print("|cffffd100SkillPfad:|r Für diesen Beruf gibt es nur eine Route. Beispiele: /sp route leder, /sp route schmied, /sp route ingenieur, /sp route alchemie")
    end
  elseif msg == "einst" or msg == "opt" then ns.OpenWindow("opt")
  elseif default then ns.OpenWindow(default)
  elseif ns.WindowShown() then ns.CloseWindow() else ns.OpenWindow() end
end

SLASH_SKILLPFAD1 = "/lg"
SLASH_SKILLPFAD2 = "/leder"
SLASH_SKILLPFAD3 = "/sp"
SLASH_SKILLPFAD4 = "/skillpfad"
SlashCmdList["SKILLPFAD"] = function(m) handle(m, nil) end
SLASH_SKILLPFADK1 = "/kochen"
SlashCmdList["SKILLPFADK"] = function(m) handle(m, "kochen") end
SLASH_SKILLPFADH1 = "/erstehilfe"
SlashCmdList["SKILLPFADH"] = function(m) handle(m, "ersthilfe") end

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
      ns.print("|cffff4040SkillPfad Scanfehler:|r " .. tostring(r[2]))
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

local function buildRaw(key, rank, maxRank, list, usePrice, cached)
  local def = ns.defs[key]
  local ph = ns.phaseFor(key, rank)
  local L = {}
  L[#L + 1] = ns.fmt("|cffffd100%s – Skill: %d / %d|r", def.label, rank, maxRank)
  if cached then
    L[#L + 1] = "|cff999999Stand vom letzten Öffnen des Berufsfensters (Skill " .. cached.rank ..
      "). Menge im Beutel ist aktuell, Rezeptfarben evtl. nicht. Öffne das Berufsfenster zum Aktualisieren.|r"
  end
  if rank >= maxRank and maxRank < 300 then
    L[#L + 1] = "|cffff8040Maximum erreicht: Lerne beim Lehrer die nächste Stufe.|r"
  end
  L[#L + 1] = ns.fmt("Aktuelle Phase: |cff00ff00%s|r", ph[3])
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
      L[#L + 1] = ns.fmt("%d. %s%s|r  (Material für %dx)", k, col, r.name, r.crafts)
      if usePrice then
        local note = (r.miss > 0) and " (ohne Händlerware)" or ""
        L[#L + 1] = "   Kosten/Herstellung: ~" .. (GetCoinTextureString or GetMoneyString or tostring)(math.floor(r.money)) .. note
      end
      for _, m in ipairs(r.reag) do
        local rn, rc, have = m[1], m[2], m[3]
        local c = (have >= rc) and "|cff00ff00" or "|cffff4040"
        L[#L + 1] = ns.fmt("   %s%s: %d/%d|r", c, rn, have, rc)
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
        acts[#acts + 1] = { text = ns.fmt("Weg: %s besorgen", m[1]), fn = function() ns.GoToItem(id) end }
      end
    end
  end
  for _, a in ipairs(ns.TrainerActions(key, rank)) do acts[#acts + 1] = a end
  for _, a in ipairs(ns.QuestActions(key, rank or 1)) do acts[#acts + 1] = a end
  for _, a in ipairs(ns.ShoppingActions(key, rank, ph and ph[2])) do acts[#acts + 1] = a end
  ns.SetActions(key, acts)
  if not cached and wantOpen then
    wantOpen = false
    if SkillPfadDB.autoShow and ns.Enabled(key) then
      local was = ns.WindowShown()
      ns.OpenWindow(key, (not was) or ns.autoOpened)
    end
  end
end

-- Sichere Huelle: ein Rechenfehler (z.B. kaputter Cache) darf nicht das Fenster oder den Chat fluten
local lastBuildErr = 0
local function build(key, ...)
  local ok, err = pcall(buildRaw, key, ...)
  if ok then return end
  if SkillPfadDB.cache then SkillPfadDB.cache[key] = nil end   -- verdaechtigen Cache verwerfen
  if GetTime() - lastBuildErr > 30 then
    lastBuildErr = GetTime()
    ns.print("|cffff4040SkillPfad:|r Anzeige konnte nicht berechnet werden und wurde zurueckgesetzt. Oeffne das Berufsfenster erneut. (" .. tostring(err):sub(1, 160) .. ")")
  end
  pcall(ns.SetLines, key, { "Anzeige konnte nicht berechnet werden. Öffne das Berufsfenster erneut." })
  pcall(ns.SetActions, key, {})
end

local function refreshRaw()
  pending = false
  local key, rank, maxRank, list, usePrice = scan()
  if not key then wantOpen = false; return end
  setRank(key, rank)
  -- Ergebnis merken, damit die Empfehlungen auch ohne offenes Berufsfenster erscheinen
  local c = {}
  for k = 1, math.min(8, #list) do
    local r = list[k]
    local rg = {}
    for _, m in ipairs(r.reag) do rg[#rg + 1] = { m[1], m[2], m[4] } end
    c[#c + 1] = { name = r.name, type = r.type, money = r.money, miss = r.miss, reag = rg,
                  wscore = r.wscore, mscore = r.mscore }
  end
  SkillPfadDB.cache = SkillPfadDB.cache or {}
  SkillPfadDB.cache[key] = { rank = rank, maxRank = maxRank, list = c }
  build(key, rank, maxRank, list, usePrice, nil)
end

local lastScanErr = 0
local function refresh()
  local ok, err = pcall(refreshRaw)
  if not ok and GetTime() - lastScanErr > 30 then
    lastScanErr = GetTime()
    ns.print("|cffff4040SkillPfad:|r Scan fehlgeschlagen (" .. tostring(err):sub(1, 160) .. ")")
  end
end

local function queue()
  if pending then return end
  pending = true
  C_Timer.After(0.2, refresh)
end

function ns.Refresh()
  if openKey() then queue(); return end
  -- Berufsfenster zu: gemerkten Stand des aktuellen Tabs neu rechnen (z.B. nach Umschalten der Sortierung)
  if ns.WindowShown() then
    local t = ns.CurrentTab and ns.CurrentTab()
    if t and ns.tabRefresh[t] then pcall(ns.tabRefresh[t]) end
  end
end

-- Wird beim Wechsel auf einen Berufs-Tab aufgerufen
for key, def in pairs(ns.defs) do
 if not def.gather then
  ns.tabRefresh[key] = function()
    if openKey() == key then queue(); return end
    local r = ns.RankOf(key)
    local cc = SkillPfadDB.cache and SkillPfadDB.cache[key]
    if cc and cc.list and #cc.list > 0 then
      local list = {}
      for _, e in ipairs(cc.list) do
        local reag, crafts = {}, math.huge
        for _, m in ipairs(e.reag) do
          local have = m[3] and itemCount(m[3]) or 0
          reag[#reag + 1] = { m[1], m[2], have, m[3] }
          crafts = math.min(crafts, math.floor(have / m[2]))
        end
        if crafts == math.huge then crafts = 0 end
        list[#list + 1] = { name = e.name, type = e.type, money = e.money or 0, miss = e.miss or 0,
          reag = reag, crafts = crafts, wscore = e.wscore, mscore = e.mscore }
      end
      local usePrice = false
      if SkillPfadDB.price then
        for _, e in ipairs(list) do if (e.mscore or 0) > 0 then usePrice = true; break end end
      end
      table.sort(list, function(a, b)
        if usePrice and a.mscore ~= b.mscore then return (a.mscore or 0) < (b.mscore or 0) end
        return (a.wscore or 0) < (b.wscore or 0)
      end)
      build(key, r or cc.rank, cc.maxRank or 300, list, usePrice, cc)
      return
    end
    local L = { "Öffne dein " .. def.label .. "-Fenster für Empfehlungen." }
    if r then
      local ph = ns.phaseFor(key, r)
      L[#L + 1] = " "
      L[#L + 1] = ns.fmt("Zuletzt bekannter Skill: %d", r)
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
-- Oeffnen/Schliessen wird alle 0,7 s geprueft, neu gescannt nur etwa alle 3 s (Ereignisse loesen sofort aus)
local wasOpen, tick = false, 0
C_Timer.NewTicker(0.7, function()
  tick = tick + 1
  local shown = ns.TradeFrameShown()
  if shown and not wasOpen then wantOpen = true; wasOpen = true; if openKey() then queue() end
    if ns.UpdateOpenBtn and ns.WindowShown() then ns.UpdateOpenBtn(ns.CurrentTab()) end
  elseif not shown and wasOpen then
    wasOpen = false; wantOpen = false
    if ns.autoOpened and ns.WindowShown() then ns.CloseWindow()
    elseif ns.WindowShown() then
      local t = ns.CurrentTab and ns.CurrentTab()
      if t and ns.tabRefresh[t] then ns.tabRefresh[t]() end
      if ns.UpdateOpenBtn then ns.UpdateOpenBtn(t) end
    end
  elseif shown and tick % 4 == 0 and ns.WindowShown() and openKey() then queue() end
end)
if hooksecurefunc and TradeSkillFrame_SetSelection then
  hooksecurefunc("TradeSkillFrame_SetSelection", function() if openKey() then queue() end end)
end
local bagPending = false
ev:SetScript("OnEvent", function(_, e)
  if e == "TRADE_SKILL_SHOW" then
    wantOpen = true
  elseif e == "TRADE_SKILL_CLOSE" then
    wantOpen = false
    if ns.autoOpened and ns.WindowShown() then ns.CloseWindow() end
    return
  elseif e == "BAG_UPDATE_DELAYED" then
    if not ns.WindowShown() then return end
    if not openKey() then
      -- Berufsfenster zu: Beutelmengen im sichtbaren Tab nachfuehren (gebremst)
      if not bagPending then
        bagPending = true
        C_Timer.After(0.5, function()
          bagPending = false
          if ns.WindowShown() and not openKey() then
            local t = ns.CurrentTab and ns.CurrentTab()
            if t and ns.tabRefresh[t] then pcall(ns.tabRefresh[t]) end
          end
        end)
      end
      return
    end
  end
  if openKey() then queue() end
end)

------------------------------------------------------------ Befehle
local function handle(msg, default)
  msg = (msg or ""):lower():match("^%s*(.-)%s*$")
  if msg == "reset" then
    ns.ResetPos(); ns.print("SkillPfad: Position zurückgesetzt.")
  elseif msg == "help" or msg == "befehle" or msg == "?" then
    ns.print("|cffffd100SkillPfad – Befehle:|r")
    ns.print("  /sp – Fenster öffnen/schließen;  /sp opt – Optionen")
    ns.print("  /sp leder, /sp kochen, /sp alchemie ... – Beruf direkt öffnen")
    ns.print("  /sp weg <Material oder Lehrer> – Wegpunkt setzen;  /sp weg aus – Wegpunkte löschen")
    ns.print("  /sp route <Beruf> – Route wechseln;  /sp preis – Sortierung umschalten (AH-Preise / Farm-Aufwand)")
    ns.print("  /sp lang de | en | auto – Sprache;  /sp reset – Fensterposition zurücksetzen")
    ns.print("  /sp check – Selbsttest;  /spdiag – Ladefehler;  /sp mapcheck – Karten-IDs prüfen")
  elseif msg == "api" then
    local function has(n) return (_G[n] ~= nil) and "ja" or "NEIN" end
    ns.print("SkillPfad API: GetTradeSkillLine " .. has("GetTradeSkillLine") ..
      ", GetNumTradeSkills " .. has("GetNumTradeSkills") .. ", TradeSkillFrame " .. has("TradeSkillFrame") ..
      ", C_TradeSkillUI " .. has("C_TradeSkillUI") .. ", C_SkillInfo " .. has("C_SkillInfo") ..
      ", TomTom " .. has("TomTom"))
    do
      local k, r, m = modernInfo()
      local nrec = (C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs and #C_TradeSkillUI.GetAllRecipeIDs()) or "?"
      ns.print("SkillPfad: Fenster sichtbar " .. tostring(frameShown()) .. ", erkannter Beruf " .. tostring(k) ..
        " " .. tostring(r) .. "/" .. tostring(m) .. ", Rezepte " .. tostring(nrec) ..
        ", ProfessionsFrame " .. has("ProfessionsFrame"))
      local ok, res = pcall(scanModern)
      ns.print("SkillPfad: Scan " .. tostring(ok) .. " " .. (ok and (res and "ok" or "nil") or tostring(res)))
    end
    if C_TradeSkillUI and C_TradeSkillUI.GetBaseProfessionInfo then
      local ok, p = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
      if ok and p then ns.print("Aktuelles Handwerk: " .. tostring(p.professionName) .. " " .. tostring(p.skillLevel) .. "/" .. tostring(p.maxSkillLevel)) end
    end
  elseif msg == "lang" or msg:match("^lang%s") or msg == "sprache" or msg:match("^sprache%s") then
    local a = msg:match("^%a+%s+(%a+)")
    if a == "de" or a == "en" then ns.SetLang(a)
    elseif a == "auto" then ns.SetLang(nil)
    else
      local l = SkillPfadDB.lang
      ns.SetLang((l == nil and "de") or (l == "de" and "en") or nil)
    end
    if ns.UpdateOptions then ns.UpdateOptions() end
    ns.print("|cffffd100SkillPfad:|r Sprache: " .. (ns.lang == "en" and "English" or "Deutsch") ..
      (SkillPfadDB.lang == nil and " (auto)" or "") .. "  –  /sp lang de | en | auto")
  elseif msg == "scan" then
    ns.StartScan()
  elseif msg == "preis" then
    SkillPfadDB.price = not SkillPfadDB.price
    ns.print("SkillPfad: Sortierung nach " .. (SkillPfadDB.price and "AH-Preisen" or "Farm-Aufwand"))
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
      ns.print("|cffffd100SkillPfad:|r Route für " .. key .. ": " .. r.name)
      if ns.RefreshAll then ns.RefreshAll() end
    else
      ns.print("|cffffd100SkillPfad:|r Für diesen Beruf gibt es nur eine Route. Beispiele: /sp route leder, /sp route schmied, /sp route ingenieur, /sp route alchemie")
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

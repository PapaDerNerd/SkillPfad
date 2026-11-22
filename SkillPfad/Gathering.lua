local ADDON, ns = ...
SkillPfadDB = SkillPfadDB or {}

-- Reine Skill-Guides (Berufe mit gather = true): lesen nur deinen Skill aus.

local function findSkill(def)
  local function find()
    for i = 1, ns.Skills.Num() do
      local n, header, rank, maxRank = ns.Skills.Info(i)
      if n and not header and def.names[n] then return rank, maxRank end
    end
  end
  local r, m = find()
  if not r then
    ns.Skills.ExpandAll()   -- alle Kategorien aufklappen
    r, m = find()
  end
  return r, m
end

-- Kuerschnerei: hoechstes haeutbares Mob-Level (Richtwert)
local function mobLevel(rank)
  if rank < 100 then return math.max(10, math.floor((rank + 100) / 10)) end
  return math.floor(rank / 5)
end

local function build(key)
  local def = ns.defs[key]
  local rank, maxRank = findSkill(def)
  local L = {}
  if not rank then
    L[#L + 1] = "|cffff8040" .. def.label .. " nicht gefunden (nicht erlernt?).|r"
    L[#L + 1] = "Der ganze Weg steht unten (aufklappen)."
  else
    local c = ns.C()
    c.ranks = c.ranks or {}
    c.ranks[key] = rank
    c.maxRanks = c.maxRanks or {}
    c.maxRanks[key] = maxRank
    local ph = ns.phaseFor(key, rank)
    L[#L + 1] = "##now|Jetzt|"
    if rank >= maxRank and maxRank < 300 then
      L[#L + 1] = "|cffff8040Maximum erreicht: Lerne beim Lehrer die nächste Stufe.|r"
    end
    L[#L + 1] = ns.fmt("Sammeln: |cff00ff00%s|r", ph[3])
    L[#L + 1] = "Wo: " .. ph[4]
    if key == "skin" then
      L[#L + 1] = ns.fmt("Höchstes häutbares Mob-Level: |cff00ff00~%d|r", mobLevel(rank))
    end
    for _, wl in ipairs(ns.WarnLines(key, rank)) do L[#L + 1] = wl end
    for _, tl in ipairs(ns.TipSections(key, rank)) do L[#L + 1] = tl end
    for _, ql in ipairs(ns.QuestLines(key, rank)) do L[#L + 1] = ql end
    if key == "skin" then
      local lr = ns.RankOf("leder")
      L[#L + 1] = " "
      if lr then
        local lp = ns.phaseFor("leder", lr)
        L[#L + 1] = ns.fmt("|cffffd100Für Lederverarbeitung (Skill %d):|r", lr)
        L[#L + 1] = "Du brauchst gerade |cff00ff00" .. lp[3] .. "|r"
        L[#L + 1] = "Farmen: " .. lp[4]
      else
        L[#L + 1] = "Öffne einmal dein Lederverarbeitung-Fenster, dann zeige ich dir auch dein Leder-Ziel."
      end
    end
  end
  for _, pl in ipairs(ns.GatherPlanLines(key, rank)) do L[#L + 1] = pl end
  for _, pl in ipairs(ns.PathSection(key, rank)) do L[#L + 1] = pl end
  ns.SetLines(key, L)

  local acts = {}
  if rank then
    local idx = 1
    for i, p in ipairs(def.phases) do if rank >= p[1] and rank < p[2] then idx = i end end
    for _, a in ipairs(ns.PhaseItemActions(key, idx)) do acts[#acts + 1] = a end
  end
  for _, a in ipairs(ns.TrainerActions(key, rank or 1)) do acts[#acts + 1] = a end
  for _, a in ipairs(ns.QuestActions(key, rank or 1)) do acts[#acts + 1] = a end
  for _, craft in ipairs(ns.gatherPairs[key] or {}) do
    for _, a in ipairs(ns.ShoppingActions(craft, ns.RankOf(craft), nil)) do a.sec = "plan"; acts[#acts + 1] = a end
  end
  for _, a in ipairs(ns.GunstActions()) do acts[#acts + 1] = a end
  ns.SetActions(key, acts)
end

for key, def in pairs(ns.defs) do
  if def.gather then
    ns.tabRefresh[key] = function() build(key) end
  end
end

local ev = CreateFrame("Frame")
ns.Reg(ev, "SKILL_LINES_CHANGED")
ev:SetScript("OnEvent", function()
  if not ns.WindowShown() then return end
  local cur = ns.CurrentTab()
  if ns.defs[cur] and ns.defs[cur].gather then build(cur) end
end)

SLASH_SKILLPFADS1 = "/kuersch"
SlashCmdList["SKILLPFADS"] = function() ns.OpenWindow("skin") end

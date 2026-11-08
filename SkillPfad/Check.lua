local ADDON, ns = ...

-- /sp check: Selbsttest im Spiel. Gibt je Punkt OK / FEHLT aus, damit Fehler sofort sichtbar sind.
local function ok(t) return "|cff00ff00OK|r " .. t end
local function bad(t) return "|cffff4040FEHLT|r " .. t end
local function warn(t) return "|cffffff00HINWEIS|r " .. t end

function ns.Check()
  local out = {}
  local function add(s) out[#out + 1] = s end
  local ver = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON, "Version"))
    or (GetAddOnMetadata and GetAddOnMetadata(ADDON, "Version")) or "?"
  local gv, gb, _, toc = GetBuildInfo()
  add("|cffffd100SkillPfad-Selbsttest|r  Version " .. tostring(ver) .. ", Spiel " .. tostring(gv) .. " (" .. tostring(gb) .. "), Interface " .. tostring(toc))

  -- Ladefehler
  local errs = SkillPfadDB and SkillPfadDB.errors or {}
  add(#errs == 0 and ok("keine Ladefehler") or bad(#errs .. " Ladefehler (/spdiag zeigt sie)"))

  -- Daten
  local np, nq, nl, nla = 0, 0, 0, 0
  for _ in pairs(ns.defs or {}) do np = np + 1 end
  for _, l in pairs(ns.quests or {}) do nq = nq + #l end
  for _ in pairs(ns.loc or {}) do nl = nl + 1 end
  for _ in pairs(ns.locA or {}) do nla = nla + 1 end
  add((np == 12 and nq > 50 and nl > 50) and ok(string.format("Daten: %d Berufe, %d Quests, %d Material-Orte (Horde), %d (Allianz)", np, nq, nl, nla))
    or bad(string.format("Daten unvollständig: %d Berufe, %d Quests, %d Orte", np, nq, nl)))

  -- Fraktion / Routen
  local fac = UnitFactionGroup and UnitFactionGroup("player") or "?"
  local routes = {}
  for _, k in ipairs { "leder", "schmied", "ingenieur", "alchemie", "schneider", "verzauber" } do
    local r = ns.RouteOf and ns.RouteOf(k)
    if r then routes[#routes + 1] = k .. "=" .. r.id end
  end
  add(ok("Fraktion " .. tostring(fac) .. "; Routen: " .. table.concat(routes, ", ")))

  -- Berufsfenster-Scan
  local scanned = ns.CheckScan and { ns.CheckScan() }
  if not scanned or not scanned[1] then
    add(warn("Berufsfenster nicht offen oder Beruf nicht erkannt – öffne z.B. Lederverarbeitung und gib /sp check erneut ein."))
  else
    local key, rank, nrec, nlist = scanned[1], scanned[2], scanned[3], scanned[4]
    add(ok(string.format("Scan: Beruf %s, Skill %s, %s Rezepte gefunden, %s Empfehlungen", tostring(key), tostring(rank), tostring(nrec), tostring(nlist))))
  end

  -- Skills
  local sk = {}
  for _, k in ipairs(ns.order or {}) do
    local r = ns.RankOf and ns.RankOf(k)
    if r then sk[#sk + 1] = (ns.defs[k].label or k) .. " " .. r end
  end
  add(#sk > 0 and ok("Bekannte Skills: " .. table.concat(sk, ", ")) or warn("Noch kein Skill bekannt – Berufsfenster einmal öffnen."))

  -- Auctionator
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  if api then
    local p = ns.GetPrice and ns.GetPrice("Dickes Leder", 4304)
    add(p and ok("Auctionator erkannt, Dickes Leder: " .. (GetCoinTextureString and GetCoinTextureString(p) or p))
      or warn("Auctionator erkannt, aber kein Preis für Dickes Leder (AH einmal scannen)."))
  else
    add(warn("Auctionator nicht gefunden – es werden nur selbst gescannte Preise genutzt."))
  end

  -- TomTom
  add((ns.HasTomTom and ns.HasTomTom()) and ok("TomTom gefunden") or warn("TomTom nicht gefunden – nur Blizzard-Wegpunkt."))

  -- Minimap
  local mb = _G["LibDBIcon10_SkillPfad"] or _G["SkillPfadMinimapButton"]
  add(mb and ok("Minimap-Knopf vorhanden" .. ((mb.IsShown and mb:IsShown()) and "" or " (ausgeblendet)")) or bad("Minimap-Knopf nicht gefunden"))

  -- Karten-IDs (Horde und Allianz, Lehrer, Quests)
  if C_Map and C_Map.GetMapInfo then
    local seen, badIds = {}, {}
    local function chk(m)
      if m and not seen[m] then
        seen[m] = true
        local i = C_Map.GetMapInfo(m)
        if not (i and i.name) then badIds[#badIds + 1] = m end
      end
    end
    for _, l in pairs(ns.loc or {}) do for _, e in ipairs(l) do chk(e[1]) end end
    for _, l in pairs(ns.locA or {}) do for _, e in ipairs(l) do chk(e[1]) end end
    for _, e in pairs(ns.trainer or {}) do chk(e[1]) end
    for _, e in pairs(ns.trainerA or {}) do chk(e[1]) end
    for _, l in pairs(ns.quests or {}) do for _, e in ipairs(l) do chk(e[7]) end end
    local n = 0
    for _ in pairs(seen) do n = n + 1 end
    add(#badIds == 0 and ok(n .. " Karten-IDs gültig") or bad(#badIds .. " von " .. n .. " Karten-IDs unbekannt: " .. table.concat(badIds, ",", 1, math.min(#badIds, 12))))
  end

  -- Ereignisse
  if C_EventUtils and C_EventUtils.IsEventValid then
    local miss = {}
    for _, e in ipairs { "TRADE_SKILL_SHOW", "TRADE_SKILL_CLOSE", "SKILL_LINES_CHANGED", "BAG_UPDATE_DELAYED" } do
      if not C_EventUtils.IsEventValid(e) then miss[#miss + 1] = e end
    end
    add(#miss == 0 and ok("Ereignisse gültig") or warn("Ereignisse fehlen: " .. table.concat(miss, ", ")))
  end

  for _, l in ipairs(out) do print(l) end
  print("|cff999999Schick mir diese Zeilen, wenn etwas FEHLT.|r")
end

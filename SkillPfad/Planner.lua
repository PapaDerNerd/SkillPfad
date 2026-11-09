local ADDON, ns = ...

-- Planung ueber mehrere Berufe: Gesamtbedarf bis Skill 300 je Route, auf die Sammelberufe verteilt.
-- Daten: Plans.lua. Kuerschnerei <- Leder, Bergbau <- Schmiedekunst/Ingenieurskunst, Kraeuterkunde <- Alchemie, Angeln <- Kochen.
local PER_ANIMAL = 1.3   -- grobe Annahme: Leder je gehaeutetem Tier

ns.gatherPairs = {
  skin    = { "leder" },
  bergbau = { "schmied", "ingenieur" },
  kraeuter = { "alchemie" },
  angeln  = { "kochen" },
}

local WHERE = {
  [2318] = "Tiere Lvl 1-20", [2319] = "Tiere Lvl 20-30", [4234] = "Tiere Lvl 30-40", [4304] = "Tiere Lvl 40-50",
  [8170] = "Tiere Lvl 50-60", [783] = "Tiere Lvl 1-20", [4232] = "Tiere Lvl 20-30", [4235] = "Tiere Lvl 30-40",
  [8171] = "Tiere Lvl 50-60", [15408] = "Skorpiden in Silithus/Un'Goro",
  [14047] = "Humanoide Lvl 50-60 (AH)",
}

local function have(id)
  if C_Item and C_Item.GetItemCount then return C_Item.GetItemCount(id, true) or 0 end
  return GetItemCount and GetItemCount(id, true) or 0
end
local function nameOf(id)
  -- Nicht-deutsche Clients: Itemname aus dem Client (passt zu AH und Auctionator)
  if GetLocale and GetLocale() ~= "deDE" and ns.ClientItemName then
    local cn = ns.ClientItemName(id)
    if cn then return cn end
  end
  return (ns.itemName and ns.itemName[id]) or ("item:" .. id)
end

---------------------------------------------------------------- Routen
local function routeList(craft) return ns.plans and ns.plans[craft] end
function ns.HasRoutes(craft) local l = routeList(craft); return l and #l or 0 end

function ns.RouteOf(craft)
  local list = routeList(craft)
  if not list then return nil end
  SkillPfadDB.routes = SkillPfadDB.routes or {}
  if SkillPfadDB.route and not SkillPfadDB.routes.leder then   -- alte Einstellung uebernehmen
    SkillPfadDB.routes.leder = SkillPfadDB.route; SkillPfadDB.route = nil
  end
  local want = SkillPfadDB.routes[craft]
  for _, r in ipairs(list) do if r.id == want then return r end end
  return list[1]
end

function ns.NextRoute(craft)
  local list = routeList(craft)
  if not list then return nil end
  local cur = ns.RouteOf(craft)
  for i, r in ipairs(list) do
    if r == cur then
      SkillPfadDB.routes[craft] = list[i % #list + 1].id
      break
    end
  end
  return ns.RouteOf(craft)
end

---------------------------------------------------------------- Bedarf
function ns.PlanNeeds(craft, rank, route, target)
  local r = route or ns.RouteOf(craft)
  local need, order = {}, {}
  if not r then return need, order end
  target = target or 300
  for _, s in ipairs(r.steps) do
    local lo, hi = s[1], s[2]
    local from, to = math.max(rank, lo), math.min(hi, target)
    if to > from then
      local frac = (to - from) / (hi - lo)
      for _, m in ipairs(s[4]) do
        if m[2] > 0 then
          if not need[m[1]] then need[m[1]] = 0; order[#order + 1] = m[1] end
          need[m[1]] = need[m[1]] + math.ceil(m[2] * frac)
        end
      end
    end
  end
  return need, order
end

-- Anzahl im Beutel; Barren zaehlen verhuettbares Erz mit (Bronze: min(Kupfer, Zinn) x 2)
local function owned(id)
  local n = have(id)
  local sm = ns.smelt and ns.smelt[id]
  if sm then
    local best
    for i = 1, #sm, 2 do
      local c = have(sm[i]) * (sm.yield or 1)
      best = best and math.min(best, c) or c
    end
    n = n + (best or 0)
  end
  return n
end

local function oreHint(id, lack)
  local sm = ns.smelt and ns.smelt[id]
  if not sm then return "" end
  local parts = {}
  local y = sm.yield or 1
  for i = 1, #sm, 2 do
    parts[#parts + 1] = ns.fmt("%d %s", math.ceil(lack / y), nameOf(sm[i]))
  end
  return " = " .. table.concat(parts, " + ")
end

-- craft: Handwerksberuf; tag: nur Material dieses Sammelberufs (nil = alles)
function ns.PlanLines(craft, rank, tag, gatherRank)
  local R = ns.RouteOf(craft)
  if not R then return {} end
  local need, order = ns.PlanNeeds(craft, rank or 1)
  local L = {}
  local animals, any = 0, false
  for _, id in ipairs(order) do
    local t = ns.gatherTag and ns.gatherTag[id]
    if tag == nil or t == tag then
      any = true
      local h = owned(id)
      local lack = math.max(0, need[id] - h)
      local c = lack == 0 and "|cff00ff00" or "|cffff4040"
      local where = WHERE[id] and ("  |cff999999(" .. WHERE[id] .. ")|r") or ""
      L[#L + 1] = ns.fmt("   %s: %d nötig, %d da -> %s%d fehlen|r%s%s", nameOf(id), need[id], math.min(h, need[id]), c,
        lack, (lack > 0) and oreHint(id, lack) or "", where)
      if t == "skin" then
        animals = animals + math.ceil(lack / ((id == 15408 or id == 783 or id == 4232 or id == 4235 or id == 8171) and 1 or PER_ANIMAL))
      end
    end
  end
  if not any then return {} end
  if tag == "skin" and animals > 0 then
    L[#L + 1] = ns.fmt("   Das sind ca. |cffffd100%d|r gehäutete Tiere (Annahme: %.1f Leder je Tier).", animals, PER_ANIMAL)
  end
  return L, R
end


---------------------------------------------------------------- Routenvergleich nach Kosten
local function gold(c)
  return (GetCoinTextureString or GetMoneyString or tostring)(math.floor(c))
end

-- Kosten fuer fehlendes Material einer Route (AH-Preise); Posten ohne Preis werden gezaehlt
function ns.RouteCost(craft, route, rank)
  local need, order = ns.PlanNeeds(craft, rank, route)
  local total, noPrice, items = 0, 0, 0
  for _, id in ipairs(order) do
    local lack = math.max(0, need[id] - owned(id))
    if lack > 0 then
      items = items + 1
      local p = ns.GetPrice and ns.GetPrice(nameOf(id), id)
      if p then total = total + p * lack else noPrice = noPrice + 1 end
    end
  end
  return total, noPrice, items
end

function ns.RouteCompareLines(craft, rank)
  local list = ns.plans and ns.plans[craft]
  if not list or #list < 2 then return {} end
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  if not api and not (SkillPfadDB.prices and next(SkillPfadDB.prices)) then return {} end
  local rows, best = {}, nil
  for _, r in ipairs(list) do
    local total, noPrice, items = ns.RouteCost(craft, r, rank or 1)
    rows[#rows + 1] = { r = r, total = total, noPrice = noPrice, items = items }
  end
  -- fair vergleichen: Routen mit weniger fehlenden Preisen gelten als verlaesslicher
  for _, x in ipairs(rows) do
    if x.total > 0 and not x.r.partial and (not best or x.total < best.total) and x.noPrice <= 2 then best = x end
  end
  local out = { " ", "|cffffd100Routenvergleich nach AH-Kosten:|r" }
  for _, x in ipairs(rows) do
    local mark = (x == best) and " |cff00ff00<- günstigste|r" or ""
    local nb = x.r.partial and " |cffff8040(Quelle unvollständig)|r" or ""
    nb = nb .. (x.noPrice > 0 and ns.fmt(" |cffffff00(%d Posten ohne Preis)|r", x.noPrice) or "")
    if x.total <= 0 and x.noPrice > 0 then
      out[#out + 1] = ns.fmt("   %s: |cffffff00noch keine Preise (%d Posten)|r%s", x.r.name, x.noPrice,
        x.r.partial and " |cffff8040(Quelle unvollständig)|r" or "")
    else
      out[#out + 1] = ns.fmt("   %s: ca. %s%s%s", x.r.name, gold(x.total), nb, mark)
    end
  end
  local anyPrice = false
  for _, x in ipairs(rows) do if x.total > 0 then anyPrice = true end end
  if not anyPrice then out[#out + 1] = "|cff999999Am Auktionshaus einmal mit Auctionator scannen, dann erscheinen die Kosten.|r" end
  if best then
    local cur = ns.RouteOf(craft)
    if cur ~= best.r then
      out[#out + 1] = "|cff999999Wechseln: /sp route " .. craft .. " (Kosten sind eine Schätzung; Preise von Auctionator.)|r"
    end
  end
  return out
end


---------------------------------------------------------------- Auctionator-Einkaufsliste
local function realName(id)
  local n = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id)
  if (not n or n == "") and GetItemInfo then n = GetItemInfo(id) end
  return (n and n ~= "") and n or nameOf(id)
end

-- legt fuer das fehlende Material bis Skill 'target' eine Auctionator-Liste an
function ns.SendShoppingList(craft, rank, target)
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  if not (api and api.CreateShoppingList and api.ConvertToSearchString) then
    ns.print("|cffff4040SkillPfad:|r Auctionator mit Einkaufslisten-Schnittstelle nicht gefunden.")
    return
  end
  local need, order = ns.PlanNeeds(craft, rank or 1, nil, target)
  local terms = {}
  for _, id in ipairs(order) do
    local lack = need[id] - owned(id)
    if lack > 0 then
      local ok, str = pcall(api.ConvertToSearchString, "SkillPfad",
        { searchString = realName(id), isExact = true, quantity = lack })
      if ok and str then terms[#terms + 1] = str end
    end
  end
  if #terms == 0 then
    ns.print("|cffffd100SkillPfad:|r Es fehlt nichts bis Skill " .. target .. " – keine Liste nötig.")
    return
  end
  local name = ns.tr("SkillPfad: " .. ((ns.defs[craft] and ns.defs[craft].label) or craft))
  local ok, err = pcall(api.CreateShoppingList, "SkillPfad", name, terms)
  if ok then
    ns.print(ns.fmt("|cffffd100SkillPfad:|r Auctionator-Liste '%s' mit %d Posten (bis Skill %d) angelegt. Am Auktionshaus im Reiter 'Einkaufslisten' öffnen.", name, #terms, target))
  else
    ns.print("|cffff4040SkillPfad:|r Liste konnte nicht angelegt werden: " .. tostring(err))
  end
end

-- Buttons fuer die Wegpunkt-Liste: bis Phasenende und bis 300
function ns.ShoppingActions(craft, rank, phaseEnd)
  local out = {}
  if not (Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.CreateShoppingList) then return out end
  if not ns.RouteOf(craft) then return out end
  local label = (ns.defs[craft] and ns.defs[craft].label) or craft
  if phaseEnd and phaseEnd < 300 then
    out[#out + 1] = { text = ns.fmt("Auctionator-Liste: %s bis Skill %d", label, phaseEnd),
                      fn = function() ns.SendShoppingList(craft, rank or 1, phaseEnd) end }
  end
  out[#out + 1] = { text = ns.fmt("Auctionator-Liste: %s bis Skill 300", label),
                    fn = function() ns.SendShoppingList(craft, rank or 1, 300) end }
  return out
end

---------------------------------------------------------------- Anzeige im Sammelberuf-Tab
function ns.GatherPlanLines(key, gatherRank)
  local out = {}
  for _, craft in ipairs(ns.gatherPairs[key] or {}) do
    local def = ns.defs[craft]
    local cr = ns.RankOf and ns.RankOf(craft)
    local L, R = ns.PlanLines(craft, cr or 1, key, gatherRank)
    if R and #L > 0 then
      if #out == 0 then out[1] = " "; out[2] = "|cffffd100Planung beider Berufe:|r" end
      out[#out + 1] = ns.fmt("|cffffd100Für %s%s|r bis Skill 300 – Route: %s", def and def.label or craft,
        cr and (" (Skill " .. cr .. ")") or " (ab Skill 1)", R.name)
      out[#out + 1] = "|cff999999" .. R.note .. " Wechseln: /sp route " .. craft .. "|r"
      for _, l in ipairs(L) do out[#out + 1] = l end
      if not cr then out[#out + 1] = "   |cff999999(Öffne einmal das " .. (def and def.label or craft) .. "-Fenster, dann rechne ich ab deinem Skill.)|r" end
    end
  end
  if key == "skin" and gatherRank then
    out[#out + 1] = ns.fmt("   Dein Kürschnerskill %d reicht für Mobs bis Level ~%d (Skill = 5 x Mob-Level).",
      gatherRank, math.max(1, math.floor(gatherRank / 5)))
  end
  return out
end

-- Anzeige im Handwerks-Tab: Gesamtbedarf aller Materialien bis 300
function ns.CraftPlanLines(craft, rank)
  local L, R = ns.PlanLines(craft, rank or 1, nil)
  if not R or #L == 0 then return {} end
  local out = { " ", "|cffffd100Gesamtbedarf bis Skill 300|r – Route: " .. R.name,
                "|cff999999" .. R.note .. " Wechseln: /sp route " .. craft .. "|r" }
  for _, l in ipairs(L) do out[#out + 1] = l end
  for _, l in ipairs(ns.RouteCompareLines(craft, rank)) do out[#out + 1] = l end
  return out
end

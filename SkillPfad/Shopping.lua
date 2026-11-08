local ADDON, ns = ...

-- Einkaufsliste: Material fuer das beste Rezept bis zum Ende der aktuellen Phase bzw. bis Skill 300.
-- Schaetzung: orange = 1 Skillpunkt pro Herstellung, gelb = ca. 0,75.
local function coin(c)
  return (GetCoinTextureString or GetMoneyString or tostring)(math.floor(c))
end

local function block(r, fromSkill, toSkill, title, usePrice)
  local pts = toSkill - fromSkill
  if pts <= 0 then return nil end
  local chance = (r.type == "optimal") and 1 or 0.75
  local n = math.ceil(pts / chance)
  local L = { string.format("|cffffd100%s|r bis Skill %d: ca. %dx %s", title, toSkill, n, r.name) }
  local total, miss = 0, 0
  for _, m in ipairs(r.reag) do
    local name, rc, have, id = m[1], m[2], m[3], m[4]
    local need = rc * n
    local lack = math.max(0, need - have)
    local line = string.format("   %s: %d nötig, %d da", name, need, have)
    if lack > 0 then
      local p = ns.GetPrice and ns.GetPrice(name, id)
      if p then
        total = total + p * lack
        line = line .. string.format(" -> |cffff4040%d fehlen|r (~%s)", lack, coin(p * lack))
      else
        miss = miss + 1
        line = line .. string.format(" -> |cffff4040%d fehlen|r (Preis unbekannt)", lack)
      end
    else
      line = line .. " |cff00ff00(genug)|r"
    end
    L[#L + 1] = line
  end
  if usePrice then
    L[#L + 1] = "   Gesamt ca. |cffffd100" .. coin(total) .. "|r" .. (miss > 0 and " (ohne Posten ohne Preis)" or "")
  end
  return L
end

function ns.ShoppingLines(list, rank, ph, maxRank, usePrice)
  local r = list and list[1]
  if not r or not ph then return {} end
  local out = { " ", "|cffffd100Einkaufsliste (Schätzung für das beste Rezept):|r" }
  local phaseEnd = math.min(ph[2] - 1, maxRank > 0 and maxRank or 300)
  local b1 = block(r, rank, phaseEnd, "Phase", usePrice)
  if b1 then for _, l in ipairs(b1) do out[#out + 1] = l end end
  local top = math.min(300, maxRank > 0 and maxRank or 300)
  if top > phaseEnd then
    local b2 = block(r, rank, top, "Gesamt", usePrice)
    if b2 then
      out[#out + 1] = "|cff999999Bis " .. top .. " ist grob: spätere Phasen nutzen andere Rezepte.|r"
      out[#out + 1] = b2[1]
      if usePrice then out[#out + 1] = b2[#b2] end
    end
  end
  return out
end

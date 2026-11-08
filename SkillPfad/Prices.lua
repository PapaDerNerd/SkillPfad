local ADDON, ns = ...
SkillPfadDB = SkillPfadDB or {}
ns.seen = ns.seen or {}   -- Reagenz-Namen, die im Rezeptfenster gesehen wurden

local function store()
  SkillPfadDB.prices = SkillPfadDB.prices or {}
  return SkillPfadDB.prices
end

-- Preis in Kupfer pro Stueck, oder nil. Nutzt Auctionator falls vorhanden,
-- sonst die Werte aus dem eigenen AH-Scan.
local function itemLink(x)
  if C_Item and C_Item.GetItemInfo then
    local ok, _, link = pcall(C_Item.GetItemInfo, x)
    if ok and link then return link end
  end
  if GetItemInfo then
    local ok, _, link = pcall(GetItemInfo, x)
    if ok and link then return link end
  end
end

function ns.GetPrice(name, id)
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  if api then
    if id and type(id) == "number" and api.GetAuctionPriceByItemID then
      local ok, p = pcall(api.GetAuctionPriceByItemID, "SkillPfad", id)
      if ok and p and p > 0 then return p end
    end
    if api.GetAuctionPriceByItemLink then
      local link = itemLink(id or name)
      if link then
        local ok, p = pcall(api.GetAuctionPriceByItemLink, "SkillPfad", link)
        if ok and p and p > 0 then return p end
      end
    end
  end
  local e = store()[name]
  return e and e.p or nil
end

function ns.PriceAge(name)
  local e = store()[name]
  return e and e.t or nil
end

------------------------------------------------------------ eigener AH-Scan
local queue, current, waiting = {}, nil, false
local scanning = false
local ev = CreateFrame("Frame")

local function finish()
  scanning, waiting, current = false, false, nil
  print("|cffffd100SkillPfad:|r Preisscan fertig.")
  if ns.Refresh then ns.Refresh() end
end

function ns.StartScan()
  if not (CanSendAuctionQuery and QueryAuctionItems) then
    print("|cffffd100SkillPfad:|r Eigener AH-Scan wird von diesem Client nicht unterstuetzt. Nutze Auctionator (Preise werden automatisch uebernommen).")
    return
  end
  if not (AuctionFrame and AuctionFrame:IsShown()) then
    print("|cffffd100SkillPfad:|r Öffne zuerst das Auktionshaus.")
    return
  end
  queue = {}
  for name, id in pairs(ns.seen) do
    -- Haendlerware (Faeden, Salz ...) nicht im AH scannen
    if ns.WeightOf(type(id) == "number" and id or nil) >= 1 then queue[#queue + 1] = name end
  end
  if #queue == 0 then
    print("|cffffd100SkillPfad:|r Öffne erst das Lederverarbeitung-Fenster, damit ich die Materialien kenne.")
    return
  end
  scanning, waiting = true, true
  print(string.format("|cffffd100SkillPfad:|r Scanne %d Materialien ...", #queue))
end

ev:SetScript("OnUpdate", function()
  if not (scanning and waiting) then return end
  if not (AuctionFrame and AuctionFrame:IsShown()) then
    scanning = false; print("|cffffd100SkillPfad:|r Scan abgebrochen (AH geschlossen)."); return
  end
  if CanSendAuctionQuery() then
    if #queue == 0 then finish(); return end
    waiting = false
    current = table.remove(queue, 1)
    QueryAuctionItems(current, nil, nil, 0, false, 0, false, true)
  end
end)

ns.Reg(ev, "AUCTION_ITEM_LIST_UPDATE")
ev:SetScript("OnEvent", function()
  if not (scanning and current) then return end
  local best
  for i = 1, GetNumAuctionItems("list") do
    local nm, _, count, _, _, _, _, _, _, buyout = GetAuctionItemInfo("list", i)
    if nm == current and buyout and buyout > 0 and count and count > 0 then
      local unit = buyout / count
      if not best or unit < best then best = unit end
    end
  end
  if best then store()[current] = { p = math.floor(best), t = time() } end
  current = nil
  waiting = true
end)

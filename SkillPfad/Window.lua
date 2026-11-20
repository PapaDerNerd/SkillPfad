local ADDON, ns = ...
local CreateFrame = ns.CreateFrame  -- uebersetzt Texte je nach Sprache
SkillPfadDB = SkillPfadDB or {}

local DEFAULTS = { price = false, autoShow = true, topN = 3, scale = 1, locked = false, minimapShow = true,
  lookSize = 13, lookSpacing = 2, lookTheme = "leder", lookText = "creme", lookAlpha = 100 }
ns.tabRefresh = {}
local lines = {
  leder = { "Öffne dein Lederverarbeitung-Fenster für Empfehlungen." },
  kochen = { "Öffne dein Koch-Fenster für Empfehlungen." },
  ersthilfe = { "Öffne dein Erste-Hilfe-Fenster für Empfehlungen." },
  skin  = { "..." },
}
local current = "leder"
local loading = false


------------------------------------------------------------ Grafiken (alle aus dem Spiel)
local ICON = {
  leder = "Trade_LeatherWorking", skin = "INV_Misc_Pelt_Wolf_01", kochen = "INV_Misc_Food_15",
  ersthilfe = "Spell_Holy_SealOfSacrifice", alchemie = "Trade_Alchemy", schmied = "Trade_BlackSmithing",
  ingenieur = "Trade_Engineering", schneider = "Trade_Tailoring", verzauber = "Trade_Engraving",
  bergbau = "Trade_Mining", kraeuter = "Trade_Herbalism", angeln = "Trade_Fishing",
  opt = "INV_Misc_Gear_01",
}
local function iconPath(key) return "Interface\\Icons\\" .. (ICON[key] or "INV_Misc_QuestionMark") end
local FLAT = "Interface\\Buttons\\WHITE8X8"
local BODY = CreateFont("SkillPfadBody")     -- Kartentext
BODY:SetFont(STANDARD_TEXT_FONT, 13, "")
BODY:SetTextColor(0.94, 0.92, 0.86)
BODY:SetSpacing(2)
local HEAD = CreateFont("SkillPfadHead")     -- Abschnittstitel
HEAD:SetFont(STANDARD_TEXT_FONT, 14, "")
local INFO = CreateFont("SkillPfadInfo")     -- Kurzinfo rechts im Abschnittskopf
INFO:SetFont(STANDARD_TEXT_FONT, 11, ""); INFO:SetTextColor(0.6, 0.6, 0.6)
local TAB = CreateFont("SkillPfadTab")       -- Seitenleiste
TAB:SetFont(STANDARD_TEXT_FONT, 13, "")

-- Optik: Farbschemata (Hintergruende) und Textfarben, in den Optionen waehlbar
local THEMES = {
  leder = { name = "Farbschema: Leder (Standard)", card = { 0.11, 0.09, 0.07 }, now = { 0.16, 0.12, 0.05 },
            pane = { 0.055, 0.045, 0.035 }, side = { 0.03, 0.025, 0.02 } },
  dunkel = { name = "Farbschema: Dunkel", card = { 0.07, 0.07, 0.07 }, now = { 0.11, 0.10, 0.05 },
            pane = { 0.02, 0.02, 0.02 }, side = { 0.01, 0.01, 0.01 } },
  blau  = { name = "Farbschema: Nachtblau", card = { 0.06, 0.08, 0.14 }, now = { 0.11, 0.12, 0.17 },
            pane = { 0.03, 0.04, 0.08 }, side = { 0.02, 0.03, 0.06 } },
  wald  = { name = "Farbschema: Wald", card = { 0.07, 0.10, 0.07 }, now = { 0.12, 0.13, 0.06 },
            pane = { 0.03, 0.05, 0.03 }, side = { 0.02, 0.035, 0.02 } },
}
local THEME_ORDER = { "leder", "dunkel", "blau", "wald" }
local TEXTC = {
  creme = { name = "Textfarbe: Creme (Standard)", 0.94, 0.92, 0.86 },
  weiss = { name = "Textfarbe: Weiß", 1, 1, 1 },
  grau  = { name = "Textfarbe: Hellgrau", 0.78, 0.78, 0.78 },
  gold  = { name = "Textfarbe: Gold", 1, 0.86, 0.55 },
}
local TEXT_ORDER = { "creme", "weiss", "grau", "gold" }
local function theme() return THEMES[SkillPfadDB.lookTheme] or THEMES.leder end
local function lookAlpha() return math.max(0.3, math.min(1, (tonumber(SkillPfadDB.lookAlpha) or 100) / 100)) end
local function headH() return math.max(22, (tonumber(SkillPfadDB.lookSize) or 13) + 10) end
local PANEL = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 14,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

------------------------------------------------------------ Hauptfenster
local f = CreateFrame("Frame", "SkillPfadWindow", UIParent, "BackdropTemplate")
local DEF_W, DEF_H = 860, 660
f:SetSize(DEF_W, DEF_H)
f:SetResizable(true)
if f.SetResizeBounds then f:SetResizeBounds(760, 600, 1600, 1200)
elseif f.SetMinResize then f:SetMinResize(760, 600); f:SetMaxResize(1600, 1200) end
f:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 32, edgeSize = 32,
  insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
f:SetClampedToScreen(true); f:SetFrameStrata("HIGH")
f:SetScript("OnDragStart", function(s)
  if SkillPfadDB.locked then return end
  s:StartMoving()
  s:SetScript("OnUpdate", function() if ns.UpdateOpenBtn then ns.UpdateOpenBtn(ns.CurrentTab()) end end)
end)
f:SetScript("OnDragStop", function(s)
  s:StopMovingOrSizing()
  s:SetScript("OnUpdate", nil)
  local p, _, rp, x, y = s:GetPoint()
  SkillPfadDB.pos = { p, rp, x, y }
  if ns.UpdateOpenBtn then ns.UpdateOpenBtn(ns.CurrentTab()) end
end)
f:SetScript("OnHide", function() if ns.UpdateOpenBtn then ns.UpdateOpenBtn(nil) end end)
f:Hide()
tinsert(UISpecialFrames, "SkillPfadWindow")   -- ESC schliesst

-- Titelplakette wie bei Blizzard-Dialogen
local header = f:CreateTexture(nil, "ARTWORK")
header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
header:SetSize(300, 64); header:SetPoint("TOP", 0, 12)
local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", header, "TOP", 0, -14); title:SetText("SkillPfad")
local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -4, -4)

-- Ziehgriff unten rechts: Fenstergroesse mit der Maus aendern
local grip = CreateFrame("Button", nil, f)
grip:SetSize(16, 16); grip:SetPoint("BOTTOMRIGHT", -8, 8); grip:SetFrameLevel((tonumber(f:GetFrameLevel()) or 1) + 20)
grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
grip:SetScript("OnMouseDown", function() if not SkillPfadDB.locked then f:StartSizing("BOTTOMRIGHT") end end)
grip:SetScript("OnMouseUp", function()
  f:StopMovingOrSizing()
  SkillPfadDB.size = { math.floor(f:GetWidth() + 0.5), math.floor(f:GetHeight() + 0.5) }
  local p, _, rp, x, y = f:GetPoint()
  SkillPfadDB.pos = { p, rp, x, y }
  if ns.UpdateOpenBtn then ns.UpdateOpenBtn(ns.CurrentTab()) end
end)

-- Seitenleiste (Berufe)
local side = CreateFrame("Frame", nil, f, "BackdropTemplate")
side:SetBackdrop(PANEL); side:SetBackdropColor(0.03, 0.025, 0.02, 0.97)
side:SetBackdropBorderColor(0.8, 0.7, 0.4, 1)
side:SetPoint("TOPLEFT", 16, -44); side:SetPoint("BOTTOMLEFT", 16, 16); side:SetWidth(186)

-- Inhaltsfläche
local pane = CreateFrame("Frame", nil, f, "BackdropTemplate")
pane:SetBackdrop(PANEL); pane:SetBackdropColor(0.055, 0.045, 0.035, 0.98)
pane:SetBackdropBorderColor(0.8, 0.7, 0.4, 1)
pane:SetPoint("TOPLEFT", side, "TOPRIGHT", 6, 0)
pane:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 16)

local hIcon = pane:CreateTexture(nil, "ARTWORK")
hIcon:SetSize(36, 36); hIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93); hIcon:SetPoint("TOPLEFT", 10, -10)
local hFrame = pane:CreateTexture(nil, "OVERLAY")        -- goldener Iconrahmen
hFrame:SetTexture("Interface\\Buttons\\UI-Quickslot2")
hFrame:SetSize(64, 64); hFrame:SetPoint("CENTER", hIcon, "CENTER", 0, -1)
local hTitle = pane:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
hTitle:SetPoint("TOPLEFT", hIcon, "TOPRIGHT", 12, -1)
local hSub = pane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")   -- aktuelle Phase
hSub:SetPoint("TOPLEFT", hTitle, "BOTTOMLEFT", 0, -4); hSub:SetWidth(265); hSub:SetJustifyH("LEFT")
if hSub.SetWordWrap then hSub:SetWordWrap(false) end
local hLine = pane:CreateTexture(nil, "ARTWORK")
hLine:SetTexture(FLAT)
hLine:SetVertexColor(0.8, 0.65, 0.2, 0.7)
hLine:SetHeight(1); hLine:SetPoint("TOPLEFT", 8, -58); hLine:SetPoint("TOPRIGHT", -8, -58)

-- Skillbalken (wie die Berufsleiste im Spiel)
local bar = CreateFrame("StatusBar", nil, pane, "BackdropTemplate")
bar:SetSize(150, 16); bar:SetPoint("TOPRIGHT", -14, -12)
bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
bar:SetMinMaxValues(0, 300)
bar:SetBackdrop({ bgFile = FLAT, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10,
  insets = { left = 2, right = 2, top = 2, bottom = 2 } })
bar:SetBackdropColor(0, 0, 0, 0.8); bar:SetBackdropBorderColor(0.7, 0.6, 0.3, 1)
local barText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
barText:SetPoint("CENTER")
bar:Hide()

-- Knopf: Berufsfenster oeffnen (Zauber wirken ist geschuetzt, daher ein sicherer Knopf)
-- Der Knopf haengt absichtlich NICHT am Fenster: ein geschuetzter Knopf als Kind (oder verankert) wuerde das
-- ganze Fenster schuetzen, es liesse sich im Kampf dann nicht oeffnen, schliessen oder verschieben.
-- Er liegt deshalb auf UIParent und wird ausserhalb des Kampfes an die passende Stelle gesetzt.
local openBtn = CreateFrame("Button", "SkillPfadOpenProf", UIParent, "SecureActionButtonTemplate,UIPanelButtonTemplate")
openBtn:SetSize(104, 22)
openBtn:SetFrameStrata("HIGH"); openBtn:SetFrameLevel(50)
openBtn:SetText("Beruf öffnen")
openBtn:SetAttribute("type", "spell")
openBtn:RegisterForClicks("AnyUp", "AnyDown")
openBtn:Hide()
local function updateOpenBtn(key)
  if InCombatLockdown and InCombatLockdown() then return end   -- im Kampf nicht anfassen
  local d = key and ns.defs[key]
  local r, t = pane:GetRight(), pane:GetTop()
  if f:IsShown() and r and t and d and not d.gather and not (ns.TradeFrameShown and ns.TradeFrameShown()) then
    openBtn:SetScale(f:GetScale())
    openBtn:ClearAllPoints()
    openBtn:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", r - 14, t - 32)
    openBtn:SetAttribute("spell", ns.SpellName and ns.SpellName(key) or d.label)
    openBtn:Show()
  else
    openBtn:Hide()
  end
end
ns.UpdateOpenBtn = updateOpenBtn

-- Textbereich (scrollbar) mit Karten je Abschnitt
local sf = CreateFrame("ScrollFrame", "SkillPfadScroll", pane, "UIPanelScrollFrameTemplate")
sf:SetPoint("TOPLEFT", 10, -66); sf:SetPoint("BOTTOMRIGHT", -30, 10)
local child = CreateFrame("Frame", nil, sf)
local CW = 450      -- Kartenbreite, passt sich der Fenstergroesse an
child:SetSize(CW, 10); sf:SetScrollChild(child)
local cards = {}

-- Einstellungen
local opt = CreateFrame("Frame", nil, pane)
opt:SetPoint("TOPLEFT", 14, -64); opt:SetPoint("BOTTOMRIGHT", -14, 10)
opt:Hide()
-- Zweite Optionsseite: Optik
local look = CreateFrame("Frame", nil, pane)
look:SetPoint("TOPLEFT", 14, -64); look:SetPoint("BOTTOMRIGHT", -14, 10)
look:Hide()
local lookPage = false

------------------------------------------------------------ Tabs
local tabBtn = {}

local actions = {}      -- Tab -> Liste von { text, fn, sec } (Wegpunkt-Buttons; sec = Abschnitt, in dem der Knopf steht)

-- Abschnitte: eine Zeile "##schluessel|Titel|Info" beginnt eine Karte, die sich einklappen laesst
local SEC = {
  now   = { 1.00, 0.82, 0.00, fixed = true },
  warn  = { 0.95, 0.30, 0.22, open = true },
  alt   = { 0.90, 0.75, 0.25, open = true },
  tips  = { 0.70, 0.65, 0.55 },
  gunst = { 0.95, 0.60, 0.20 },
  quest = { 0.35, 0.62, 0.98 },
  shop  = { 0.40, 0.82, 0.40 },
  need  = { 0.40, 0.82, 0.40 },
  plan  = { 0.75, 0.50, 0.95 },
  weg   = { 0.80, 0.68, 0.40 },
  way   = { 0.30, 0.80, 0.80, open = true },
}
local ACCENT = {   -- Karten ohne Abschnittskopf
  { "Wichtig", 0.95, 0.30, 0.22 }, { "Berufsquests", 0.35, 0.62, 0.98 },
  { "Einkaufsliste", 0.40, 0.82, 0.40 }, { "Gesamtbedarf", 0.40, 0.82, 0.40 }, { "Planung", 0.75, 0.50, 0.95 },
}
local PLUS, MINUS = "Interface\\Buttons\\UI-PlusButton-Up", "Interface\\Buttons\\UI-MinusButton-Up"
local ARROW = "Interface\\ChatFrame\\ChatFrameExpandArrow"

local function isOpen(key)
  local s = SEC[key]
  if not s or s.fixed then return true end
  local fo = SkillPfadDB.fold and SkillPfadDB.fold[current .. ":" .. key]
  if fo == nil then return s.open and true or false end
  return fo
end

local render
local function toggle(key)
  SkillPfadDB.fold = SkillPfadDB.fold or {}
  SkillPfadDB.fold[current .. ":" .. key] = not isOpen(key)
  render()
end

local function card(i)
  local c = cards[i]
  if not c then
    c = CreateFrame("Frame", nil, child, "BackdropTemplate")
    c:SetBackdrop({ bgFile = FLAT, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10,
      insets = { left = 2, right = 2, top = 2, bottom = 2 } })
    c.accent = c:CreateTexture(nil, "ARTWORK"); c.accent:SetTexture(FLAT)
    c.accent:SetPoint("TOPLEFT", 3, -3); c.accent:SetPoint("BOTTOMLEFT", 3, 3); c.accent:SetWidth(4)
    c.text = c:CreateFontString(nil, "OVERLAY", "SkillPfadBody")
    c.text:SetPoint("TOPLEFT", 16, -10); c.text:SetWidth(CW - 32)
    c.text:SetJustifyH("LEFT"); c.text:SetJustifyV("TOP")
    -- Kopfzeile zum Ein-/Ausklappen
    local hd = CreateFrame("Button", nil, c)
    hd:SetHeight(22); hd:SetPoint("TOPLEFT", 10, -4); hd:SetPoint("TOPRIGHT", -6, -4)
    hd:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2", "ADD")
    hd:SetScript("OnClick", function(self) if self.key then toggle(self.key) end end)
    c.chev = hd:CreateTexture(nil, "ARTWORK"); c.chev:SetSize(14, 14); c.chev:SetPoint("LEFT", 2, 0)
    c.title = hd:CreateFontString(nil, "OVERLAY", "SkillPfadHead")
    c.title:SetPoint("LEFT", 22, 0); c.title:SetJustifyH("LEFT")
    c.info = hd:CreateFontString(nil, "OVERLAY", "SkillPfadInfo")
    c.info:SetPoint("RIGHT", -4, 0); c.info:SetPoint("LEFT", c.title, "RIGHT", 10, 0)
    c.info:SetJustifyH("RIGHT")
    if c.info.SetWordWrap then c.info:SetWordWrap(false) end
    c.head = hd; c.segs = {}; c.btns = {}
    cards[i] = c
  end
  return c
end

-- TomTom-Knoepfe innerhalb einer Karte
local function cardButton(c, j)
  local b = c.btns[j]
  if not b then
    b = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    b:SetHeight(22)
    b:SetScript("OnClick", function(self)
      local a = (actions[current] or {})[self.ai]
      if a and a.fn then a.fn() end
    end)
    c.btns[j] = b
  end
  return b
end

-- Balken "Der ganze Weg": ein Stueck je Phase
local function seg(c, j)
  local t = c.segs[j]
  if not t then
    t = c:CreateTexture(nil, "ARTWORK"); t:SetTexture(FLAT); t:SetHeight(6)
    c.segs[j] = t
  end
  return t
end

local function blocksOf(list)
  local blocks, cur = {}, {}
  for _, ln in ipairs(list) do
    if ln == " " or ln == "" then
      if #cur > 0 then blocks[#blocks + 1] = cur; cur = {} end
    else cur[#cur + 1] = ln end
  end
  if #cur > 0 then blocks[#blocks + 1] = cur end
  return blocks
end

render = function()
  updateOpenBtn(current)
  hIcon:SetTexture(iconPath(current))
  hTitle:SetText(current == "opt" and "Optionen" or (ns.defs[current] and ns.defs[current].label) or "")
  -- Skillbalken und Phase
  local rank = (current ~= "opt" and ns.RankOf) and ns.RankOf(current) or nil
  if rank then
    local mx = tonumber(SkillPfadDB.maxRanks and SkillPfadDB.maxRanks[current]) or 300
    if mx < rank or mx <= 0 then mx = 300 end
    bar:SetMinMaxValues(0, mx); bar:SetValue(rank); barText:SetText(rank .. " / " .. mx)
    bar:SetStatusBarColor(rank >= 300 and 0.2 or 0.85, rank >= 300 and 0.8 or 0.65, 0.1)
    bar:Show()
  else bar:Hide() end
  local ph = rank and ns.defs[current] and ns.phaseFor and ns.phaseFor(current, rank)
  if ph then
    hSub:SetText(ns.fmt("Phase: |cff00ff00%s|r  (%d-%d)", ph[3], ph[1], math.min(ph[2], 300))); hSub:Show()
  else hSub:SetText(""); hSub:Hide() end
  if current == "opt" then
    sf:Hide()
    if lookPage then opt:Hide(); look:Show() else look:Hide(); opt:Show() end
    ns.UpdateOptions()
  else
    opt:Hide(); look:Hide(); sf:Show()
    for _, c in ipairs(cards) do c:Hide() end
    local sw = sf:GetWidth()
    if type(sw) == "number" and sw > 300 then CW = math.floor(sw) end
    child:SetWidth(CW)
    local acts = actions[current] or {}
    local blocks = blocksOf(lines[current] or {})
    local present, secActs, rest = {}, {}, {}
    for _, blk in ipairs(blocks) do
      local k = blk[1]:match("^##([%w_]+)|")
      if k then present[k] = true end
    end
    for i, a in ipairs(acts) do
      if a.sec and present[a.sec] then
        secActs[a.sec] = secActs[a.sec] or {}
        table.insert(secActs[a.sec], i)
      elseif not a.only then
        rest[#rest + 1] = i
      end
    end
    if #rest > 0 then blocks[#blocks + 1] = { "##way|Wegpunkte (TomTom)|" }; secActs.way = rest end
    local y = 2
    for i, blk in ipairs(blocks) do
      local c = card(i)
      for _, bt in ipairs(c.btns) do bt:Hide() end
      for _, t in ipairs(c.segs) do t:Hide() end
      local key, ttl, info = blk[1]:match("^##([%w_]+)|([^|]*)|?(.*)$")
      local body = {}
      for j = key and 2 or 1, #blk do body[#body + 1] = blk[j] end
      local txt = table.concat(body, "\n")
      local r, g, b = 0.90, 0.75, 0.25
      if key and SEC[key] then r, g, b = SEC[key][1], SEC[key][2], SEC[key][3]
      elseif not key then
        for _, a in ipairs(ACCENT) do if txt:find(a[1], 1, true) then r, g, b = a[2], a[3], a[4]; break end end
      end
      local open = (not key) or isOpen(key)
      local top = 10
      if key then
        local foldable = not (SEC[key] and SEC[key].fixed)
        c.head.key = foldable and key or nil
        c.head:EnableMouse(foldable)
        if foldable then c.chev:SetTexture(open and MINUS or PLUS); c.chev:SetVertexColor(1, 1, 1)
        else c.chev:SetTexture(ARROW); c.chev:SetVertexColor(1, 0.82, 0) end
        c.chev:Show()
        c.head:SetHeight(headH())
        c.title:SetFontObject(HEAD); c.title:SetText(ttl); c.title:SetTextColor(r, g, b)
        c.info:SetFontObject(INFO); c.info:SetText(info or "")
        c.head:Show()
        top = headH() + 8
      else
        c.head:Hide()
      end
      -- Phasenbalken
      if open and key == "weg" then
        local def = ns.defs[current]
        local W, x = CW - 34, 0
        for j, p in ipairs(def and def.phases or {}) do
          local a1, a2 = p[1], math.min(p[2], 300)
          local w = math.max(2, (a2 - a1) / 300 * W - 2)
          local t = seg(c, j)
          t:ClearAllPoints(); t:SetPoint("TOPLEFT", c, "TOPLEFT", 16 + x, -top); t:SetWidth(w)
          if rank and rank >= a2 then t:SetVertexColor(0.30, 0.55, 0.25, 1)
          elseif rank and rank >= a1 then t:SetVertexColor(0.95, 0.75, 0.15, 1)
          else t:SetVertexColor(0.25, 0.21, 0.15, 1) end
          t:Show()
          x = x + w + 2
        end
        top = top + 14
      end
      local h = top
      if open and txt ~= "" then
        c.text:ClearAllPoints(); c.text:SetPoint("TOPLEFT", key and 14 or 16, -top)
        c.text:SetWidth(CW - 32)
        c.text:SetFontObject(BODY); c.text:SetText(txt); c.text:Show()
        h = h + c.text:GetStringHeight() + (key and 8 or 12)
      else
        c.text:SetText(""); c.text:Hide()
      end
      local list = (open and key and secActs[key]) or {}
      for j, ai in ipairs(list) do
        local bt = cardButton(c, j)
        bt.ai = ai
        bt:ClearAllPoints(); bt:SetPoint("TOPLEFT", c, "TOPLEFT", 14, -h); bt:SetWidth(CW - 30)
        bt:SetText(acts[ai].text); bt:Show()
        h = h + 24
      end
      if #list > 0 then h = h + 4 end
      if key and not open then h = headH() + 8 end
      c.accent:SetVertexColor(r, g, b, 1)
      if key then c.accent:Hide() else c.accent:Show() end   -- Abschnitte: farbiger Rahmen statt Balken
      local th, al = theme(), lookAlpha()
      if key == "now" then
        c:SetBackdropColor(th.now[1], th.now[2], th.now[3], al)
        c:SetBackdropBorderColor(r, g, b, 1)
      else
        c:SetBackdropColor(th.card[1], th.card[2], th.card[3], al)
        c:SetBackdropBorderColor(r * 0.7, g * 0.7, b * 0.7, 0.9)
      end
      c:ClearAllPoints(); c:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -y); c:SetSize(CW, h)
      c:Show()
      y = y + h + 6
    end
    child:SetHeight(y + 10)
  end
  for key, b in pairs(tabBtn) do
    if key == current then b.sel:Show(); b.label:SetTextColor(1, 1, 1)
    else b.sel:Hide(); b.label:SetTextColor(1, 0.82, 0) end
    if b.rank then
      local r2 = (key ~= "opt" and ns.RankOf) and ns.RankOf(key) or nil
      b.rank:SetText(r2 and tostring(r2) or "")
    end
  end
end

function ns.Enabled(key)
  return key == "opt" or not (SkillPfadDB.off and SkillPfadDB.off[key])
end

local keys = {}
local function layoutTabs()
  local n = 0
  for _, key in ipairs(keys) do
    local b = tabBtn[key]
    if b then
      if ns.Enabled(key) then
        local gap = (key == "opt") and 10 or 0    -- Optionen etwas abgesetzt
        b:ClearAllPoints(); b:SetPoint("TOPLEFT", 7, -8 - n * 38 - gap); b:Show(); n = n + 1
      else b:Hide() end
    end
  end
end
ns.LayoutTabs = layoutTabs

local function showTab(key)
  if not ns.Enabled(key) then
    key = "opt"
    for _, k in ipairs(ns.order) do if ns.Enabled(k) then key = k; break end end
  end
  current = key
  if key ~= "opt" then lookPage = false end
  if ns.tabRefresh[key] then ns.tabRefresh[key]() end
  render()
end

for _, k in ipairs(ns.order) do keys[#keys + 1] = k end
keys[#keys + 1] = "opt"
for i, key in ipairs(keys) do
  local b = CreateFrame("Button", nil, side)
  b:SetSize(172, 36)
  b:SetPoint("TOPLEFT", 7, -8 - (i - 1) * 38)
  local sel = b:CreateTexture(nil, "BACKGROUND")           -- gewählt: goldener Balken
  sel:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
  sel:SetBlendMode("ADD"); sel:SetAllPoints(); sel:Hide()
  b.sel = sel
  b:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2", "ADD")
  local ic = b:CreateTexture(nil, "ARTWORK")
  ic:SetSize(24, 24); ic:SetPoint("LEFT", 3, 0); ic:SetTexture(iconPath(key))
  ic:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  local lb = b:CreateFontString(nil, "OVERLAY", "SkillPfadTab")
  lb:SetPoint("LEFT", ic, "RIGHT", 7, 0); lb:SetJustifyH("LEFT")
  lb:SetText(key == "opt" and "Optionen" or ns.defs[key].label)
  b.label = lb
  local rk = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  rk:SetPoint("RIGHT", -6, 0); rk:SetTextColor(0.6, 0.85, 0.6)
  b.rank = rk
  b:SetScript("OnClick", function() showTab(key) end)
  tabBtn[key] = b
end
layoutTabs()


------------------------------------------------------------ Schnittstelle
-- Neu gezeichnet wird nur, wenn sich der Inhalt wirklich geaendert hat (spart Rechenzeit beim Dauer-Scan)
local lineSig, actSig = {}, {}
function ns.SetActions(tab, list)
  local t = {}
  for i, a in ipairs(list) do t[i] = (a.sec or "") .. ":" .. a.text end
  local sig = table.concat(t, "\n")
  local same = (actSig[tab] == sig)
  actSig[tab] = sig
  actions[tab] = list
  -- Knoepfe holen ihre Funktion beim Klick aus actions, bei gleichem Inhalt reicht das Ersetzen der Liste
  if not same and f:IsShown() and current == tab then render() end
end

function ns.SetLines(tab, l)
  local sig = table.concat(l, "\n")
  local same = (lineSig[tab] == sig)
  lineSig[tab] = sig
  lines[tab] = l
  if not same and f:IsShown() and current == tab then render() end
end

function ns.PlaceWindow()
  f:ClearAllPoints()
  local p = SkillPfadDB.pos
  if p then
    f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
  elseif TradeSkillFrame and TradeSkillFrame:IsShown() then
    f:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 0, 0)
  else
    f:SetPoint("CENTER")
  end
end

function ns.OpenWindow(tab, auto)
  if not f:IsShown() then ns.PlaceWindow() end
  ns.autoOpened = auto and true or false
  f:Show()
  showTab(tab or current)
end

function ns.CloseWindow() f:Hide() end
function ns.WindowShown() return f:IsShown() end
function ns.CurrentTab() return current end
function ns.ResetPos()
  SkillPfadDB.pos = nil; SkillPfadDB.size = nil
  f:SetSize(DEF_W, DEF_H)
  if f:IsShown() then ns.PlaceWindow(); updateOpenBtn(current); render() end
end
f:SetScript("OnSizeChanged", function() if f:IsShown() and current ~= "opt" then render() end end)

------------------------------------------------------------ Einstellungen: Steuerelemente
local controls = {}
local P = opt        -- Elternrahmen fuer die folgenden Steuerelemente

local COL2 = 360     -- rechte Spalte

-- Gruppenueberschrift mit Linie
local function head(text, x, y, w)
  local t = P:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t:SetPoint("TOPLEFT", x, y); t:SetText(text)
  local ln = P:CreateTexture(nil, "ARTWORK"); ln:SetTexture(FLAT); ln:SetVertexColor(0.8, 0.65, 0.2, 0.5)
  ln:SetHeight(1); ln:SetWidth(w or 300); ln:SetPoint("TOPLEFT", x, y - 16)
  return t
end

local function check(name, label, key, x, y, onChange)
  local c = CreateFrame("CheckButton", "SkillPfadChk" .. name, P, "UICheckButtonTemplate")
  c:SetPoint("TOPLEFT", x, y)
  local t = ns.WrapObj(_G[c:GetName() .. "Text"])
  t:SetText(label); t:SetWidth(290); t:SetJustifyH("LEFT")
  c:SetScript("OnClick", function(self)
    SkillPfadDB[key] = self:GetChecked() and true or false
    if onChange then onChange() end
  end)
  controls[#controls + 1] = { c, key }
end

local function slider(name, label, key, x, y, minV, maxV, step, fmt, onChange)
  local sname = "SkillPfadSlider" .. name
  local s = CreateFrame("Slider", sname, P, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", x + 8, y); s:SetWidth(280)
  s:SetMinMaxValues(minV, maxV); s:SetValueStep(step)
  if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
  ns.WrapObj(_G[sname .. "Text"])
  _G[sname .. "Low"]:SetText(tostring(minV))
  _G[sname .. "High"]:SetText(tostring(maxV))
  s:SetScript("OnValueChanged", function(self, v)
    v = math.floor(v / step + 0.5) * step
    _G[sname .. "Text"]:SetText(label .. ": " .. ns.fmt(fmt, v))
    if loading then return end
    SkillPfadDB[key] = v
    if onChange then onChange(v) end
  end)
  controls[#controls + 1] = { s, key, true }
end

local function button(label, x, y, w, onClick)
  local b = CreateFrame("Button", nil, P, "UIPanelButtonTemplate")
  b:SetSize(w or 296, 24); b:SetPoint("TOPLEFT", x, y)
  b:SetText(label); b:SetScript("OnClick", onClick)
  return b
end

-- Linke Spalte: Anzeige und Verhalten
head("Anzeige und Verhalten", 0, 0, 320)
check("Price", "Nach AH-Preisen sortieren (statt Farm-Aufwand)", "price", 0, -22,
  function() if ns.Refresh then ns.Refresh() end end)
check("Auto",  "Fenster automatisch beim Beruf öffnen", "autoShow", 0, -50)
check("Lock",  "Fenster sperren (nicht verschiebbar)", "locked", 0, -78)
check("Mini",  "Knopf an der Minimap anzeigen", "minimapShow", 0, -106,
  function() if ns.UpdateMinimapButton then ns.UpdateMinimapButton() end end)
check("Way",   "Wegpunkte per TomTom-Befehl /way setzen (falls sie falsch sitzen)", "wayMode", 0, -134)

-- Linke Spalte: Fenster und Inhalt
head("Fenster und Inhalt", 0, -182, 320)
slider("TopN",  "Angezeigte Rezepte", "topN", 0, -222, 1, 5, 1, "%d",
  function() if ns.Refresh then ns.Refresh() end end)
slider("Scale", "Skalierung", "scale", 0, -272, 0.7, 1.3, 0.05, "%.2f",
  function(v) f:SetScale(v); if ns.UpdateOpenBtn then ns.UpdateOpenBtn(ns.CurrentTab()) end end)
button("Fenster zurücksetzen (Position und Größe)", 0, -306, 320, function() ns.ResetPos() end)

-- Linke Spalte: Route, Sprache und Preise
head("Route, Sprache und Preise", 0, -346, 320)
function ns.RefreshAll()
  for _, fn in pairs(ns.tabRefresh) do pcall(fn) end
end
local routeBtn
local function routeKey()
  local k = ns.CurrentTab and ns.CurrentTab()
  local map = { skin = "leder", bergbau = "schmied", kraeuter = "alchemie", angeln = "kochen" }
  k = map[k] or k
  if k and ns.HasRoutes and ns.HasRoutes(k) > 1 then return k end
  return "leder"
end
local function routeText()
  local k = routeKey()
  local r = ns.RouteOf and ns.RouteOf(k)
  return "Route " .. ((ns.defs[k] and ns.defs[k].label) or k) .. ": " .. (r and r.name or "?")
end
routeBtn = button("Route", 0, -368, 320, function()
  ns.NextRoute(routeKey()); routeBtn:SetText(routeText())
  if ns.RefreshAll then ns.RefreshAll() end
end)

-- Sprache: Auto (nach Client) -> Deutsch -> English
local langBtn
local function langText()
  local l = SkillPfadDB and SkillPfadDB.lang
  local cur = (l == "de" and "Deutsch") or (l == "en" and "English") or ("Auto (" .. (ns.lang == "en" and "English" or "Deutsch") .. ")")
  return "Sprache / Language: " .. cur
end
langBtn = button("Sprache / Language", 0, -396, 320, function()
  local l = SkillPfadDB.lang
  local nxt = (l == nil and "de") or (l == "de" and "en") or nil
  ns.SetLang(nxt)
  langBtn:SetText(langText())
  if ns.UpdateOptions then ns.UpdateOptions() end
end)
local scanBtn = button("AH-Preise scannen (AH muss offen sein)", 0, -424, 320, function() ns.StartScan() end)
if not (CanSendAuctionQuery and QueryAuctionItems) then
  scanBtn:SetText("Preise: über Auctionator (Liste am AH suchen)")
  scanBtn:Disable()
end
button("Gespeicherte Preise löschen", 0, -452, 320, function()
  SkillPfadDB.prices = {}; ns.UpdateOptions()
  if ns.Refresh then ns.Refresh() end
end)

-- Rechte Spalte: Berufe ein-/ausschalten
local profChecks = {}
head("Berufe anzeigen", COL2, 0, 240)
for i, key in ipairs(ns.order) do
  local c = CreateFrame("CheckButton", "SkillPfadProf" .. key, opt, "UICheckButtonTemplate")
  c:SetPoint("TOPLEFT", COL2, -20 - (i - 1) * 24)
  local t = ns.WrapObj(_G[c:GetName() .. "Text"])
  t:SetText(ns.defs[key].label); t:SetWidth(200); t:SetJustifyH("LEFT")
  c:SetScript("OnClick", function(self)
    SkillPfadDB.off = SkillPfadDB.off or {}
    SkillPfadDB.off[key] = (not self:GetChecked()) or nil
    layoutTabs()
    if not ns.Enabled(current) then showTab(current) end
  end)
  profChecks[key] = c
end

-- Rechte Spalte: Optik und Status
head("Optik", COL2, -322, 240)
local status = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
status:SetPoint("TOPLEFT", COL2, -380); status:SetWidth(240); status:SetJustifyH("LEFT")

------------------------------------------------------------ Optik-Seite
local lookBtn = CreateFrame("Button", nil, opt, "UIPanelButtonTemplate")
lookBtn:SetSize(240, 24); lookBtn:SetPoint("TOPLEFT", COL2, -344)
lookBtn:SetText("Optik anpassen …")
lookBtn:SetScript("OnClick", function() lookPage = true; render() end)

P = look
head("Optik anpassen", 0, 0, 320)
head("Vorschau", COL2, 0, 240)
local function cycle(order, cur)
  for i, k in ipairs(order) do if k == cur then return order[i % #order + 1] end end
  return order[1]
end
local themeBtn, textBtn
themeBtn = button("Farbschema", 0, -24, 320, function()
  SkillPfadDB.lookTheme = cycle(THEME_ORDER, SkillPfadDB.lookTheme); ns.ApplyLook()
end)
textBtn = button("Textfarbe", 0, -54, 320, function()
  SkillPfadDB.lookText = cycle(TEXT_ORDER, SkillPfadDB.lookText); ns.ApplyLook()
end)
slider("Size",    "Schriftgröße", "lookSize", 0, -106, 9, 18, 1, "%d", function() ns.ApplyLook() end)
slider("Spacing", "Zeilenabstand", "lookSpacing", 0, -156, 0, 8, 1, "%d", function() ns.ApplyLook() end)
slider("Alpha",   "Hintergrund-Deckkraft", "lookAlpha", 0, -206, 40, 100, 5, "%d %%", function() ns.ApplyLook() end)

-- Vorschau einer Karte
local pv = CreateFrame("Frame", nil, look, "BackdropTemplate")
pv:SetBackdrop({ bgFile = FLAT, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10,
  insets = { left = 2, right = 2, top = 2, bottom = 2 } })
pv:SetPoint("TOPLEFT", COL2, -24); pv:SetSize(240, 90)
local pvTitle = pv:CreateFontString(nil, "OVERLAY", "SkillPfadHead")
pvTitle:SetPoint("TOPLEFT", 12, -8); pvTitle:SetText("Jetzt"); pvTitle:SetTextColor(1, 0.82, 0)
local pvText = pv:CreateFontString(nil, "OVERLAY", "SkillPfadBody")
pvText:SetPoint("TOPLEFT", pvTitle, "BOTTOMLEFT", 0, -6); pvText:SetWidth(216); pvText:SetJustifyH("LEFT")
local function updatePreview()
  local th, al = theme(), lookAlpha()
  pv:SetBackdropColor(th.now[1], th.now[2], th.now[3], al)
  pv:SetBackdropBorderColor(1, 0.82, 0, 1)
  pvTitle:SetFontObject(HEAD); pvText:SetFontObject(BODY)
  pvText:SetText(ns.fmt("%s%s|r herstellen", "|cffff8040", "Leichtes Rüstungsset") ..
    "\n|cff00ff00Leichtes Leder: 1/1|r   |cffff4040Grober Faden: 0/1|r\n|cff999999Fehlt: Grober Faden -> Händler|r")
  pv:SetHeight(pvTitle:GetStringHeight() + pvText:GetStringHeight() + 26)
end

button("Standard wiederherstellen", 0, -246, 320, function()
  for _, k in ipairs({ "lookSize", "lookSpacing", "lookTheme", "lookText", "lookAlpha" }) do SkillPfadDB[k] = DEFAULTS[k] end
  ns.UpdateOptions(); ns.ApplyLook()
end)
button("Zurück zu den Optionen", 0, -276, 320, function() lookPage = false; render() end)
P = opt

function ns.ApplyLook()
  local sz = tonumber(SkillPfadDB.lookSize) or 13
  local sp = tonumber(SkillPfadDB.lookSpacing) or 2
  local tc = TEXTC[SkillPfadDB.lookText] or TEXTC.creme
  BODY:SetFont(STANDARD_TEXT_FONT, sz, ""); BODY:SetSpacing(sp); BODY:SetTextColor(tc[1], tc[2], tc[3])
  HEAD:SetFont(STANDARD_TEXT_FONT, sz + 1, "")
  INFO:SetFont(STANDARD_TEXT_FONT, math.max(9, sz - 2), "")
  TAB:SetFont(STANDARD_TEXT_FONT, sz, "")
  for _, b in pairs(tabBtn) do b.label:SetFontObject(TAB) end
  local th, al = theme(), lookAlpha()
  pane:SetBackdropColor(th.pane[1], th.pane[2], th.pane[3], al)
  side:SetBackdropColor(th.side[1], th.side[2], th.side[3], al)
  f:SetBackdropColor(1, 1, 1, al)
  updatePreview()
  if f:IsShown() then render() end
end

function ns.UpdateOptions()
  if themeBtn then themeBtn:SetText(theme().name) end
  if textBtn then textBtn:SetText((TEXTC[SkillPfadDB.lookText] or TEXTC.creme).name) end
  if routeBtn and ns.RouteOf then routeBtn:SetText(routeText()) end
  if langBtn then langBtn:SetText(langText()) end
  loading = true
  for _, c in ipairs(controls) do
    local w, key, isSlider = c[1], c[2], c[3]
    if isSlider then w:SetValue(SkillPfadDB[key] or DEFAULTS[key])
    else w:SetChecked(SkillPfadDB[key] and true or false) end
  end
  loading = false
  for key, c in pairs(profChecks) do c:SetChecked(ns.Enabled(key)) end
  local n = 0
  for _ in pairs(SkillPfadDB.prices or {}) do n = n + 1 end
  status:SetText(ns.fmt("Gespeicherte Preise: %d%s", n,
    Auctionator and "  |  Auctionator erkannt (wird bevorzugt)" or "") ..
    "\nTomTom: " .. (ns.HasTomTom and ns.HasTomTom() and "gefunden" or "nicht gefunden (nur Blizzard-Wegpunkt)"))
end

------------------------------------------------------------ Start
local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(_, _, name)
  if name ~= ADDON then return end
  for k, v in pairs(DEFAULTS) do
    if SkillPfadDB[k] == nil then SkillPfadDB[k] = v end
  end
  -- Datenbank-Version und Grundpruefung (alte/kaputte Daten verwerfen statt Fehler zu werfen)
  local DBV = 1
  for _, tk in ipairs({ "off", "cache", "routes", "ranks", "fold", "maxRanks" }) do
    if type(SkillPfadDB[tk]) ~= "table" then SkillPfadDB[tk] = nil end
  end
  if (tonumber(SkillPfadDB.dbVersion) or 0) < DBV then
    SkillPfadDB.cache = nil          -- Cache-Format kann sich zwischen Versionen aendern
    SkillPfadDB.dbVersion = DBV
  end
  if ns.InitLang then ns.InitLang() end
  if ns.RelabelUI then ns.RelabelUI() end
  f:SetScale(SkillPfadDB.scale or 1)
  local sz = SkillPfadDB.size
  if type(sz) == "table" and tonumber(sz[1]) and tonumber(sz[2]) then
    f:SetSize(math.max(760, math.min(1600, sz[1])), math.max(600, math.min(1200, sz[2])))
  else SkillPfadDB.size = nil end
  ns.ApplyLook()
end)

-- Kampf: der geschuetzte Knopf wird vorher ausgeblendet und danach wieder gezeigt
local combat = CreateFrame("Frame")
combat:RegisterEvent("PLAYER_REGEN_DISABLED")
combat:RegisterEvent("PLAYER_REGEN_ENABLED")
combat:SetScript("OnEvent", function(_, e)
  if e == "PLAYER_REGEN_DISABLED" then openBtn:Hide()
  elseif f:IsShown() then updateOpenBtn(current) end
end)

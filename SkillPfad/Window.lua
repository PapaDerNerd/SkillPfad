local ADDON, ns = ...
local CreateFrame = ns.CreateFrame  -- uebersetzt Texte je nach Sprache
SkillPfadDB = SkillPfadDB or {}

local DEFAULTS = { price = false, autoShow = true, topN = 3, scale = 1, locked = false, minimapShow = true }
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
local BODY = CreateFont("SkillPfadBody")
BODY:SetFont(STANDARD_TEXT_FONT, 13, "")
BODY:SetTextColor(0.94, 0.92, 0.86)
BODY:SetSpacing(4)
local PANEL = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 14,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

------------------------------------------------------------ Hauptfenster
local f = CreateFrame("Frame", "SkillPfadWindow", UIParent, "BackdropTemplate")
f:SetSize(720, 580)
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

-- Seitenleiste (Berufe)
local side = CreateFrame("Frame", nil, f, "BackdropTemplate")
side:SetBackdrop(PANEL); side:SetBackdropColor(0.03, 0.025, 0.02, 0.97)
side:SetBackdropBorderColor(0.8, 0.7, 0.4, 1)
side:SetPoint("TOPLEFT", 16, -44); side:SetSize(186, 520)

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
hTitle:SetPoint("LEFT", hIcon, "RIGHT", 12, 0)
local hLine = pane:CreateTexture(nil, "ARTWORK")
hLine:SetTexture(FLAT)
hLine:SetVertexColor(0.8, 0.65, 0.2, 0.7)
hLine:SetHeight(1); hLine:SetPoint("TOPLEFT", 8, -58); hLine:SetPoint("TOPRIGHT", -8, -58)

-- Skillbalken (wie die Berufsleiste im Spiel)
local bar = CreateFrame("StatusBar", nil, pane, "BackdropTemplate")
bar:SetSize(150, 16); bar:SetPoint("TOPRIGHT", -14, -22)
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
    openBtn:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", r - 170, t - 19)
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
local CW = 450
child:SetSize(CW, 10); sf:SetScrollChild(child)
local cards = {}

-- Einstellungen
local opt = CreateFrame("Frame", nil, pane)
opt:SetPoint("TOPLEFT", 14, -64); opt:SetPoint("BOTTOMRIGHT", -14, 10)
opt:Hide()

------------------------------------------------------------ Tabs
local tabBtn = {}

local actions = {}      -- Tab -> Liste von { text, fn } (Wegpunkt-Buttons)
local btnPool = {}
local actionHead = child:CreateFontString(nil, "OVERLAY", "GameFontNormal")
actionHead:SetText("|cffffd100Wegpunkte (TomTom)|r")
actionHead:Hide()

local function actionButton(i)
  local b = btnPool[i]
  if not b then
    b = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
    b:SetSize(CW - 4, 26)
    b:SetScript("OnClick", function(self) if self.fn then self.fn() end end)
    btnPool[i] = b
  end
  return b
end

local ACCENT = {
  { "Wichtig", 0.95, 0.30, 0.22 }, { "Berufsquests", 0.35, 0.62, 0.98 },
  { "Einkaufsliste", 0.40, 0.82, 0.40 }, { "Gesamtbedarf", 0.40, 0.82, 0.40 }, { "Planung", 0.75, 0.50, 0.95 },
}
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
    cards[i] = c
  end
  return c
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

local function render()
  updateOpenBtn(current)
  hIcon:SetTexture(iconPath(current))
  hTitle:SetText(current == "opt" and "Optionen" or (ns.defs[current] and ns.defs[current].label) or "")
  -- Skillbalken
  local rank = (current ~= "opt" and ns.RankOf) and ns.RankOf(current) or nil
  if rank then
    bar:SetValue(rank); barText:SetText(rank .. " / 300")
    bar:SetStatusBarColor(rank >= 300 and 0.2 or 0.85, rank >= 300 and 0.8 or 0.65, 0.1)
    bar:Show()
  else bar:Hide() end
  if current == "opt" then
    sf:Hide(); opt:Show(); ns.UpdateOptions()
  else
    opt:Hide(); sf:Show()
    for _, c in ipairs(cards) do c:Hide() end
    for _, b in ipairs(btnPool) do b:Hide() end
    local y = 2
    for i, blk in ipairs(blocksOf(lines[current] or {})) do
      local c = card(i)
      local txt = table.concat(blk, "\n")
      c.text:SetText(txt)
      local r, g, b = 0.90, 0.75, 0.25
      for _, a in ipairs(ACCENT) do if txt:find(a[1], 1, true) then r, g, b = a[2], a[3], a[4]; break end end
      c.accent:SetVertexColor(r, g, b, 1)
      c:SetBackdropColor(0.11, 0.09, 0.07, 1)
      c:SetBackdropBorderColor(r * 0.7, g * 0.7, b * 0.7, 0.9)
      local h = c.text:GetStringHeight() + 22
      c:ClearAllPoints(); c:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -y); c:SetSize(CW, h)
      c:Show()
      y = y + h + 8
    end
    local list = actions[current] or {}
    if #list > 0 then
      actionHead:ClearAllPoints()
      actionHead:SetPoint("TOPLEFT", child, "TOPLEFT", 4, -(y + 2))
      actionHead:Show()
      y = y + 26
      for i, a in ipairs(list) do
        local b = actionButton(i)
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -y)
        b:SetText(a.text); b.fn = a.fn
        b:Show()
        y = y + 28
      end
    else
      actionHead:Hide()
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
        b:ClearAllPoints(); b:SetPoint("TOPLEFT", 7, -8 - n * 38); b:Show(); n = n + 1
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
  local lb = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
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
  for i, a in ipairs(list) do t[i] = a.text end
  local sig = table.concat(t, "\n")
  local same = (actSig[tab] == sig)
  actSig[tab] = sig
  actions[tab] = list
  if not (f:IsShown() and current == tab) then return end
  if same then
    for i, a in ipairs(list) do if btnPool[i] then btnPool[i].fn = a.fn end end
  else render() end
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
function ns.ResetPos() SkillPfadDB.pos = nil; if f:IsShown() then ns.PlaceWindow(); updateOpenBtn(current) end end

------------------------------------------------------------ Einstellungen: Steuerelemente
local controls = {}

local function check(name, label, key, y, onChange)
  local c = CreateFrame("CheckButton", "SkillPfadChk" .. name, opt, "UICheckButtonTemplate")
  c:SetPoint("TOPLEFT", 0, y)
  local t = ns.WrapObj(_G[c:GetName() .. "Text"])
  t:SetText(label); t:SetWidth(240); t:SetJustifyH("LEFT")
  c:SetScript("OnClick", function(self)
    SkillPfadDB[key] = self:GetChecked() and true or false
    if onChange then onChange() end
  end)
  controls[#controls + 1] = { c, key }
end

check("Price",  "Nach AH-Preisen sortieren (statt Farm-Aufwand)", "price", 0,
  function() if ns.Refresh then ns.Refresh() end end)
check("Auto",   "Fenster automatisch beim Beruf öffnen", "autoShow", -32)
check("Lock",   "Fenster sperren (nicht verschiebbar)", "locked", -64)
check("Mini",   "Knopf an der Minimap anzeigen", "minimapShow", -134,
  function() if ns.UpdateMinimapButton then ns.UpdateMinimapButton() end end)
check("Way",    "Wegpunkte per TomTom-Befehl /way setzen (falls sie falsch sitzen)", "wayMode", -96)

-- Berufe ein-/ausschalten (rechte Spalte)
local profChecks = {}
local profHead = opt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
profHead:SetPoint("TOPLEFT", 300, 0); profHead:SetText("Berufe anzeigen")
for i, key in ipairs(ns.order) do
  local c = CreateFrame("CheckButton", "SkillPfadProf" .. key, opt, "UICheckButtonTemplate")
  c:SetPoint("TOPLEFT", 296, -18 - (i - 1) * 26)
  local t = ns.WrapObj(_G[c:GetName() .. "Text"])
  t:SetText(ns.defs[key].label); t:SetWidth(130); t:SetJustifyH("LEFT")
  c:SetScript("OnClick", function(self)
    SkillPfadDB.off = SkillPfadDB.off or {}
    SkillPfadDB.off[key] = (not self:GetChecked()) or nil
    layoutTabs()
    if not ns.Enabled(current) then showTab(current) end
  end)
  profChecks[key] = c
end

local function slider(name, label, key, y, minV, maxV, step, fmt, onChange)
  local sname = "SkillPfadSlider" .. name
  local s = CreateFrame("Slider", sname, opt, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", 8, y); s:SetWidth(280)
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

slider("TopN",  "Angezeigte Rezepte", "topN", -190, 1, 5, 1, "%d",
  function() if ns.Refresh then ns.Refresh() end end)
slider("Scale", "Fenstergröße", "scale", -246, 0.7, 1.3, 0.05, "%.2f",
  function(v) f:SetScale(v); if ns.UpdateOpenBtn then ns.UpdateOpenBtn(ns.CurrentTab()) end end)

local function button(label, y, onClick)
  local b = CreateFrame("Button", nil, opt, "UIPanelButtonTemplate")
  b:SetSize(290, 24); b:SetPoint("TOPLEFT", 0, y)
  b:SetText(label); b:SetScript("OnClick", onClick)
  return b
end

local scanBtn = button("AH-Preise scannen (AH muss offen sein)", -290, function() ns.StartScan() end)
if not (CanSendAuctionQuery and QueryAuctionItems) then
  scanBtn:SetText("Preise: über Auctionator (Liste am AH suchen)")
  scanBtn:Disable()
end
button("Gespeicherte Preise löschen", -320, function()
  SkillPfadDB.prices = {}; ns.UpdateOptions()
  if ns.Refresh then ns.Refresh() end
end)
button("Fensterposition zurücksetzen", -350, function() ns.ResetPos() end)
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
routeBtn = button("Route", -380, function()
  ns.NextRoute(routeKey()); routeBtn:SetText(routeText())
  if ns.RefreshAll then ns.RefreshAll() end
end)
routeBtn:SetWidth(320)

-- Sprache: Auto (nach Client) -> Deutsch -> English
local langBtn
local function langText()
  local l = SkillPfadDB and SkillPfadDB.lang
  local cur = (l == "de" and "Deutsch") or (l == "en" and "English") or ("Auto (" .. (ns.lang == "en" and "English" or "Deutsch") .. ")")
  return "Sprache / Language: " .. cur
end
langBtn = button("Sprache / Language", -410, function()
  local l = SkillPfadDB.lang
  local nxt = (l == nil and "de") or (l == "de" and "en") or nil
  ns.SetLang(nxt)
  langBtn:SetText(langText())
  if ns.UpdateOptions then ns.UpdateOptions() end
end)
langBtn:SetWidth(320)

local status = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
status:SetPoint("TOPLEFT", 0, -444); status:SetWidth(310); status:SetJustifyH("LEFT")

function ns.UpdateOptions()
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
  for _, tk in ipairs({ "off", "cache", "routes", "ranks" }) do
    if type(SkillPfadDB[tk]) ~= "table" then SkillPfadDB[tk] = nil end
  end
  if (tonumber(SkillPfadDB.dbVersion) or 0) < DBV then
    SkillPfadDB.cache = nil          -- Cache-Format kann sich zwischen Versionen aendern
    SkillPfadDB.dbVersion = DBV
  end
  if ns.InitLang then ns.InitLang() end
  if ns.RelabelUI then ns.RelabelUI() end
  f:SetScale(SkillPfadDB.scale or 1)
end)

-- Kampf: der geschuetzte Knopf wird vorher ausgeblendet und danach wieder gezeigt
local combat = CreateFrame("Frame")
combat:RegisterEvent("PLAYER_REGEN_DISABLED")
combat:RegisterEvent("PLAYER_REGEN_ENABLED")
combat:SetScript("OnEvent", function(_, e)
  if e == "PLAYER_REGEN_DISABLED" then openBtn:Hide()
  elseif f:IsShown() then updateOpenBtn(current) end
end)

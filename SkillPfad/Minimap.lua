local ADDON, ns = ...

-- Kleiner Minimap-Knopf: Linksklick = Fenster, Rechtsklick = Optionen, ziehen = um die Minimap schieben
local ICON = "Interface\\Icons\\INV_Misc_Book_09"

local b = CreateFrame("Button", "SkillPfadMinimapButton", Minimap)
b:SetSize(31, 31)
b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(8)
b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
b:RegisterForDrag("LeftButton")
b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local icon = b:CreateTexture(nil, "ARTWORK")
icon:SetTexture(ICON); icon:SetSize(20, 20); icon:SetPoint("CENTER", 0, 1)
icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
local border = b:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(53, 53); border:SetPoint("TOPLEFT")

local function place()
  local a = math.rad((SkillPfadDB and SkillPfadDB.miniAngle) or 200)
  local r = (Minimap:GetWidth() or 140) / 2 + 5
  -- eckige Minimap: Position an den Rand klemmen
  local sh = GetMinimapShape and GetMinimapShape() or "ROUND"
  local x, y = math.cos(a) * r, math.sin(a) * r
  if sh ~= "ROUND" then
    x = math.max(-r, math.min(r, x * 1.4)); y = math.max(-r, math.min(r, y * 1.4))
  end
  b:ClearAllPoints()
  b:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function dragging()
  local mx, my = Minimap:GetCenter()
  local px, py = GetCursorPosition()
  local s = Minimap:GetEffectiveScale()
  px, py = px / s, py / s
  SkillPfadDB.miniAngle = math.deg(math.atan2(py - my, px - mx)) % 360
  place()
end

b:SetScript("OnDragStart", function(self)
  self:SetScript("OnUpdate", dragging)
  GameTooltip:Hide()
end)
b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

b:SetScript("OnClick", function(_, btn)
  if btn == "RightButton" then
    ns.OpenWindow("opt")
  elseif ns.WindowShown() then
    ns.CloseWindow()
  else
    ns.OpenWindow()
  end
end)

b:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine(ns.tr("SkillPfad"))
  GameTooltip:AddLine(ns.tr("Linksklick: Fenster öffnen/schließen"), 1, 1, 1)
  GameTooltip:AddLine(ns.tr("Rechtsklick: Optionen"), 1, 1, 1)
  GameTooltip:AddLine(ns.tr("Ziehen: Knopf verschieben"), 0.7, 0.7, 0.7)
  GameTooltip:Show()
end)
b:SetScript("OnLeave", function() GameTooltip:Hide() end)

local LDI, LDB
if LibStub then
  LDI = LibStub("LibDBIcon-1.0", true)
  LDB = LibStub("LibDataBroker-1.1", true)
end
local registered = false

function ns.UpdateMinimapButton()
  local show = not (SkillPfadDB and SkillPfadDB.minimapShow == false)
  if LDI and LDB then
    b:Hide()
    if not registered then
      SkillPfadDB.mini = SkillPfadDB.mini or { hide = false }
      local obj = LDB:NewDataObject("SkillPfad", {
        type = "launcher", icon = ICON,
        OnClick = function(_, btn) b:GetScript("OnClick")(b, btn) end,
        OnTooltipShow = function(tt)
          tt:AddLine(ns.tr("SkillPfad"))
          tt:AddLine(ns.tr("Linksklick: Fenster öffnen/schließen"), 1, 1, 1)
          tt:AddLine(ns.tr("Rechtsklick: Optionen"), 1, 1, 1)
        end,
      })
      LDI:Register("SkillPfad", obj, SkillPfadDB.mini)
      registered = true
    end
    SkillPfadDB.mini.hide = not show
    if show then LDI:Show("SkillPfad") else LDI:Hide("SkillPfad") end
    return
  end
  if show then b:Show() else b:Hide() end
  place()
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function() ns.UpdateMinimapButton() end)

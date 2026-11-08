-- Faengt Ladefehler von SkillPfad ab, zeigt sie im Chat und speichert sie in SkillPfadDB.errors
local _, ns = ...
SkillPfadDB = SkillPfadDB or {}
local errs = {}
local old = geterrorhandler and geterrorhandler()
local function handler(e)
  e = tostring(e)
  if e:find("SkillPfad", 1, true) then errs[#errs + 1] = e end
  if old then return old(e) end
end
if seterrorhandler then seterrorhandler(handler) end

local function show()
  SkillPfadDB = SkillPfadDB or {}
  SkillPfadDB.errors = errs
  if #errs == 0 then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100SkillPfad:|r keine Fehler beim Laden. /sp oeffnet das Fenster.")
  else
    DEFAULT_CHAT_FRAME:AddMessage("|cffff4040SkillPfad: " .. #errs .. " Ladefehler|r (mit /spdiag anzeigen):")
    for i = 1, math.min(#errs, 3) do DEFAULT_CHAT_FRAME:AddMessage(errs[i]:sub(1, 400)) end
  end
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_LOGOUT")
ev:SetScript("OnEvent", function(_, e)
  if e == "PLAYER_LOGIN" then
    if seterrorhandler and old then seterrorhandler(old) end
    show()
  else
    SkillPfadDB.errors = errs
  end
end)

SLASH_SKILLPFADDIAG1 = "/spdiag"
SlashCmdList["SKILLPFADDIAG"] = function()
  if #errs == 0 then print("SkillPfad: keine Fehler gespeichert.") end
  for i, e in ipairs(errs) do print(i, e:sub(1, 600)) end
end

-- Ereignisse nur anmelden, wenn der Client sie kennt (sonst Fehlermeldung)
function ns.Reg(frame, name)
  if C_EventUtils and C_EventUtils.IsEventValid then
    if C_EventUtils.IsEventValid(name) then frame:RegisterEvent(name); return true end
    return false
  end
  return (pcall(frame.RegisterEvent, frame, name))
end

-- Faehigkeitslinien: Forever nutzt C_SkillInfo, Klassik-Clients die globalen Funktionen
ns.Skills = {}
function ns.Skills.Num()
  if C_SkillInfo and C_SkillInfo.GetNumSkillLines then return C_SkillInfo.GetNumSkillLines() or 0 end
  if GetNumSkillLines then return GetNumSkillLines() end
  return 0
end
-- liefert name, isHeader, rank, maxRank
function ns.Skills.Info(i)
  if C_SkillInfo and C_SkillInfo.GetSkillLineInfo then
    local s = C_SkillInfo.GetSkillLineInfo(i)
    if not s then return nil end
    return s.name, s.isHeader, s.rank or s.skillRank, s.maxRank or s.skillMaxRank
  end
  if GetSkillLineInfo then
    local n, h, _, r, _, _, m = GetSkillLineInfo(i)
    return n, h, r, m
  end
end
function ns.Skills.ExpandAll()
  if C_SkillInfo and C_SkillInfo.ExpandSkillHeader then
    for i = ns.Skills.Num(), 1, -1 do
      local s = C_SkillInfo.GetSkillLineInfo(i)
      if s and s.isHeader and s.isCollapsed then C_SkillInfo.ExpandSkillHeader(i) end
    end
  elseif ExpandSkillHeader then
    ExpandSkillHeader(0)
  end
end

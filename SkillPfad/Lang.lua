-- Sprachschicht: deutsche Texte werden bei englischer Sprache ueber ein Woerterbuch (LangEN.lua) uebersetzt.
-- ns.lang = "de" | "en". Einstellung: SkillPfadDB.lang = nil (automatisch nach Client-Sprache) | "de" | "en".
local ADDON, ns = ...

local function clientLang()
  local loc = GetLocale and GetLocale() or "enUS"
  return (loc == "deDE") and "de" or "en"
end
ns.lang = clientLang()
local cache = {}

function ns.SetLang(l)   -- l = "de" | "en" | nil (automatisch)
  if SkillPfadDB then SkillPfadDB.lang = l end
  ns.lang = l or clientLang()
  cache = {}
  if ns.RefreshAll then pcall(ns.RefreshAll) end
  if ns.RelabelUI then pcall(ns.RelabelUI) end
end

function ns.InitLang()   -- nach dem Laden der SavedVariables
  local l = SkillPfadDB and SkillPfadDB.lang
  if l ~= "de" and l ~= "en" then l = nil end
  ns.lang = l or clientLang()
  cache = {}
end

local function esc(s) return (s:gsub("%p", "%%%0")) end

function ns.tr(s)
  if ns.lang ~= "en" or type(s) ~= "string" or s == "" then return s end
  local c = cache[s]
  if c then return c end
  local dict = ns.trEN
  if not dict then return s end
  local r = s
  for i = 1, #dict do
    local e = dict[i]
    local k = e[1]
    if r:find(k, 1, true) then
      e[3] = e[3] or esc(k)
      r = r:gsub(e[3], "\1" .. i .. "\2")
    end
  end
  if r:find("\1", 1, true) then
    r = r:gsub("\1(%d+)\2", function(n) return dict[tonumber(n)][2] end)
  end
  cache[s] = r
  return r
end

function ns.fmt(f, ...) return string.format(ns.tr(f), ...) end

function ns.print(...)
  local n = select("#", ...)
  if n == 0 then return print() end
  local t = {}
  for i = 1, n do
    local v = select(i, ...)
    t[i] = (type(v) == "string") and ns.tr(v) or v
  end
  return print(unpack(t, 1, n))
end

-- Frames: Texte (SetText) automatisch uebersetzen
local regs = {}
local function wrapObj(o)
  if type(o) ~= "table" or o.__trw then return o end
  o.__trw = true
  local st = o.SetText
  if st then
    regs[#regs + 1] = o
    o.__st = st
    o.SetText = function(self, t, ...) self.__orig = t; return st(self, ns.tr(t), ...) end
  end
  local cfs = o.CreateFontString
  if cfs then o.CreateFontString = function(self, ...) return wrapObj(cfs(self, ...)) end end
  return o
end
ns.WrapObj = wrapObj
function ns.RelabelUI()   -- Sprache gewechselt: bereits gesetzte Texte neu uebersetzen
  for _, o in ipairs(regs) do
    if o.__orig ~= nil then pcall(o.__st, o, ns.tr(o.__orig)) end
  end
end
function ns.CreateFrame(...) return wrapObj(CreateFrame(...)) end

-- Beruf-Zauber fuer den "Beruf oeffnen"-Knopf: Name muss zur Client-Sprache passen
local en = {
  leder = "Leatherworking", skin = "Skinning", kochen = "Cooking", ersthilfe = "First Aid",
  alchemie = "Alchemy", schmied = "Blacksmithing", ingenieur = "Engineering", schneider = "Tailoring",
  verzauber = "Enchanting", bergbau = "Mining", kraeuter = "Herbalism", angeln = "Fishing",
}
function ns.SpellName(key)
  local d = ns.defs and ns.defs[key]
  if not d then return nil end
  if GetLocale and GetLocale() == "deDE" then return d.label end
  return en[key] or d.label
end

-- Itemname in der Sprache des Clients (nil, wenn noch nicht im Cache)
function ns.ClientItemName(id)
  local n = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id)
  if n and n ~= "" then return n end
  return nil
end

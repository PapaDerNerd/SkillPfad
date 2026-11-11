local ADDON, ns = ...

-- Allianz-Fassung der Texte: ersetzt Horde-Orte und -Lehrer in Data.lua (bei PLAYER_LOGIN, nur fuer Allianz)
ns.allySubs = {
  { "z.B. Durotar, Brachland (auch Leichte Häute)", "z.B. Wald von Elwynn, Dun Morogh, Teldrassil (auch Leichte Häute)" },
  { "z.B. Brachland, Steinkrallengebirge", "z.B. Westfall, Loch Modan, Rotkammgebirge" },
  { "Werg Thickblade, Tirisfal", "Leonard Porter" },
  { "z.B. Karolek in Orgrimmar", "z.B. Randal Worth in Sturmwind" },
  { "z.B. Una in Donnerfels", "z.B. Simon Tanner in Sturmwind" },
  { "Hahrana Ironhide (Camp Mojache, Feralas)", "Telonis (Darnassus)" },
  { "Gesprenkelte Eber im Tal der Prüfungen / Durotar (Mob-Lvl 1-2)", "Wölfe im Wald von Elwynn / Dun Morogh (Mob-Lvl 1-3)" },
  { "Brachland nahe Kreuzweg beginnen (Mob-Level steigen nach Süden), Loch Modan im Westen bei Thelsamar beginnen, Alternative: Dunkelküste", "Loch Modan im Westen bei Thelsamar beginnen, Westfall (Lvl 15-20), Alternative: Dunkelküste" },
  { "Brachland / Loch Modan", "Loch Modan / Westfall" },
  { "ab Tarrens Mühle", "ab Süderstade" },
  { "ab Camp Mojache", "ab Mondfederfeste" },
  { "Lehrer: Kagil im Tal der Prüfungen (nur bis 75), danach Thuwd in Orgrimmar.", "Lehrer: Maris Granger in Sturmwind (Starterlehrer nur bis 75)." },
  { "(Durotar, Mulgore, Küsten)", "(Elwynn, Dun Morogh, Teldrassil, Küsten)" },
  { "Rezept Sheendra Tallgrass", "Rezept: Horde Sheendra Tallgrass, Allianz-Händler unbekannt (AH prüfen)" },
  { "Quest 'Clamlette Surprise', führt zu", "Quest 'I Know A Guy...' bei Daryl Riknussun (Eisenschmiede), dann 'Clamlette Surprise' bei" },
  { "(Durotar, Brachland, Mulgore)", "(Elwynn, Westfall, Dun Morogh)" },
  { "(Brachland, Steinkrallengebirge)", "(Westfall, Rotkammgebirge, Loch Modan)" },
  { "(Gregory Victor, Hammerfall)", "(Gustaf VanHowzen, Düstermarschen)" },
  { "Balai Lok'Wein (Düstermarschen, Horde)", "Deneb Walker (Arathihochland, Allianz)" },
  { "Doctor Gregory Victor (Hammerfall, Arathihochland)", "Doktor Gustaf VanHowzen (Düstermarschen)" },
  { "Kräuter in Durotar/Brachland", "Kräuter im Wald von Elwynn, Dun Morogh" },
  { "Lehrer in Undercity", "Lehrer in Sturmwind" },
  { "Lehrer in Stonard (Sümpfe des Elends)", "Ainethil in Darnassus" },
  { "Brikk Keencraft in Booty Bay", "Bengus Deepforge in Eisenschmiede (oder Brikk Keencraft in Booty Bay)" },
  { "Roxxik in Orgrimmar", "Lilliam Sparkspindle in Sturmwind" },
  { "Buzzek Bracketswing in Tanaris", "Springspindle Fizzlegear in Eisenschmiede (oder Buzzek Bracketswing in Tanaris)" },
  { "(Schema: Sovik)", "(Schema: Horde Sovik, Allianz-Händler unbekannt)" },
  { "z.B. Magar oder Tepa (Horde)", "z.B. Lawrence Schneider in Sturmwind" },
  { "Josef Gregorian in Undercity", "Sellandus in Sturmwind" },
  { "Daryl Stack in Tarrens Mühle", "Georgio Bolero in Sturmwind" },
  { "z.B. Godan in Orgrimmar", "z.B. Betty Quin in Sturmwind" },
  { "Hgarth (Steinkrallengebirge, Horde)", "Lucan Cordell (Sturmwind)" },
  { "nur Annora in Uldaman (am besten mit Gruppe)", "Kitta Firewind (Wald von Elwynn) oder Annora in Uldaman (mit Gruppe)" },
  { "Durotar (Höhle mit 5 Kupfervorkommen), alternativ Mulgore oder Tirisfal; Schmelzen in Razor Hill", "Wald von Elwynn oder Dun Morogh (Kupfer), alternativ Westfall; Schmelzen in Sturmwind oder Eisenschmiede" },
  { "Verwüstete Lande (Horde: Garnison-Waffenkammer)", "Verwüstete Lande" },
  { "danach Krunn in Razor Hill", "danach Gelman Stonehand in Sturmwind" },
  { "Durotar (Erdwurzel ab Skill 15)", "Wald von Elwynn, Dun Morogh, Teldrassil (Erdwurzel ab Skill 15)" },
  { "Lehrer: Mishiki in Sen'jin; Zor'la im Tal der Prüfungen nur bis 75, danach Jandi in Orgrimmar.", "Lehrer: Shylamiir in Sturmwind (Starterlehrer nur bis 75)." },
  { "Durotar, Mulgore, Tirisfal oder Zephras", "Elwynn, Dun Morogh, Teldrassil oder Zephras" },
  { "Brachland, Silberwald oder Hauptstädte", "Westfall, Loch Modan, Dunkelküste oder Hauptstädte" },
}

local function sub(s)
  if type(s) ~= "string" then return s end
  for _, p in ipairs(ns.allySubs) do
    local a, b = s:find(p[1], 1, true)
    if a then s = s:sub(1, a - 1) .. p[2] .. s:sub(b + 1) end
  end
  return s
end

function ns.ApplyFaction()
  if ns.allyDone or not (UnitFactionGroup and UnitFactionGroup("player") == "Alliance") then return end
  ns.allyDone = true
  for _, def in pairs(ns.defs or {}) do
    for _, ph in ipairs(def.phases or {}) do ph[3] = sub(ph[3]); ph[4] = sub(ph[4]) end
    for _, h in ipairs(def.hints or {}) do h[3] = sub(h[3]) end
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function() ns.ApplyFaction() end)

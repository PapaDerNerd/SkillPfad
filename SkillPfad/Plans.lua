local ADDON, ns = ...

-- Skill-Routen aller Berufe (Wowhead Forever vom 3./4.11.2026, wow-professions, RankedBoost).
-- S(von, bis, Rezept, ItemID, Menge, ItemID, Menge, ...): Materialbedarf fuer den ganzen Schritt.
-- Mengen sind Durchschnittswerte ab Skill 1; angefangene Schritte werden anteilig gerechnet.
local function S(von, bis, name, ...)
  local m, a = {}, { ... }
  for i = 1, #a, 2 do m[#m + 1] = { a[i], a[i + 1] } end
  return { von, bis, name, m }
end

-- Item-IDs
local LL, ML, HL, TL, RL = 2318, 2319, 4234, 4304, 8170          -- Leder
local LH, MH, HH, RH, SC = 783, 4232, 4235, 8171, 15408          -- Haeute, Skorpidschuppe
local CUo, TNo, IRo, MIo, TSo, THo = 2770, 2771, 2772, 3858, 7911, 10620   -- Erze
local CU, BR, SIb, IR, ST, MI, TS, TH, AZ = 2840, 2841, 2842, 3575, 3859, 3860, 6037, 12359, 12655   -- Barren
local RS, CS, HS, SS, DS = 2835, 2836, 2838, 7912, 12365         -- Steine
local LIN, WOOL, SILK, MW, RC = 2589, 2592, 4306, 4338, 14047    -- Stoffe
local PEACE, SILVER, MAGE, EARTH, BRIAR, KELP = 2447, 765, 785, 2449, 2450, 3820
local KINGS, LIFE, GOLDT, KHAD, SUN, BLIND, ARTH = 3356, 3357, 3821, 3358, 8838, 8839, 8836
local PLAGUE, LOTUS, FIREB, GHOST = 13466, 8831, 4625, 8845
local STAR, EOA, OPAL, ARC = 7910, 7082, 12799, 12360
local STRD, SOULD, VISD, DREAMD, ILLD, LMAG, LAST = 10940, 11083, 11137, 11176, 16204, 10938, 10998
local F1, F2, F3, F4, F5, F6 = 6291, 6289, 6317, 8365, 4603, 13893  -- Fische

ns.itemName = {
  [LL] = "Leichtes Leder", [ML] = "Mittleres Leder", [HL] = "Schweres Leder", [TL] = "Dickes Leder",
  [RL] = "Unverwüstliches Leder", [LH] = "Leichte Haut", [MH] = "Mittlere Haut", [HH] = "Schwere Haut",
  [RH] = "Unverwüstliche Haut", [SC] = "Schwere Skorpidschuppe",
  [CUo] = "Kupfererz", [TNo] = "Zinnerz", [IRo] = "Eisenerz", [MIo] = "Mithrilerz", [TSo] = "Echtsilbererz", [THo] = "Thoriumerz",
  [CU] = "Kupferbarren", [BR] = "Bronzebarren", [SIb] = "Silberbarren", [IR] = "Eisenbarren", [ST] = "Stahlbarren",
  [MI] = "Mithrilbarren", [TS] = "Echtsilberbarren", [TH] = "Thoriumbarren", [AZ] = "Azerothiumbarren",
  [RS] = "Rauer Stein", [CS] = "Grober Stein", [HS] = "Schwerer Stein", [SS] = "Robuster Stein", [DS] = "Dichter Stein",
  [LIN] = "Leinenstoff", [WOOL] = "Wollstoff", [SILK] = "Seidenstoff", [MW] = "Magiestoff", [RC] = "Runenstoff",
  [PEACE] = "Friedensblume", [SILVER] = "Silberblatt", [MAGE] = "Maguskönigskraut", [EARTH] = "Erdwurzel",
  [BRIAR] = "Wilddornrose", [KELP] = "Würgetang", [KINGS] = "Königsblut", [LIFE] = "Lebenswurz", [GOLDT] = "Golddorn",
  [KHAD] = "Khadgars Schnurrbart", [SUN] = "Sonnengras", [BLIND] = "Blindkraut", [ARTH] = "Arthas' Tränen",
  [PLAGUE] = "Pestblüte", [LOTUS] = "Lila Lotus", [FIREB] = "Feuerblüte", [GHOST] = "Geisterpilz",
  [STAR] = "Sternrubin", [EOA] = "Wesen der Luft", [OPAL] = "Großer Opal", [ARC] = "Arkanitbarren",
  [STRD] = "Seltsamer Staub", [SOULD] = "Seelenstaub", [VISD] = "Visionenstaub", [DREAMD] = "Traumstaub",
  [ILLD] = "Illusionsstaub", [LMAG] = "Geringe Magieessenz", [LAST] = "Geringe Astralessenz",
  [F1] = "Roher Strahlender Kleinfisch", [F2] = "Roher Langkiefer-Schlammschnapper", [F3] = "Roher Borstenbart-Katzenwels",
  [F4] = "Roher Mithrilkopf-Forelle", [F5] = "Roher Gelbschwanz", [F6] = "Großer Roher Machtfisch",
}

-- Wer liefert das Material? (fuer die Sammelberufe-Tabs)
ns.gatherTag = {}
for _, id in ipairs { LL, ML, HL, TL, RL, LH, MH, HH, RH, SC } do ns.gatherTag[id] = "skin" end
for _, id in ipairs { CU, BR, SIb, IR, ST, MI, TS, TH, AZ, RS, CS, HS, SS, DS } do ns.gatherTag[id] = "bergbau" end
for _, id in ipairs { PEACE, SILVER, MAGE, EARTH, BRIAR, KELP, KINGS, LIFE, GOLDT, KHAD, SUN, BLIND, ARTH, PLAGUE, LOTUS, FIREB, GHOST } do ns.gatherTag[id] = "kraeuter" end
for _, id in ipairs { F1, F2, F3, F4, F5, F6 } do ns.gatherTag[id] = "angeln" end

-- Barren -> Erz (Ausbeute je Erz; Bronze = 1 Kupfer + 1 Zinn -> 2 Barren)
ns.smelt = { [CU] = { CUo, 1 }, [BR] = { CUo, 1, TNo, 1, yield = 2 }, [IR] = { IRo, 1 }, [ST] = { IRo, 1 },
             [MI] = { MIo, 1 }, [TS] = { TSo, 1 }, [TH] = { THo, 1 } }

ns.plans = {}

ns.plans.leder = {
  { id = "wowhead", name = "Wowhead (4.11.2026)", note = "Ab Skill 225 noch ungetestet.", steps = {
  S(30, 45, "Leichte Rüstungssätze", LL, 20),
  S(45, 55, "Gegerbte Leichte Haut", LH, 10),
  S(55, 85, "Geprägte Lederhandschuhe", LL, 105),
  S(85, 100, "Feiner Ledergürtel", LL, 120),
  S(100, 115, "Dunkle Lederhose", ML, 180),
  S(115, 118, "Graue Lederstiefel", ML, 28),
  S(125, 135, "Gegerbte Schwere Haut", HH, 10),
  S(143, 145, "Gegerbte Schwere Haut", HH, 12),
  S(145, 155, "Gehärtete Lederhandschuhe", ML, 100),
  S(155, 160, "Barbarische Schultern", HL, 40),
  S(180, 185, "Barbarische Schultern", HL, 96),
  S(190, 200, "Wächterhandschuhe", HL, 80),
  S(200, 210, "Dicker Rüstungssatz", TL, 100),
  S(210, 225, "Nachtschattenhose", TL, 210),
  S(225, 230, "Gegerbte Unverwüstliche Haut", RH, 6),
  S(230, 240, "Nachtschattenhose", TL, 280),
  S(240, 255, "Boshafte Lederstulpen", RL, 120),
  S(255, 260, "Schwere Skorpidarmschienen", RL, 24, SC, 24),
  S(260, 270, "Boshafte Lederstulpen", RL, 160),
  S(270, 300, "Schwerer Skorpidhelm", RL, 264, SC, 396, RH, 33),
  } },
  { id = "profs", name = "wow-professions (Forever-Beta)", note = "Ab Skill 210 laut Quelle ungetestet; braucht viel Runenstoff.", steps = {
  S(30, 45, "Leichte Rüstungssätze", LL, 24),
  S(45, 55, "Geprägte Lederhandschuhe", LL, 30),
  S(55, 75, "Geprägte Lederhandschuhe", LL, 63),
  S(75, 80, "Mittleres Leder", LL, 32),
  S(80, 90, "Gegerbte Mittlere Haut", MH, 10),
  S(90, 100, "Feiner Ledergürtel", LL, 114),
  S(100, 115, "Dunkler Lederumhang", ML, 128),
  S(125, 130, "Schweres Leder", ML, 35),
  S(130, 140, "Gegerbte Schwere Haut", HH, 20),
  S(140, 155, "Hügelmann-Lederhandschuhe", ML, 280),
  S(155, 165, "Barbarische Schultern", HL, 80, HH, 10),
  S(165, 175, "Wächterhandschuhe", HL, 40, HH, 10),
  S(175, 195, "Wächterhandschuhe", HL, 104, HH, 26),
  S(195, 210, "Nachtschatten-Stirnband", TL, 105),
  S(210, 225, "Nachtschattenhose", TL, 210),
  S(225, 235, "Nachtschattenstiefel", TL, 192),
  S(235, 250, "Boshafte Lederstulpen", RL, 120),
  S(250, 265, "Boshafte Lederstulpen", RL, 168),
  S(265, 285, "Runen-Lederstirnband", RL, 280, RC, 200),
  S(285, 300, "Runen-Lederstirnband", RL, 462, RC, 330),
  } },
  { id = "ranked", name = "RankedBoost (9.10.2026)", note = "Ab 225 nur Gesamtsummen, ältester Stand.", steps = {
  S(1, 50, "Leichter Rüstungssatz", LL, 61),
  S(50, 65, "Gegerbte Leichte Haut", LH, 27),
  S(65, 75, "Geprägte Lederhandschuhe", LL, 45),
  S(75, 90, "Geprägte Lederhandschuhe", LL, 81),
  S(90, 101, "Gegerbte Mittlere Haut", MH, 19),
  S(101, 117, "Graue Lederstiefel", ML, 108),
  S(117, 130, "Dunkle Lederhandschuhe", LL, 52, LH, 13, MH, 13),
  S(130, 145, "Hügelmann-Schultern", MH, 23, ML, 92),
  S(145, 155, "Schwerer Rüstungssatz", HL, 70),
  S(155, 170, "Grüner Ledergürtel", HH, 27, HL, 135),
  S(170, 175, "Barbarische Schultern", HH, 6, HL, 48),
  S(175, 185, "Grüne Lederarmschienen", HH, 28, HL, 84),
  S(185, 195, "Wächterhandschuhe", HH, 14, HL, 56),
  S(195, 200, "Dicker Rüstungssatz", TL, 30),
  S(200, 215, "Nachtschatten-Stirnband", TL, 135),
  S(215, 225, "Nachtschattenumhang", TL, 120),
  S(225, 300, "Unverwüstlicher Rüstungssatz u.a.", RL, 677, SC, 28),
  } },
}

ns.plans.schmied = {
  { id = "wowhead", name = "Wowhead (4.11.2026)", note = "Ab Skill 225 ungetestet; Thorium-Route mit Bold Dirk.", steps = {
    S(1, 30, "Raue Wetzsteine", RS, 32), S(30, 65, "Raue Mahlsteine", RS, 84), S(65, 75, "Kupferkettengürtel", CU, 60),
    S(75, 80, "Silberskelettschlüssel", SIb, 5), S(80, 90, "Raue Bronzegamaschen", BR, 60), S(90, 100, "Runenkupfergürtel", CU, 130),
    S(100, 105, "Schwerer Wetzstein", HS, 5), S(105, 110, "Runenkupfergürtel", CU, 100), S(110, 125, "Raue Bronzegamaschen", BR, 90),
    S(125, 129, "Eiserne Schnalle", IR, 6), S(129, 140, "Bronzener Kriegshammer", BR, 88, ML, 11),
    S(140, 147, "Gemusterte bronzene Armschienen", BR, 85, CS, 68), S(147, 155, "Grüne Eisenarmschienen", IR, 48),
    S(155, 165, "Grüne Eisengamaschen", IR, 96, HS, 36), S(165, 183, "Grüne Eisenarmschienen", IR, 186),
    S(183, 190, "Schwerer Mithrilhandschuh", MI, 42, MW, 28), S(190, 200, "Goldschuppenarmschienen", ST, 80, HS, 96),
    S(200, 205, "Schwerer Mithrilhandschuh", MI, 30, MW, 20), S(205, 210, "Mithrilplattenhose", MI, 60),
    S(210, 215, "Schwerer Mithrilhandschuh", MI, 72, MW, 48), S(215, 225, "Schwere Mithrilbrustplatte", MI, 160),
    S(225, 235, "Dichter Gewichtsstein", DS, 15), S(235, 240, "Mithrilhelmkappe", MI, 120, MW, 72),
    S(240, 246, "Schwere Mithrilstiefel", MI, 238, TL, 68), S(246, 250, "Großer schwarzer Streitkolben", MI, 192, TL, 24, SS, 48),
    S(250, 257, "Arkanitskelettschlüssel", ARC, 10, DS, 40), S(257, 270, "Ebon-Schiv", MI, 240, TS, 120, STAR, 40, TL, 40, SS, 80),
    S(270, 275, "Kühner Dolch", TH, 150, AZ, 50, EOA, 20, RL, 20), S(275, 279, "Verzierte Thoriumhandaxt", TH, 80, OPAL, 8, DS, 32, RL, 16),
    S(279, 300, "Kühner Dolch", TH, 720, AZ, 240, EOA, 96, RL, 96),
  } },
  { id = "profs", name = "wow-professions (Forever-Beta)", note = "Ab Skill 225 ungetestet; Imperiale-Platte-Route (140 Thorium für Quests).", steps = {
    S(1, 25, "Raue Wetzsteine", RS, 30), S(25, 50, "Raue Mahlsteine", RS, 60), S(50, 67, "Grobe Mahlsteine", CS, 72),
    S(67, 75, "Runenkupferstulpen", CU, 64), S(75, 80, "Runenkupfergürtel", CU, 50), S(80, 95, "Runenkupfergürtel", CU, 180),
    S(95, 100, "Gemusterte bronzene Armschienen", BR, 25), S(100, 112, "Schwere Mahlsteine", HS, 60),
    S(112, 125, "Gemusterte bronzene Armschienen", BR, 65), S(125, 140, "Bronzenes Kurzschwert", BR, 120, ML, 48),
    S(140, 150, "Bronzener Kriegshammer", BR, 80, ML, 10), S(150, 170, "Bronzener Kriegshammer", BR, 232, ML, 29),
    S(170, 175, "Grüne Eisenarmschienen", IR, 54), S(175, 195, "Goldschuppenarmschienen", ST, 125),
    S(195, 210, "Schwerer Mithrilhandschuh", MI, 126, MW, 84), S(210, 215, "Stahlplattenhelm", ST, 98, SS, 28),
    S(215, 225, "Schwere Mithrilbrustplatte", MI, 160), S(225, 230, "Dichter Wetzstein", DS, 5),
    S(230, 240, "Schwere Mithrilstiefel", MI, 224, TL, 64), S(240, 245, "Imperialer Plattengürtel", TH, 110, RL, 30),
    S(245, 270, "Imperiale Plattenarmschienen", TH, 540, STAR, 27), S(270, 290, "Imperiale Plattenstiefel", TH, 680, STAR, 20),
    S(290, 300, "Imperiale Plattengamaschen", TH, 440, STAR, 20),
  } },
}

ns.plans.ingenieur = {
  { id = "wowhead", name = "Wowhead (3.11.2026)", note = "Ab Skill 225 ungetestet.", steps = {
    S(1, 30, "Raues Sprengpulver", RS, 32), S(30, 50, "Handvoll Kupferbolzen", CU, 20), S(50, 51, "Arclight-Schraubenschlüssel", CU, 6),
    S(51, 75, "Raue Kupferbombe", CU, 29, RS, 58, LIN, 29), S(75, 90, "Grobes Sprengpulver", CS, 16),
    S(90, 100, "Grobes Dynamit", CS, 45, LIN, 15), S(100, 105, "Silberkontakt", SIb, 5), S(105, 125, "Bronzerohr", BR, 50),
    S(135, 150, "Wirbelnder Bronzegizmo", BR, 46, WOOL, 23), S(150, 160, "Bronzerahmen", BR, 24, ML, 12, WOOL, 12),
    S(160, 175, "Explosives Schaf", HS, 30, WOOL, 30), S(175, 194, "Robustes Sprengpulver", SS, 102),
    S(194, 195, "Gyromatischer Mikro-Regler", ST, 4), S(195, 200, "Mithrilrohr", MI, 15),
    S(200, 215, "Instabiler Auslöser", MI, 18, MW, 18, SS, 18), S(215, 238, "Mithrilgehäuse", MI, 99),
    S(238, 250, "Hochexplosive Bombe", SS, 30), S(250, 260, "Dichtes Sprengpulver", DS, 54),
    S(260, 285, "Thorium-Gadget", TH, 75, RC, 25), S(285, 300, "Thoriumrohr", TH, 90),
  } },
  { id = "profs", name = "wow-professions (Forever-Beta)", note = "Ab Skill 225 ungetestet; etwas mehr Material.", steps = {
    S(1, 30, "Raues Sprengpulver", RS, 60), S(30, 50, "Handvoll Kupferbolzen", CU, 30), S(50, 51, "Arclight-Schraubenschlüssel", CU, 6),
    S(51, 75, "Raue Kupferbombe", CU, 30, LIN, 30), S(75, 90, "Grobes Sprengpulver", CS, 60),
    S(90, 100, "Grobes Dynamit", CS, 0, LIN, 20), S(100, 105, "Silberkontakt", SIb, 5), S(105, 125, "Bronzerohr", BR, 50),
    S(135, 150, "Schweres Sprengpulver", HS, 30, BR, 30, WOOL, 15), S(150, 160, "Bronzerahmen", BR, 30, ML, 15, WOOL, 15),
    S(160, 175, "Explosives Schaf", WOOL, 30), S(175, 194, "Robustes Sprengpulver", SS, 120),
    S(194, 195, "Gyromatischer Mikro-Regler", ST, 4), S(195, 200, "Mithrilrohr", MI, 18),
    S(200, 215, "Instabiler Auslöser", MI, 20, MW, 20), S(215, 238, "Mithrilgehäuse", MI, 120),
    S(238, 250, "Hochexplosive Bombe", SS, 40), S(250, 260, "Dichtes Sprengpulver", DS, 60),
    S(260, 285, "Thorium-Gadget", TH, 105, RC, 35), S(285, 300, "Thoriumrohr", TH, 120),
  } },
}

ns.plans.alchemie = {
  { id = "wowhead", name = "Wowhead (3.11.2026)", note = "Ab Skill 225 ungetestet.", steps = {
    S(1, 12, "Elixier der geringen Kraft", SILVER, 11), S(12, 55, "Elixier der geringen Verteidigung", SILVER, 43, PEACE, 43),
    S(55, 65, "Schwacher Manatrank", MAGE, 10, PEACE, 10), S(65, 90, "Elixier der geringen Seelenstärke", EARTH, 52, PEACE, 26),
    S(90, 120, "Elixier der Weisheit", MAGE, 30, BRIAR, 60), S(120, 160, "Geringer Manatrank", MAGE, 43, KELP, 43),
    S(160, 195, "Manatrank", KELP, 38, KINGS, 38), S(195, 205, "Elixier der Beweglichkeit", KELP, 10, GOLDT, 10),
    S(205, 225, "Großer Manatrank", KHAD, 20, GOLDT, 20), S(225, 226, "Stein der Weisen", IR, 4, LOTUS, 4, FIREB, 4),
    S(226, 240, "Großer Manatrank", KHAD, 20, GOLDT, 20), S(240, 260, "Trank Untote entdecken", ARTH, 23),
    S(260, 270, "Überragender Manatrank", SUN, 20, BLIND, 20), S(270, 300, "Mächtiger Verfärbter Heiltrank", PLAGUE, 31),
  } },
  { id = "profs", name = "wow-professions (Forever-Beta)", note = "Ab Skill 225 ungetestet; letzte 10 Punkte nicht final.", steps = {
    S(1, 10, "Kleines Arkanelixier", PEACE, 9), S(10, 55, "Elixier der geringen Verteidigung", SILVER, 45, PEACE, 45),
    S(55, 65, "Schwacher Manatrank", MAGE, 10, PEACE, 10), S(65, 90, "Elixier der geringen Seelenstärke", EARTH, 54, PEACE, 27),
    S(90, 120, "Elixier der Weisheit", MAGE, 30, BRIAR, 60), S(120, 130, "Geringer Manatrank", MAGE, 10, KELP, 10),
    S(130, 150, "Geringer Manatrank", MAGE, 20, KELP, 20), S(150, 165, "Geringer Manatrank", MAGE, 22, KELP, 22),
    S(165, 195, "Manatrank", KELP, 36, KINGS, 36), S(195, 225, "Naturschutztrank", LIFE, 36, KELP, 36),
    S(225, 230, "Naturschutztrank", LIFE, 12, KELP, 12), S(230, 240, "Großer Manatrank", KHAD, 20, GOLDT, 20),
    S(240, 265, "Trank Untote entdecken", ARTH, 35), S(265, 275, "Überragender Manatrank", SUN, 20, BLIND, 20),
    S(275, 290, "Überragender Manatrank", SUN, 40, BLIND, 40), S(290, 300, "Großer Frenzy-Trank", PLAGUE, 51, BLIND, 34),
  } },
}

ns.plans.schneider = {
  { id = "wowhead", name = "Wowhead (4.11.2026)", note = "205-234 ohne Materialangabe; ab 225 ungetestet.", steps = {
    S(1, 43, "Leinenballen", LIN, 108), S(43, 45, "Braune Leinenweste", LIN, 4), S(45, 70, "Leinengürtel", LIN, 66),
    S(70, 75, "Verstärkter Leinenumhang", LIN, 28), S(75, 81, "Wollballen", WOOL, 36), S(81, 100, "Wollumhang", WOOL, 84),
    S(100, 110, "Seidenballen", SILK, 40), S(110, 125, "Doppelt genähte Wollschultern", WOOL, 171),
    S(125, 132, "Azurblaue Seidenkapuze", SILK, 56), S(132, 139, "Geringe Zauberrobe", SILK, 64),
    S(139, 140, "Förmliches weißes Hemd", SILK, 12), S(140, 149, "Magiestoffballen", MW, 55),
    S(149, 160, "Erdweste", SILK, 132), S(160, 170, "Robe der Macht", MW, 100), S(170, 180, "Schwarze Magiestoffweste", MW, 100),
    S(180, 190, "Orangefarbenes Magiestoffhemd", MW, 55), S(190, 205, "Schwarze Magiestoffhandschuhe", MW, 170),
    S(234, 250, "Runenstoffumhang", RC, 288), S(250, 260, "Runenstoffstiefel", RC, 192, RL, 48),
    S(260, 280, "Runenstoffbündchen", RC, 500), S(280, 285, "Weisheit der Timbermaw", RC, 256),
    S(285, 292, "Giftspei-Handschuhe", RC, 112), S(292, 299, "Giftspei-Gürtel", RC, 216), S(299, 300, "Giftspei-Fußpolster", RC, 80),
  } },
}

ns.plans.ersthilfe = {
  { id = "wowhead", name = "Wowhead (3.11.2026)", note = "Ab 240 laut Quelle unbestätigt.", steps = {
    S(1, 40, "Leinenverband", LIN, 41), S(40, 80, "Schwerer Leinenverband", LIN, 110), S(80, 115, "Wollverband", WOOL, 48),
    S(115, 150, "Schwerer Wollverband", WOOL, 96), S(150, 180, "Seidenverband", SILK, 41), S(180, 210, "Schwerer Seidenverband", SILK, 82),
    S(210, 240, "Magiestoffverband", MW, 41), S(240, 260, "Schwerer Magiestoffverband", MW, 48),
    S(260, 290, "Runenstoffverband", RC, 40), S(290, 300, "Schwerer Runenstoffverband", RC, 22),
  } },
}

ns.plans.verzauber = {
  { id = "wowhead", name = "Wowhead (3.11.2026)", note = "Stäbe und Essenzen nicht eingerechnet; ab 225 ungetestet.", steps = {
    S(20, 79, "Geringer Zauberstab", LMAG, 59), S(79, 90, "Brust: Geringe Absorption", LMAG, 11), S(90, 100, "Armschiene: Geringe Ausdauer", STRD, 20),
    S(101, 110, "Großer Zauberstab", LMAG, 18), S(110, 135, "Umhang: Geringe Beweglichkeit", LAST, 25),
    S(135, 155, "Armschiene: Mindere Ausdauer", SOULD, 20), S(156, 185, "Armschiene: Mindere Stärke", SOULD, 36),
    S(185, 200, "Armschiene: Stärke", VISD, 15), S(201, 220, "Armschiene: Stärke", VISD, 26), S(220, 225, "Umhang: Große Verteidigung", VISD, 5),
    S(225, 230, "Handschuhe: Beweglichkeit", VISD, 5), S(230, 235, "Stiefel: Ausdauer", VISD, 10),
    S(235, 250, "Brust: Überragende Ausdauer", VISD, 48), S(250, 265, "Geringes Manaöl", DREAMD, 15, LOTUS, 15),
    S(265, 294, "Schild: Große Ausdauer", DREAMD, 180), S(295, 300, "Umhang: Überragende Verteidigung", ILLD, 40),
  } },
}

ns.plans.kochen = {
  { id = "wowhead", name = "Wowhead (3.11.2026)", note = "Ab 225 ungetestet.", steps = {
    S(1, 50, "Strahlender Kleinfisch", F1, 49), S(50, 100, "Langkiefer-Schlammschnapper", F2, 51),
    S(100, 175, "Borstenbart-Katzenwels", F3, 120), S(175, 225, "Mithrilkopf-Forelle", F4, 51),
    S(225, 275, "Gefleckter Gelbschwanz", F5, 51), S(275, 300, "Machtfisch-Steak", F6, 25),
  } },
}

table.insert(ns.plans.schneider, { id = "profs", name = "wow-professions (Forever-Beta)",
  note = "Ab Skill 225 ungetestet; ab 265 keine Rezepte. Ballen sind in Stoff umgerechnet (Wolle 3, Seide 4, Magiestoff 5, Runenstoff 5 je Ballen).",
  steps = {
    S(1, 30, "Leinenballen", LIN, 60), S(30, 55, "Leinengürtel", LIN, 56), S(55, 80, "Wollballen", WOOL, 135),
    S(80, 95, "Wollumhang", WOOL, 66), S(95, 100, "Doppelt genähte Wollschultern", WOOL, 45),
    S(100, 120, "Seidenballen", SILK, 216), S(120, 125, "Handschuhe der Meditation", WOOL, 60),
    S(125, 140, "Handschuhe der Meditation", WOOL, 264), S(140, 150, "Magiestoffballen", MW, 115),
    S(150, 170, "Purpurseidenweste", SILK, 160), S(170, 190, "Purpurseidenhose", SILK, 360),
    S(190, 215, "Schwarze Magiestoffhandschuhe", MW, 265), S(215, 225, "Magiestofftasche", MW, 520),
    S(225, 240, "Runenstoffgürtel", RC, 360), S(240, 265, "Runenstoffhandschuhe", RC, 860, RL, 172),
  } })

table.insert(ns.plans.verzauber, { id = "profs", name = "wow-professions (Forever-Beta)",
  note = "Pfad mit Geringer Magieessenz; ab Skill 225 ungetestet (Annora, Uldaman).",
  steps = {
    S(20, 70, "Armschiene: Geringe Ablenkung", LMAG, 50), S(70, 100, "Brust: Geringe Absorption", LMAG, 33),
    S(100, 109, "Brust: Geringe Absorption", LMAG, 18), S(109, 110, "Runensilberstab", STRD, 3, LMAG, 4),
    S(110, 130, "2H-Waffe: Geringe Intelligenz", LMAG, 80), S(130, 150, "2H-Waffe: Geringe Intelligenz", LMAG, 128),
    S(150, 151, "Runengoldstab", SOULD, 1), S(151, 165, "Geringes Manaöl", SOULD, 16),
    S(165, 185, "Stiefel: Geringe Beweglichkeit", SOULD, 22), S(185, 200, "Armschiene: Stärke", VISD, 15),
    S(200, 201, "Runenechtsilberstab", VISD, 1), S(201, 220, "Geringes Zauberöl", VISD, 25),
    S(220, 225, "Umhang: Große Verteidigung", VISD, 5), S(225, 230, "Handschuhe: Beweglichkeit", VISD, 5),
    S(230, 235, "Stiefel: Ausdauer", VISD, 10), S(235, 250, "Brust: Überragende Ausdauer", VISD, 60),
    S(250, 265, "Geringes Manaöl", DREAMD, 20, LOTUS, 20), S(265, 294, "Schild: Große Ausdauer", DREAMD, 192),
    S(294, 295, "Runenarkanitstab", ILLD, 10), S(295, 300, "Umhang: Überragende Verteidigung", ILLD, 40),
  } })

-- Routen mit Luecken in der Quelle: im Kostenvergleich nie "guenstigste"
ns.plans.leder[3].partial = true
ns.plans.schneider[1].partial = true
ns.plans.schneider[2].partial = true

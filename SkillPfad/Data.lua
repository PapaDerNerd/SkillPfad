local ADDON, ns = ...

-- Reihenfolge der Berufe in der Liste links
ns.order = { "leder", "skin", "kochen", "ersthilfe", "alchemie", "schmied",
             "ingenieur", "schneider", "verzauber", "bergbau", "kraeuter", "angeln" }

-- Kurzbefehle: /lg <wort>
ns.alias = {
  leder = "leder", kuersch = "skin", ["kürschnerei"] = "skin", skin = "skin",
  kochen = "kochen", hilfe = "ersthilfe", ersthilfe = "ersthilfe", erstehilfe = "ersthilfe",
  alchemie = "alchemie", alch = "alchemie", schmied = "schmied", schmiedekunst = "schmied",
  ingenieur = "ingenieur", ing = "ingenieur", schneider = "schneider", schneiderei = "schneider",
  verzauber = "verzauber", verzauberkunst = "verzauber", bergbau = "bergbau",
  kraeuter = "kraeuter", ["kräuter"] = "kraeuter", ["kräuterkunde"] = "kraeuter", angeln = "angeln",
}

-- Berufe mit Rezeptfenster (TradeSkill): Rezepte werden live gelesen.
-- Berufe mit gather = true: reine Skill-Guides (lesen nur deinen Skill).
-- phases = { von, bis, Material, Fundort }; hints = { von, bis, Text }
-- Quelle: Forever-Beta-Guides (Stand Nov 2026), Richtwerte! Abschnitte ab 225 meist ungetestet.
ns.defs = {
  leder = {
    label = "Lederverarbeitung",
    names = { ["Leatherworking"] = true, ["Lederverarbeitung"] = true },
    phases = {
      { 1,   115, "Leichtes Leder",       "Tiere Lvl 1-20, z.B. Durotar, Brachland (auch Leichte Häute)" },
      { 115, 155, "Mittleres Leder", "Tiere Lvl 20-30, z.B. Brachland, Steinkrallengebirge" },
      { 155, 195, "Schweres Leder",       "Tiere Lvl 30-40, z.B. Schlingendorntal, Arathihochland" },
      { 195, 240, "Dickes Leder",         "Tiere Lvl 40-50, z.B. Tanaris, Feralas: Dicke Rüstungssätze 200-210, Nachtschatten-Hose 210-225, Gegerbtes Unverwüstliches Leder 225-230 (6 Rohe Häute, Salz), dann wieder Nachtschatten-Hose bis 240" },
      { 240, 301, "Unverwüstliches Leder & Skorpidschuppen", "Boshafte Lederstulpen 240-255 und 260-270 (Muster: Werg Thickblade, Tirisfal; 15-20 Schwarzer Farbstoff, Runenfaden), Schwere Skorpidarmschienen 255-260 (Skorpidschuppen aus Silithus, Muster: Zannok Hidepiercer), Schwerer Skorpidhelm 270-300 (33x, ca. 400 Skorpidschuppen, 264 Unverwüstliches Leder). Unverwüstliches Leder: Un'Goro, Winterquell, Azshara, Östliche Pestländer, Brennende Steppe" },
    },
    hints = {
      { 50,  75,  "Geselle: Lehrer ab Skill 50 (Lvl 10), z.B. Karolek in Orgrimmar. Ohne Geselle gibt es ab 75 keine Skillpunkte." },
      { 125, 150, "Experte: Skill 125, Lvl 20, 50 Silber, z.B. Una in Donnerfels." },
      { 200, 225, "Artisan: Skill 200, Lvl 35, Hahrana Ironhide (Camp Mojache, Feralas)." },
      { 225, 300, "Ab 225 laut Guide ungetestet. Muster: Boshafte Lederstulpen (Werg Thickblade, Tirisfal) ab 235, Runenlederstirnband (Jase Farlane, Lichtgrenze) ab 265." },
    },
  },
  skin = {
    label = "Kürschnerei",
    gather = true,
    names = { ["Skinning"] = true, ["Kürschnerei"] = true },
    phases = {
      { 1,   75,  "Starterzone",        "Gesprenkelte Eber im Tal der Prüfungen / Durotar (Mob-Lvl 1-2)" },
      { 75,  150, "Brachland / Loch Modan", "Raptorenlager westlich von Nordwacht (Lvl 16-18); Alternative: Loch Modan 75-125, Sumpfland (Whelgars Ausgrabung) 125-150" },
      { 150, 225, "Hügelland",          "Höhlen im Vorgebirge des Hügellands (Yetis Lvl 30-32, ab Tarrens Mühle) oder Verrottender Obstgarten im Dämmerwald (Lvl 26-29)" },
      { 225, 280, "Feralas",            "Feral-Scar-Tal in Feralas (Yetis Lvl 43-46, ab Camp Mojache)" },
      { 280, 301, "Krater von Un'Goro",            "Krater von Un'Goro (Westen), Flug ab Marshals Zuflucht (Lvl 50-55)" },
    },
    hints = {
      { 1,   75,  "Lehrer: Kagil im Tal der Prüfungen (nur bis 75), danach Thuwd in Orgrimmar. Häutemesser nicht vergessen." },
      { 50,  75,  "Geselle: Skill 50 beim Lehrer in der Hauptstadt." },
      { 125, 150, "Experte: Skill 125." },
      { 200, 225, "Artisan: Skill 200." },
      { 20,  300, "Mobs ab Lvl 20 brauchen Skill = 5 x Mob-Level. Handschuhe mit Kürschnerei-Verzauberung erlauben ein Level mehr." },
    },
  },
  kochen = {
    label = "Kochen",
    names = { ["Cooking"] = true, ["Kochkunst"] = true, ["Kochen"] = true },
    phases = {
      { 1,   50,  "Fisch, Eber- & Wolfsfleisch",    "Kleinfisch, Makrele, Eber, Wolf (Durotar, Mulgore, Küsten); Gewürze beim Kochhändler" },
      { 50,  100, "Fisch, Bär, Kojote",            "Fische, Bärenfleisch, Muscheln, Kojotenfleisch; Quellwasser beim Händler" },
      { 100, 150, "Krabben, Rippen, Omelett",      "Krebse, Eberrippen, Katzenwels, Raptoreier, Löwenfleisch; Scharfe Gewürze vom Händler" },
      { 150, 225, "Raptor, Forelle, Schildkröte",  "Raptoreier und -fleisch, Mithril-Forelle, Schildkrötenfleisch" },
      { 225, 275, "Artisan: Fisch, Eier, Wolf",    "Gelbschwanz (Rezept bei Gikkix, Tanaris), Rotkiemer, Riesenei, Wolfsfleisch (Tanaris, Schlingendorntal, Winterquell)" },
      { 275, 301, "Machtfisch-Steak oder Lachs",   "Machtfisch-Steak (25 Großer Roher Machtfisch, Gewürze; Rezept Sheendra Tallgrass) oder Sonnenschuppenlachs / Nachtflossen-Suppe (Rezepte bei Gikkix, Tanaris)" },
    },
    hints = {
      { 1,   50,  "Lerne beim Lehrer das Basis-Lagerfeuer-Set. Gewürze und Wasser dort beim Händler kaufen, nicht im AH." },
      { 50,  75,  "Geselle beim selben Lehrer lernen, sonst gibt es ab 75 keine Skillpunkte." },
      { 125, 150, "Expertenkochbuch: Wulan (Desolace, Horde) oder Shandrina (Eschental, Allianz)." },
      { 225, 300, "Artisan (Skill 225, Lvl 35): Quest 'Clamlette Surprise', führt zu Dirge Quikcleave in Gadgetzan. Vorher 12 Riesenei, 10 Scharfes Muschelfleisch, 20 Alteraclochkäse besorgen." },
      { 225, 300, "In Gadgetzan beim Artisan-Lehrer und bei Gikkix alle Rezepte kaufen. Dieser Abschnitt ist in der Beta ungetestet." },
    },
  },
  ersthilfe = {
    label = "Erste Hilfe",
    names = { ["First Aid"] = true, ["Erste Hilfe"] = true },
    phases = {
      { 1,   80,  "Leinenstoff",               "Humanoide Lvl 1-20 (Durotar, Brachland, Mulgore): Leinenverband, Schwerer Leinenverband" },
      { 80,  150, "Wollstoff",                 "Humanoide Lvl 15-30 (Brachland, Steinkrallengebirge): Wollverband, Schwerer Wollverband" },
      { 150, 210, "Seidenstoff",               "Humanoide Lvl 30-45 (Schlingendorntal, Arathihochland): Seidenverband, Schwerer Seidenverband" },
      { 210, 225, "Magiestoff (oder Seide)",   "Magiestoffverband 210-225; Ersatz: Schwerer Seidenverband (84 Seide), falls Magiestoff fehlt" },
      { 225, 240, "Überragender Heiltrank",    "16 Sonnengras, 16 Beruhigende Gewürze, 16 Kristallphiole (Handbuch ohne Händler, vermutlich Drop)" },
      { 240, 275, "Magiestoff- & Runenstoffverband", "Schwerer Magiestoffverband 240-260 (ca. 48 Magiestoff), Runenstoffverband 260-290 (ca. 40 Runenstoff); beides lehrt der Triage-Arzt (Gregory Victor, Hammerfall)" },
      { 275, 301, "Schwerer Runenstoffverband", "Schwerer Runenstoffverband 290-300 (ca. 22 Runenstoff); Alternative laut anderem Guide: Mächtiger Heiltrank 275-300 (30 Sansam, 90 Beruhigende Gewürze, 30 Kristallphiole)" },
    },
    hints = {
      { 1,   75,  "Alternative: Kleiner Heiltrank (Friedensblume, Gewürze, leere Phiole)." },
      { 50,  75,  "Geselle bei jedem Erste-Hilfe-Lehrer lernen, sonst gibt es ab 75 keine Skillpunkte." },
      { 125, 150, "Experte: Buch 'Under Wraps' bei Balai Lok'Wein (Düstermarschen, Horde). Dort gibt es auch die Handbücher für schwere Seide und Magiestoff." },
      { 225, 240, "Artisan (Skill 225, Lvl 35): Quest 'Triage' bei Doctor Gregory Victor (Hammerfall, Arathihochland). 15 Patienten retten, dann sofort abgeben." },
      { 225, 300, "Die Heiltrank-Rezepte (Überragend, Mächtig) haben keinen Händler und sind wohl Drops. Dieser Abschnitt ist in der Beta ungetestet." },
    },
  },
  alchemie = {
    label = "Alchemie",
    names = { ["Alchemy"] = true, ["Alchemie"] = true },
    phases = {
      { 1,   55,  "Friedensblume, Silberblatt",         "Elixier der geringen Verteidigung bis 55; Kräuter in Durotar/Brachland, Phiolen beim Alchemiehändler" },
      { 55,  120, "Erdwurzel, Wilddornrose, Maguskönigskraut", "Mana- und Weisheits-Elixiere; Silberwald, Loch Modan, Dunkelküste" },
      { 120, 150, "Würgetang, Feuerflossen-Schnapper",   "Kleiner Manatrank, Feueröl (30 Öle für später aufheben)" },
      { 150, 225, "Königsblut, Würgetang, Beulengras",  "Manatrank, Elixier der Feuerkraft, Naturschutztrank (Rezept in Feralas); Hügelland, Schlingendorntal, Arathihochland" },
      { 225, 301, "Arthas' Tränen, Sonnengras, Blindkraut", "Überragender Manatrank 205-240 (Khadgars Schnurrbart, Golddorn), Trank Untote entdecken 240-260 (Arthas' Tränen), Überragender Manatrank 260-270 (Sonnengras, Blindkraut; Rezept Algernon), Großer Verfärbter Heiltrank 270-300 (Pestblüte, Murlocauge; Questreihe bei Apotheker Renferrel, Silberwald)" },
    },
    hints = {
      { 1,   300, "Heiltränke stellt in Forever die Erste Hilfe her, nicht mehr die Alchemie." },
      { 50,  75,  "Geselle: Skill 50, Lvl 10, Lehrer in jeder Hauptstadt." },
      { 125, 150, "Experte: Skill 125, Lvl 20, Lehrer in Undercity." },
      { 200, 225, "Artisan: Skill 200, Lvl 35, Lehrer in Stonard (Sümpfe des Elends)." },
      { 225, 300, "Ab 225 ungetestet. Rezepte ab etwa 270 kommen aus dem AH oder gegen Zandalar-Ruf." },
    },
  },
  schmied = {
    label = "Schmiedekunst",
    names = { ["Blacksmithing"] = true, ["Schmiedekunst"] = true },
    phases = {
      { 1,   75,  "Rauer & Grober Stein",     "Wetz- und Schleifsteine; Steine abbauen (Bergbau passt perfekt), Schmiedehammer kaufen" },
      { 75,  150, "Kupfer- & Bronzebarren",    "Kupfer-, Bronzebarren, Schwerer Stein, Mittleres Leder; Flussmittel beim Händler" },
      { 150, 215, "Bronze, Eisen, Stahl, Mithril", "Grüner Farbstoff beim Händler; Stahl ab Bergbau 165; wenn Mithril teuer ist: Stahl-Brustplatte" },
      { 215, 240, "Mithrilbarren",            "Schwere Mithril-Brustplatte 215-225 (160 Barren), Dichter Wetzstein 225-230, Schwere Mithril-Stiefel bis 240 (224 Barren, 64 Dickes Leder)" },
      { 240, 301, "Thoriumbarren",            "Wowhead (4.11.): Ebon Shiv 257-270 (Magnus Frostwake), Bold Dirk 270-275, Ornate Thorium Handaxe 275-279, Bold Dirk 279-300 (720 Thoriumbarren, 96 Wesen der Luft, 240 Azerothium). Alternative (wow-professions): Kaiserlicher Plattengürtel 240-245, Armschienen 245-270, Stiefel 270-290, Beinschienen 290-300 (Quests evtl. erst ab 265). Beides ungetestet" },
    },
    hints = {
      { 1,   75,  "Schmiedehammer kaufen, er wird ab Skill 67 gebraucht." },
      { 50,  75,  "Geselle: Skill 50, Lvl 10, Lehrer in den Hauptstädten." },
      { 125, 150, "Experte: Skill 125, Lvl 20, 50 Silber (Orgrimmar oder Eisenschmiede)." },
      { 200, 225, "Artisan: Skill 200, Lvl 35, Brikk Keencraft in Booty Bay." },
      { 225, 300, "Ab 225 laut Guide ungetestet (Quest für 240-245 evtl. anders als in Classic). Classic-Schwellen gelten nicht." },
    },
  },
  ingenieur = {
    label = "Ingenieurskunst",
    names = { ["Engineering"] = true, ["Ingenieurskunst"] = true },
    phases = {
      { 1,   50,  "Steine & Kupfer",          "Raues Sprengpulver (1-30), Kupferbolzen (30-50); Bergbau passt gut dazu" },
      { 50,  150, "Kupfer, Bronze, Silber",   "Raue Kupferbomben, Grobes Sprengpulver, Dynamit, Silberkontakte, Bronzerohre, Zielfernrohre, Schweres Sprengpulver" },
      { 150, 200, "Bronze, Eisen, Stein",     "Bronzerahmen, Explosive Schafe, Robustes Sprengpulver (Beta: Eisengranaten), Mithrilrohre" },
      { 200, 301, "Mithril & Thorium",        "Mithrilrohre 195-200, Auslöser 200-215, Mithrilgehäuse 215-238, Hochexplosive Bomben 238-250, Dichtes Sprengpulver 250-260, Thorium-Gadget 260-285 (Schema: Sovik), Thoriumrohr 285-300 (Schema: Xizzer Fizzbolt)" },
    },
    hints = {
      { 1,   50,  "Schmiedehammer kaufen. Flussmittel gibt es beim Ingenieur-Händler beim Lehrer." },
      { 50,  75,  "Geselle: Skill 50, Lvl 10 (Orgrimmar, Undercity, ...)." },
      { 125, 150, "Experte: Skill 125, Lvl 20, 50 Silber, Roxxik in Orgrimmar." },
      { 200, 225, "Artisan: Skill 200, Lvl 35, Buzzek Bracketswing in Tanaris. Spezialisierung (Gnom/Goblin) ab Skill 200 und Lvl 30." },
      { 225, 300, "Ab 225 ungetestet. Schema für Thoriumrohre gibt es in Everlook (Winterquell), bindet beim Aufheben." },
    },
  },
  schneider = {
    label = "Schneiderei",
    names = { ["Tailoring"] = true, ["Schneiderei"] = true },
    phases = {
      { 1,   55,  "Leinenstoff",             "Ballen Leinenstoff (1-30), Leinengürtel (30-55); Fäden und Farbstoffe beim Händler" },
      { 55,  125, "Wollstoff & Seide",       "Ballen Wollstoff (55-80), Wollumhänge (80-95), Ballen Seidenstoff (100-120), Handschuhe der Meditation" },
      { 125, 225, "Seide & Magiestoff",      "Purpurseidenwesten/-hosen, Schwarze Magiestoffhandschuhe, Magiestofftaschen; Magiestoff ist in der Beta selten (AH)" },
      { 225, 265, "Runenstoff",              "Runenstoffgürtel bis 234, Runenstoffumhang 234-250 (Muster: Darnall), Runenstoffstiefel 250-260 (Darnall), Runenstoffbündchen 260-280 (Muster: Pexmit); Ironweb-Spinnenseide und Runenfaden nötig" },
      { 265, 301, "Timbermaw & Giftspei",    "Weisheit der Timbermaw 280-285 (Muster: Meilosh), Giftspei-Handschuhe 285-292, -Gürtel 292-299, -Fußpolster 299-300 (Muster: Mishta); Essenzen der Luft/Erde und Kleine Schillernde Splitter nötig" },
    },
    hints = {
      { 50,  75,  "Geselle: Skill 50, Lvl 10, z.B. Magar oder Tepa (Horde). Ohne Geselle gibt es ab 75 keine Skillpunkte." },
      { 125, 150, "Experte: Skill 125, Lvl 20, 50 Silber, Josef Gregorian in Undercity." },
      { 200, 225, "Artisan: Skill 200, Lvl 35, Daryl Stack in Tarrens Mühle." },
      { 140, 225, "Magiestoff ist selten: Ballen im AH kaufen. Handschuhe der Meditation brauchen ein Elixier der Weisheit." },
      { 225, 300, "Classic-Routen taugen nicht: Rezepte werden 25-45 Punkte früher grau." },
    },
  },
  verzauber = {
    label = "Verzauberkunst",
    gather = true,
    names = { ["Enchanting"] = true, ["Verzauberkunst"] = true },
    phases = {
      { 1,   70,  "Motes & Essenzen",         "Runenkupferstab, Minderwertige Ausdauer (Armschienen) 2-20; danach Geringe Magieessenz oder Seltsamer Staub" },
      { 70,  150, "Seelenstaub",              "Geringe Absorption (Brust) 70-110, Runensilberstab, Geringe Intelligenz (2H) 110-150" },
      { 150, 225, "Stäbe, Öle, Verteidigung", "Runengoldstab, Kleines Manaöl, Geringe Beweglichkeit, Stärke, Geringes Zauberöl, Große Verteidigung (Umhang)" },
      { 225, 301, "Visionen- & Traumstaub",   "Handschuhe: Beweglichkeit 225-230, Stiefel: Ausdauer 230-235, Brust: Überragende Ausdauer 235-250 (Visionenstaub), Geringes Manaöl 250-265 (Formel: Lokhtos Darkbargainer), Schild: Große Ausdauer 265-294 (Traumstaub, Formel: Daniel Bartlett), Runenarkanitstab 294-295, Umhang: Überragende Verteidigung 295-300 (Trugstaub)" },
    },
    hints = {
      { 1,   300, "Dieser Tab zeigt nur den Weg. Die Verzauberungen selbst liest das Addon nicht aus. Stäbe stellt ein Schmied her." },
      { 50,  75,  "Geselle: Skill 50, Lvl 10, z.B. Godan in Orgrimmar." },
      { 125, 150, "Experte: Skill 125, Lvl 20, 50 Silber, Hgarth (Steinkrallengebirge, Horde)." },
      { 200, 225, "Artisan: Skill 200, Lvl 35, nur Annora in Uldaman (am besten mit Gruppe)." },
    },
  },
  bergbau = {
    label = "Bergbau",
    gather = true,
    names = { ["Mining"] = true, ["Bergbau"] = true },
    phases = {
      { 1,   65,  "Kupfer",                 "Durotar (Höhle mit 5 Kupfervorkommen), alternativ Mulgore oder Tirisfal; Schmelzen in Razor Hill" },
      { 65,  125, "Zinn & Silber",          "Zinn ab 65, Silber ab 75: Silberwald-Höhle, Vorgebirge des Hügellands, Brachland, Eschental, Steinkrallengebirge" },
      { 125, 175, "Eisen & Gold",           "Eisen ab 125, Gold ab 155: Tausend Nadeln (sicherer), Arathihochland, Desolace" },
      { 175, 245, "Mithril & Echtsilber",   "Mithril ab 175, Echtsilber ab 230: Hinterland, Tanaris; hochstufige Höhlen meiden" },
      { 245, 275, "Thorium",                "Kleines Thoriumvorkommen ab 245: Krater von Un'Goro, Verwüstete Lande (Horde: Garnison-Waffenkammer), Teufelswald" },
      { 275, 301, "Reiches Thorium",        "Ab 275: Krater von Un'Goro, Östliche Pestländer, Winterquell, Brennende Steppe" },
    },
    hints = {
      { 1,   75,  "Bergbauspitzhacke kaufen. Der Starterlehrer bildet nur bis 75 aus, danach Krunn in Razor Hill." },
      { 1,   105, "Schmelzen ist optional und kostet Gold. Ab 120 lieber direkt abbauen." },
      { 50,  75,  "Geselle: Skill 50." },
      { 125, 150, "Experte: Skill 125." },
      { 155, 175, "Gold schmelzen kannst du ab Skill 155 lernen." },
      { 200, 225, "Artisan: Skill 200, vor der Weiterreise lernen." },
    },
  },
  kraeuter = {
    label = "Kräuterkunde",
    gather = true,
    names = { ["Herbalism"] = true, ["Kräuterkunde"] = true },
    phases = {
      { 1,   70,  "Friedensblume, Silberblatt, Erdwurzel", "Durotar (Erdwurzel ab Skill 15)" },
      { 70,  115, "Maguskönigskraut, Wilddornrose, Würgetang",  "Silberwald, Loch Modan, Dunkelküste (Würgetang ab 85)" },
      { 115, 170, "Beulengras, Wildstahlblume, Königsblut, Lebenswurz", "Vorgebirge des Hügellands, Steinkrallengebirge (Königsblut ab 125, Lebenswurz ab 150)" },
      { 170, 205, "Blassblatt, Golddorn, Khadgars Schnurrbart", "Schlingendorntal, Arathihochland (Schnurrbart ab 185)" },
      { 205, 230, "Lila Lotus, Feuerblüte",                "Tanaris, Sengende Schlucht" },
      { 230, 270, "Sonnengras, Geisterpilz, Goldener Sansam", "Hinterland (Geisterpilz ab 245)" },
      { 270, 301, "Gromsblut, Traumblatt, Bergsilberweisling, Pestblüte", "Teufelswald" },
    },
    hints = {
      { 1,   75,  "Lehrer: Mishiki in Sen'jin; Zor'la im Tal der Prüfungen nur bis 75, danach Jandi in Orgrimmar." },
      { 1,   300, "Kräuter finden ist standardmäßig aus: in den Berufseinstellungen einschalten und nach jedem Tod neu aktivieren." },
      { 50,  75,  "Geselle: Skill 50 beim Lehrer in der Hauptstadt." },
      { 125, 150, "Experte: Skill 125." },
      { 200, 225, "Artisan: Skill 200. Vor Tanaris oder der Sengenden Schlucht lernen, dort gibt es keinen Lehrer." },
      { 170, 300, "Die Route ab 170 ist in der Beta nicht geprüft." },
    },
  },
  angeln = {
    label = "Angeln",
    gather = true,
    names = { ["Fishing"] = true, ["Angeln"] = true },
    phases = {
      { 1,   75,  "Starterzonen",   "Durotar, Mulgore, Tirisfal oder Zephras; Angel und Glitzerköder beim Händler" },
      { 75,  150, "Geselle",        "Brachland, Silberwald oder Hauptstädte; Nachtkriecher helfen ab Skill 50, wenn Fische entkommen" },
      { 150, 225, "Experte",        "Düstermarschen (empfohlen), Tausend Nadeln, Schlingendorntal; Helle Köder in Booty Bay kaufen" },
      { 225, 301, "Artisan",        "Teufelswald, Feralas, Hinterland, Tanaris, Krater von Un'Goro, Westliche Pestländer; Helle Köder verwenden" },
    },
    hints = {
      { 50,  75,  "Geselle: Skill 50, Lvl 10 beim Lehrer." },
      { 125, 150, "Experte: Skill 125, Lvl 20. Das Buch verkauft Old Man Heming in Booty Bay (oder AH)." },
      { 200, 225, "Artisan (ab 225 nötig): Lvl 35, Quest 'Nat Pagle, Angler Extreme' in den Düstermarschen: 4 Fische aus Feralas, Sümpfe des Elends, Desolace und Schlingendorntal." },
    },
  },
}

-- Berufsname (EN + DE) -> Schluessel, nur fuer Berufe mit Rezeptfenster
ns.profs = {}
for key, d in pairs(ns.defs) do
  if not d.gather then
    for n in pairs(d.names) do ns.profs[n] = key end
  end
end

-- Materialien: Gewicht und Fundort kommen aus MaterialData.lua (nach Item-ID, sprachunabhaengig).
-- Gewicht: Haendlerware 0.3, sonst grob nach Seltenheit (1 = billig, 5 = teuer).
local tier = {
  [2318] = 1, [2319] = 2, [4234] = 3, [4304] = 4, [8170] = 5,      -- Leder
  [2589] = 1, [2592] = 2, [4306] = 3, [4338] = 4, [14047] = 5,     -- Stoffe
}
-- Dinge, die die Datenbank nicht kennt (Beute): kurze Hinweise
local extra = {
  [2318] = "Kürschnern (Tiere Lvl 1-20) oder Auktionshaus", [2319] = "Kürschnern (Tiere Lvl 20-30) oder Auktionshaus",
  [4234] = "Kürschnern (Tiere Lvl 30-40) oder Auktionshaus", [4304] = "Kürschnern (Tiere Lvl 40-50) oder Auktionshaus",
  [8170] = "Kürschnern (Tiere Lvl 50-60) oder Auktionshaus",
  [2589] = "Beute von Humanoiden (Lvl 1-20) oder Auktionshaus", [2592] = "Beute von Humanoiden (Lvl 15-30) oder Auktionshaus",
  [4306] = "Beute von Humanoiden (Lvl 30-45) oder Auktionshaus", [4338] = "Beute von Humanoiden (Lvl 40-55), selten - Auktionshaus",
  [14047] = "Beute von Humanoiden (Lvl 50-60) oder Auktionshaus",
}
function ns.WeightOf(id)
  if not id then return 1 end
  if tier[id] then return tier[id] end
  local m = ns.mat and ns.mat[id]
  return m and m[1] or 1
end
function ns.SourceOf(id)
  if not id then return nil end
  local m = ns.mat and ns.mat[id]
  local s = m and m[2] ~= "" and m[2] or nil
  if extra[id] then s = extra[id] .. (s and (" | " .. s) or "") end
  return s
end

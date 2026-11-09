local ADDON, ns = ...

-- Berufsquests, GENERIERT aus der Forever-Datenbank von QuestieDB (Texte teils von Hand).
-- Eintrag: { Skill ab, Fraktion (H/A/B=beide), Quest, Questgeber, Zone, Aufgabe, uiMapID, x, y }
ns.quests = {
  leder = {
    { 1, "H", "Bestien des Donnergrats", "Kamari", "Orgrimmar", "Lvl 6: Benötigt/abzugeben: Raue Echsenhaut, Geschmeidiger leichter Balg.", 1454, 63.3, 44.8 },
    { 10, "H", "Kodobalgtasche", "Veren Tallstrider", "Donnerfels", "4 Leichtes Leder + 4 Grober Faden, gibt Rezept.", 1456, 44.4, 44.7 },
    { 90, "A", "Mondscheinweste", "Lotherias", "Darnassus", "Lvl 8: Benötigt/abzugeben: Geprägte Lederhandschuhe, Geprägte Lederstiefel, Geprägter Lederumhang.", 1457, 64.4, 22.2 },
    { 200, "A", "Wildlederrüstung", "Pratt McGrubben", "Feralas", "Lvl 30: 10 Dickes Leder abgeben, danach Wildleder-Teile herstellen und abgeben (Weste, Helm, Schultern, Stiefel, Gamaschen).", 1444, 30.6, 42.7 },
    { 200, "H", "Wildlederrüstung", "Jangdor Swiftstrider", "Feralas", "Lvl 30: 10 Dickes Leder abgeben, danach Wildleder-Teile herstellen und abgeben (Weste, Helm, Schultern, Stiefel, Gamaschen).", 1444, 74.4, 42.9 },
    { 225, "A", "Drachenlederverarbeitung", "Peter Galen", "Azshara", "Spezialisierung (Lvl 40). SCHLIESST Elementar- und Stammesleder aus! Abgeben: 2 Feste Skorpidbrustplatten, 2 Feste Skorpidhandschuhe, 10 Abgenutzte Drachenschuppen.", 1447, 37.6, 65.4 },
    { 225, "A", "Elementarlederverarbeitung", "Sarah Tanner", "Sengende Schlucht", "Spezialisierung (Lvl 40). SCHLIESST Drachen- und Stammesleder aus! Abgeben: je 2 Herz des Feuers, Kugel des Wassers, Erdenkern, Odem des Windes.", 1427, 63.6, 76.0 },
    { 225, "A", "Meister des Wildleders", "Pratt McGrubben", "Feralas", "Lvl 30: Give Pratt's Letter to Telonis, the master leatherworker of Darnassus.", 1444, 30.6, 42.7 },
    { 225, "A", "Stammeslederverarbeitung", "Caryssia Moonhunter", "Feralas", "Spezialisierung (Lvl 40). SCHLIESST Drachen- und Elementarleder aus! Herstellen und abgeben: Wildlederweste + Wildlederhelm.", 1444, 89.4, 46.5 },
    { 225, "H", "Drachenlederverarbeitung", "Thorkaf Dragoneye", "Ödland", "Spezialisierung (Lvl 40). SCHLIESST Elementar- und Stammesleder aus! Abgeben: 2 Feste Skorpidbrustplatten, 2 Feste Skorpidhandschuhe, 10 Abgenutzte Drachenschuppen.", 1418, 62.7, 57.4 },
    { 225, "H", "Elementarlederverarbeitung", "Brumn Winterhoof", "Arathihochland", "Spezialisierung (Lvl 40). SCHLIESST Drachen- und Stammesleder aus! Abgeben: je 2 Herz des Feuers, Kugel des Wassers, Erdenkern, Odem des Windes.", 1417, 28.3, 45.1 },
    { 225, "H", "Meister des Wildleders", "Jangdor Swiftstrider", "Feralas", "Lvl 30: Give Jangdor's Letter to Una, the master leatherworker of Thunder Bluff.", 1444, 74.4, 42.9 },
    { 225, "H", "Stammeslederverarbeitung", "Se'Jib", "Schlingendorntal", "Spezialisierung (Lvl 40). SCHLIESST Drachen- und Elementarleder aus! Herstellen und abgeben: Wildlederweste + Wildlederhelm.", 1434, 36.5, 34.1 },
    { 300, "A", "Die Reise beginnt erst", "Major Mattingly", "Sturmwind", "Lvl 60.", 1453, 67.2, 85.5 },
    { 300, "H", "Die Reise beginnt erst", "Oberanführer Runthak", "Orgrimmar", "Lvl 60.", 1454, 51.7, 75.5 },
  },
  skin = {
    { 1, "A", "Raue Wolfspelze", "Helene Peltskinner", "Wald von Elwynn", "Lvl 5: Benötigt/abzugeben: Rauer Wolfspelz.", 1429, 46.2, 62.2 },
    { 1, "H", "Leder sammeln", "Veren Tallstrider", "Donnerfels", "12 Leichtes Leder abgeben.", 1456, 44.4, 44.7 },
    { 200, "A", "Salbe durch Kürschnerei", "Arathandris Silversky", "Teufelswald", "Lvl 48: Benötigt/abzugeben: Besudelter Hautfetzen.", 1448, 54.1, 86.8 },
    { 200, "H", "Salbe durch Kürschnerei", "Maybess Riverbreeze", "Teufelswald", "Lvl 48: Benötigt/abzugeben: Besudelter Hautfetzen.", 1448, 46.8, 83.1 },
  },
  kochen = {
    { 1, "A", "Rezept der Kaldorei", "Zarrin", "Teldrassil", "Lvl 1: Benötigt/abzugeben: Kleines Spinnenbein.", 1438, 57.1, 61.3 },
    { 1, "H", "Milde Schildkrötensuppe", "Christoph Jeffcoat", "Vorgebirge des Hügellands", "Lvl 28: 10 Schildkrötenfleisch + Feine Gewürze, gibt Rezept.", 1424, 62.3, 19.0 },
    { 10, "A", "Schreitereintopf", "Alanndarian Nightsong", "Dunkelküste", "Lvl 9: Benötigt/abzugeben: Schreiterfleisch.", 1439, 37.7, 40.7 },
    { 15, "H", "Grubenratteneintopf", "Grub", "Brachland", "8 Grubenratten abgeben, gibt Rezept.", 1413, 55.3, 31.8 },
    { 50, "A", "Gewürzter Wolfskebab", "Küchenchef Grual", "Dämmerwald", "Lvl 18: Benötigt/abzugeben: Magere Wolfflanke, Würzkräuter aus Stormwind.", 1431, 73.8, 43.5 },
    { 225, "A", "Ich kenne einen Typen...", "Daryl Riknussun", "Eisenschmiede", "Artisan-Kochen: Weiter zu Dirge Quikcleave in Gadgetzan (Quest Muschelette Surprise).", 1455, 60.1, 36.4 },
    { 225, "B", "Muschelette Surprise", "Dirge Quikcleave", "Tanaris", "Artisan-Quest (Lvl 35): 12 Riesenei, 10 Scharfes Muschelfleisch, 20 Alteraclochkäse.", 1446, 52.6, 28.1 },
    { 225, "H", "Ab mit Euch nach Gadgetzan!", "Zamja", "Orgrimmar", "Artisan-Kochen: Weiter zu Dirge Quikcleave in Gadgetzan (Quest Muschelette Surprise).", 1454, 57.4, 54.0 },
    { 285, "B", "Wüstenrezept", "Calandrath", "Silithus", "Lvl 54: Look for information about cooking Sandworm Meat at the Twilight's Hammer camp west of Cenarion Hold.", 1451, 51.9, 39.2 },
    { 285, "B", "Küchengehilfe", "Calandrath", "Silithus", "Lvl 54: Benötigt/abzugeben: Geräucherte Wüstenknödel.", 1451, 51.9, 39.2 },
    { 285, "B", "Geteiltes Wissen", "Calandrath", "Silithus", "Lvl 54: Bring the Torn Recipe Page to Calandrath at the inn in Cenarion Hold.", 1451, 51.9, 39.2 },
    { 300, "A", "Der Held des Tages", "Wulmort Jinglepocket", "Eisenschmiede", "Lvl 40: 1 Tiefsteinsalz + 5 Gold -> Gepökelte Stechpalme.", 1455, 33.7, 67.2 },
    { 300, "H", "Der Held des Tages", "Kaymard Copperpinch", "Orgrimmar", "Lvl 40: 1 Tiefsteinsalz + 5 Gold -> Gepökelte Stechpalme.", 1454, 53.3, 66.5 },
  },
  ersthilfe = {
    { 225, "A", "Traumachirurg der Allianz", "Nissa Firestone", "Eisenschmiede", "Artisan-Erste-Hilfe: Weiter zu Doktor Gustaf Van Howzen (Düstermarschen), dann Quest Triage.", 1455, 55.1, 58.3 },
    { 225, "A", "Triage", "Doktor Gustaf Van Howzen", "Düstermarschen", "Artisan-Quest (Lvl 35): 15 Patienten retten, bevor 6 sterben. Erst kritisch, dann schwer, dann leicht Verletzte.", 1445, 67.8, 49.0 },
    { 225, "H", "Traumachirurg der Horde", "Arnok", "Orgrimmar", "Artisan-Erste-Hilfe: Weiter zu Doktor Gregory Victor in Hammerfall (Arathihochland), dann Quest Triage.", 1454, 34.2, 84.6 },
    { 225, "H", "Triage", "Doktor Gregory Victor", "Arathihochland", "Artisan-Quest (Lvl 35): 15 Patienten retten, bevor 6 sterben. Erst kritisch, dann schwer, dann leicht Verletzte.", 1417, 73.4, 36.9 },
  },
  alchemie = {
    { 1, "A", "Mein erstes Alchimieset", "Seltsames Kind", "Westfall", "Lvl 10: Benötigt/abzugeben: Leere Phiole, Friedensblume, Silberblatt.", 1436, 42.8, 72.8 },
    { 1, "A", "Mein erster echter Trank", "Seltsames Kind", "Westfall", "Lvl 10: Benötigt/abzugeben: Murlocauge.", 1436, 42.8, 72.8 },
    { 20, "A", "Elixiere für die Bladeleafs", "Syral Bladeleaf", "Teldrassil", "Lvl 4: Benötigt/abzugeben: Elixier der Löwenstärke, Elixier der schwachen Verteidigung.", 1438, 56.1, 57.7 },
    { 210, "A", "Reagenzien-Suche im Ödland II", "Ghak Healtouch", "Loch Modan", "Lvl 40: Leere Gefäße an Feuerdrachen im Ödland füllen.", 1432, 37.1, 49.4 },
    { 210, "H", "Reagenzien-Suche im Ödland II", "Jarkal Mossmeld", "Ödland", "Lvl 40: Leere Gefäße an Feuerdrachen im Ödland füllen.", 1418, 2.4, 46.1 },
  },
  schmied = {
    { 1, "H", "Hörner der Raserei", "Orokk Omosh", "Orgrimmar", "Lvl 32: Benötigt/abzugeben: Robuster Eisenschlägel, Bronzene Stiefel mit Versilberung, Bronzene Stulpen mit Versilberung.", 1454, 79.2, 22.4 },
    { 1, "H", "Freude der Omoshs", "Orokk Omosh", "Orgrimmar", "Lvl 32: Watch and learn the Omosh Dance of Joy.", 1454, 79.2, 22.4 },
    { 1, "H", "Über Eisenschulterstücke", "Orokk Omosh", "Orgrimmar", "Lvl 32: Benötigt/abzugeben: Bronzene Streitaxt, Bronzener Kriegshammer.", 1454, 79.2, 22.4 },
    { 1, "H", "Vom Stachel zur Axt", "Ug'thok", "Orgrimmar", "Lvl 6: Benötigt/abzugeben: Verwitterter Stachel, Rauer Schleifstein.", 1454, 80.8, 23.7 },
    { 1, "H", "In den Boden getrampelt", "Orokk Omosh", "Orgrimmar", "Lvl 32: Benötigt/abzugeben: Grüner Eisenhelm, Grüne Eisenarmschienen, Grüne Eisengamaschen.", 1454, 79.2, 22.4 },
    { 30, "A", "Nachschub für die Front", "Tormus Deepforge", "Eisenschmiede", "Lvl 1: Benötigt/abzugeben: Kupferaxt, Kupferner Kettengürtel.", 1455, 48.6, 42.5 },
    { 60, "A", "Die Aufrüstung im Rotkammgebirge", "Tormus Deepforge", "Eisenschmiede", "Lvl 1: Benötigt/abzugeben: Runenverzierter Kupfergürtel, Schwerer Kupferschlägel.", 1455, 48.6, 42.5 },
    { 140, "H", "Barbarische Waffenschmiedekunst", "Orokk Omosh", "Orgrimmar", "Lvl 32: Benötigt/abzugeben: Gemusterte bronzene Armschienen, Bronzenes Großschwert, Scharfe Klaue.", 1454, 79.2, 22.4 },
    { 200, "A", "Die Kunst des Rüstungsschmiedes", "Grumnus Steelshaper", "Eisenschmiede", "Rüstungsschmied (Lvl 40): 4 Verschnörkelte Mithrilhelme, 2 Verschn. Mithrilstiefel, 1 Verschn. Mithrilbrustplatte herstellen.", 1455, 50.0, 42.8 },
    { 200, "A", "Der Weg des Waffenschmieds...", "Ironus Coldsteel", "Eisenschmiede", "Waffenschmied (Lvl 40): 4 Mondstahlbreitschwerter, 4 Massive Eisenäxte, 2 Schwere Mithrilaxt, 2 Große schwarze Streitkolben herstellen.", 1455, 50.3, 43.6 },
    { 200, "H", "Die Kunst des Rüstungsschmiedes", "Okothos Ironrager", "Orgrimmar", "Rüstungsschmied (Lvl 40): 4 Verschnörkelte Mithrilhelme, 2 Verschn. Mithrilstiefel, 1 Verschn. Mithrilbrustplatte herstellen.", 1454, 79.8, 24.1 },
    { 200, "H", "Der Weg des Waffenschmieds...", "Borgosh Corebender", "Orgrimmar", "Waffenschmied (Lvl 40): 4 Mondstahlbreitschwerter, 4 Massive Eisenäxte, 2 Schwere Mithrilaxt, 2 Große schwarze Streitkolben herstellen.", 1454, 79.4, 23.7 },
    { 210, "A", "Auf der Suche nach Galvan", "Hank der Hammer", "Sturmwind", "Lvl 40: Speak with McGavan in Booty Bay.", 1453, 62.9, 36.8 },
    { 210, "A", "Die Herkunft der Schmiedekunst", "Hank der Hammer", "Sturmwind", "Lvl 40: Benötigt/abzugeben: Goldene Schuppenarmschienen.", 1453, 62.9, 36.8 },
    { 210, "B", "Ein schlauer Kopf auf den Schultern", "Trenton Lighthammer", "Tanaris", "Lvl 40: Benötigt/abzugeben: Mithrilhelmkappe, Verschnörkelte Mithrilschulter.", 1446, 51.4, 28.8 },
    { 210, "B", "Habt Ihr das verloren?", "Trenton Lighthammer", "Tanaris", "Lvl 40: Wait for Trenton to finish his work.", 1446, 51.4, 28.8 },
    { 210, "B", "Schmiedkunstexperte!", "Galvan der Alte", "Schlingendorntal", "Lvl 40: Claim your reward from Galvan the Ancient!", 1434, 50.6, 20.5 },
    { 210, "B", "Galvans bester Schüler", "Galvan der Alte", "Schlingendorntal", "Lvl 40: Speak with Trenton Lighthammer in Gadgetzan.", 1434, 50.6, 20.5 },
    { 210, "B", "Hier verhütten, da verhütten", "Galvan der Alte", "Schlingendorntal", "Je 40 Mithrilbarren + 40 Eisenbarren (Galvan, Experte).", 1434, 50.6, 20.5 },
    { 210, "B", "Die Kunst der Magieerfüllung", "Galvan der Alte", "Schlingendorntal", "40 Mithrilbarren + 4 Citrin (Galvan, Experte).", 1434, 50.6, 20.5 },
    { 210, "B", "Der große silberne Betrüger", "Galvan der Alte", "Schlingendorntal", "40 Mithrilbarren + 5 Echtsilberbarren (Galvan, Experte).", 1434, 50.6, 20.5 },
    { 210, "B", "Mithril-Kid", "Trenton Lighthammer", "Tanaris", "Lvl 40: Benötigt/abzugeben: Schwere Mithrilbrustplatte, Verschnörkelte Mithrilhandschuhe.", 1446, 51.4, 28.8 },
    { 210, "B", "Der Mithrilorden", "McGavan", "Schlingendorntal", "Lvl 40: Speak with Galvan the Ancient in Stranglethorn Vale.", 1434, 28.9, 75.4 },
    { 210, "B", "Die Welt zu Euren Füßen", "Trenton Lighthammer", "Tanaris", "Lvl 40: Benötigt/abzugeben: Schwere Mithrilstiefel, Verschnörkelte Mithrilhose.", 1446, 51.4, 28.8 },
    { 210, "H", "Auf nach Booty Bay!", "Ochse", "Orgrimmar", "Weiter zu McGavan in Booty Bay, dann zu Galvan dem Alten (Schlingendorntal).", 1454, 80.5, 23.5 },
    { 210, "H", "Die alten Traditionen", "Aturk der Amboss", "Orgrimmar", "Experte Schmiedekunst: 4 Stahlbrustplatten + 4 Stahlplattenhelme, dann Booty Bay (McGavan) und Galvan der Alte.", 1454, 80.9, 23.3 },
    { 250, "B", "Verderbnis", "Seril Scourgebane", "Winterquell", "Lvl 50: Stratholme – Schwarzgardisten-Schwertschmied töten, Insignien bringen.", 1452, 61.3, 37.2 },
    { 250, "B", "Schlangenstein der Schattenjägerin", "Kilram", "Winterquell", "Lvl 50: Schwarzfelsspitze – Schattenjägerin Vosh'gajin töten, Schlangenstein bringen.", 1452, 61.3, 37.1 },
    { 250, "B", "Süße Beschaulichkeit", "Lilith die Liebliche", "Winterquell", "Lvl 50: Stratholme – Purpurroten Hammerschmied töten, Schürze mitbringen.", 1452, 61.3, 37.1 },
    { 265, "B", "Ein Sonderangebot", "Derotain Mudsipper", "Tanaris", "Imperiale Platte (Lvl 50): Thoriumbarren für Gürtel, Stiefel, Armschienen, Brustplatte, Helm, Gamaschen, Schultern.", 1446, 51.4, 28.7 },
    { 270, "B", "Heißer, feuriger Tod", "Malyfous Darkhammer", "Winterquell", "Lvl 55: Someone in this world must know what to do with these gauntlets. Good luck!", 1452, 61.0, 38.8 },
    { 270, "B", "Lorax' Geschichte", "Lorax", "Winterquell", "Lvl 55: Speak with Lorax. Listen to what he has to say.", 1452, 63.8, 73.8 },
    { 270, "B", "Die Dämonenschmiede", "Lorax", "Winterquell", "Lvl 55: Benötigt/abzugeben: Seelenbefleckte Pike, Ungeschmiedete runenbedeckte Brustplatte.", 1452, 63.8, 73.8 },
    { 275, "B", "Feurige Plattenstulpen", "Malyfous Darkhammer", "Winterquell", "Lvl 55: 6 Verzauberte Thoriumbarren, 2 Essenz des Feuers, 4 Sternrubine + Ungebrannte Plattenstulpen.", 1452, 61.0, 38.8 },
  },
  ingenieur = {
    { 1, "A", "Die Ernter ernten", "Ozwin Ironsprocket", "Westfall", "Lvl 8: Bring the Precessive Autocognition Assembly to Ozwin Ironsprocket at Saldean's Farm.", 1436, 51.5, 32.3 },
    { 1, "B", "Blitzstrahlbombenanleitung", "Rigglefuzz", "Ödland", "Lvl 30.", 1418, 42.4, 52.9 },
    { 200, "A", "Gnomen-Ingenieurskunst", "Lilliam Sparkspindle", "Sturmwind", "Lvl 30: Handbuch der Ingenieur-Disziplinen zu Tüftlermeister Overspark/Nixx bringen. Goblin oder Gnom ist eine endgültige Wahl!", 1453, 62.1, 30.3 },
    { 200, "A", "Goblin-Ingenieurskunst", "Springspindle Fizzlegear", "Eisenschmiede", "Lvl 30: Handbuch der Ingenieur-Disziplinen zu Nixx Sprocketspring in Gadgetzan bringen. Goblin oder Gnom ist eine endgültige Wahl!", 1455, 68.5, 43.5 },
    { 200, "A", "Mitgliedskarten-Erneuerung", "Tüftlermeister Overspark", "Eisenschmiede", "Lvl 30.", 1455, 69.5, 50.3 },
    { 200, "A", "Zeigt Eure Arbeit", "Tüftlermeister Overspark", "Eisenschmiede", "20 Große Eisenbomben, 20 Robustes Dynamit, 5 Explodierende Schafe abgeben.", 1455, 69.5, 50.3 },
    { 200, "A", "Der Schwur der Geheimhaltung", "Tüftlermeister Overspark", "Eisenschmiede", "Lvl 30: Benötigt/abzugeben: Oversparks unterschriebener Schwur.", 1455, 69.5, 50.3 },
    { 200, "B", "Goblin-Ingenieurskunst", "Tinkerwiz", "Brachland", "Lvl 30: Handbuch der Ingenieur-Disziplinen zu Nixx Sprocketspring in Gadgetzan bringen. Goblin oder Gnom ist eine endgültige Wahl!", 1413, 62.7, 36.3 },
    { 200, "B", "Mitgliedskarten-Erneuerung", "Nixx Sprocketspring", "Tanaris", "Lvl 30.", 1446, 52.5, 27.3 },
    { 200, "B", "Zeigt Eure Arbeit", "Nixx Sprocketspring", "Tanaris", "20 Große Eisenbomben, 20 Robustes Dynamit, 5 Explodierende Schafe abgeben.", 1446, 52.5, 27.3 },
    { 200, "B", "Der Schwur der Geheimhaltung", "Nixx Sprocketspring", "Tanaris", "Lvl 30: Benötigt/abzugeben: Nixx' unterschriebener Schwur.", 1446, 52.5, 27.3 },
    { 200, "H", "Gnomen-Ingenieurskunst", "Graham Van Talen", "Unterstadt", "Lvl 30: Handbuch der Ingenieur-Disziplinen zu Tüftlermeister Overspark/Nixx bringen. Goblin oder Gnom ist eine endgültige Wahl!", 1458, 75.3, 73.1 },
    { 200, "H", "Goblin-Ingenieurskunst", "Graham Van Talen", "Unterstadt", "Lvl 30: Handbuch der Ingenieur-Disziplinen zu Nixx Sprocketspring in Gadgetzan bringen. Goblin oder Gnom ist eine endgültige Wahl!", 1458, 75.3, 73.1 },
    { 200, "H", "Zeigt Eure Arbeit", "Oglethorpe Obnoticus", "Schlingendorntal", "20 Große Eisenbomben, 20 Robustes Dynamit, 5 Explodierende Schafe abgeben.", 1434, 28.4, 76.3 },
    { 200, "H", "Der Schwur der Geheimhaltung", "Oglethorpe Obnoticus", "Schlingendorntal", "Lvl 30: Benötigt/abzugeben: Oglethorpes unterschriebener Schwur.", 1434, 28.4, 76.3 },
    { 250, "B", "Euer eigener Yeti", "Umi Rumplesnicker", "Winterquell", "Lvl 55.", 1452, 60.9, 37.6 },
  },
  schneider = {
    { 230, "B", "Schattenweber", "Nilith Lokrav", "Sengende Schlucht", "Lvl 46: 5 Schattenseiden-Wilderer in der Sengenden Schlucht töten.", 1427, 41.0, 75.0 },
    { 230, "B", "Der Untermarkt", "Nilith Lokrav", "Sengende Schlucht", "Lvl 46: Handelsmeister Kovic + Clunk töten, dann weiter zu Vizzklick in Gadgetzan.", 1427, 41.0, 75.0 },
    { 280, "B", "Hochheiliger Stoff", "Meilosh", "Teufelswald", "Lvl 50: 2 Mondstoff abgeben, belohnt Muster Weisheit der Timbermaw.", 1448, 65.7, 2.8 },
  },
  verzauber = {
    { 1, "A", "Verzaubernde Erkenntnisse", "Kitta Firewind", "Wald von Elwynn", "Lvl 5: Benötigt/abzugeben: Leuchtende Rückstände.", 1429, 64.9, 70.7 },
    { 1, "H", "Ein Dorn im Nacken", "Pa'zula", "Durotar", "Lvl 5: Benötigt/abzugeben: Leuchtende Rückstände.", 1411, 56.7, 73.7 },
    { 200, "A", "Salbe durch Entzauberung", "Arathandris Silversky", "Teufelswald", "Lvl 48: Benötigt/abzugeben: Geringe Netheressenz.", 1448, 54.1, 86.8 },
    { 200, "H", "Salbe durch Entzauberung", "Maybess Riverbreeze", "Teufelswald", "Lvl 48: Benötigt/abzugeben: Geringe Netheressenz.", 1448, 46.8, 83.1 },
  },
  bergbau = {
    { 200, "A", "Salbe durch Bergbau", "Arathandris Silversky", "Teufelswald", "Lvl 48: Benötigt/abzugeben: Besudeltes Vitriol.", 1448, 54.1, 86.8 },
    { 200, "H", "Salbe durch Bergbau", "Maybess Riverbreeze", "Teufelswald", "Lvl 48: Benötigt/abzugeben: Besudeltes Vitriol.", 1448, 46.8, 83.1 },
  },
  kraeuter = {
    { 1, "B", "Wurzelproben", "Mebok Mizzyrix", "Brachland", "Lvl 9: Benötigt/abzugeben: Wurzelprobe.", 1413, 62.4, 37.6 },
    { 200, "A", "Salbe durch Sammlung", "Arathandris Silversky", "Teufelswald", "Lvl 48: Benötigt/abzugeben: Teufelsunhold.", 1448, 54.1, 86.8 },
    { 200, "H", "Salbe durch Sammlung", "Maybess Riverbreeze", "Teufelswald", "Lvl 48: Benötigt/abzugeben: Teufelsunhold.", 1448, 46.8, 83.1 },
  },
  angeln = {
    { 30, "A", "Elektropeller", "Wizbang Cranktoggle", "Dunkelküste", "Lvl 10: Benötigt/abzugeben: Elektropeller.", 1439, 37.0, 44.1 },
    { 30, "A", "Klemm-Muffen", "Wizbang Cranktoggle", "Dunkelküste", "Lvl 10: Benötigt/abzugeben: Klemm-Muffen.", 1439, 37.0, 44.1 },
    { 175, "A", "Könnte ich einen Flugzettel für den Angelwettbewerb bekommen?", "Barrus", "Eisenschmiede", "Lvl 35.", 1455, 28.2, 75.0 },
    { 175, "H", "Könnte ich einen Flugzettel für den Angelwettbewerb bekommen?", "Grinkle", "Orgrimmar", "Lvl 35.", 1454, 53.2, 70.7 },
    { 225, "A", "Ich hab nix mehr!", "Grimnur Stonebrand", "Eisenschmiede", "Grimnur schickt dich weiter zu Nat Pagle (Düstermarschen).", 1455, 48.1, 6.9 },
    { 225, "B", "Nat Pagle, Extremangler", "Nat Pagle", "Düstermarschen", "Artisan-Quest (Lvl 35): Nebelschilf-Mahi-Mahi (Sumpf des Elends), Sar'theris-Barsch (Desolace), Feralas Ahi, Blauwimpel (Schlingendorntal).", 1445, 58.6, 60.1 },
    { 225, "H", "Ihr zu gut", "Lumak", "Orgrimmar", "Lumak schickt dich weiter zu Nat Pagle (Düstermarschen, Insel südlich Theramore).", 1454, 69.8, 29.2 },
  },
}

local function myFaction()
  local f = UnitFactionGroup and UnitFactionGroup("player")
  return (f == "Alliance") and "A" or "H"
end

-- zeigt Quests, die bald (ab Skill-25) bis lange nach Erreichen (Skill+100, Artisan-Quests immer) relevant sind
local function relevant(e, rank, fac)
  if e[2] ~= "B" and e[2] ~= fac then return false end
  if rank < e[1] - 25 then return false end
  return rank <= e[1] + 100 or e[1] >= 200
end

function ns.QuestLines(key, rank)
  local q = ns.quests and ns.quests[key]
  if not q then return {} end
  local fac, L = myFaction(), {}
  for _, e in ipairs(q) do
    if relevant(e, rank, fac) then
      if #L == 0 then L[1] = " "; L[2] = "|cffffd100Berufsquests:|r" end
      local mark = (e[6]:find("ENDGÜLTIG", 1, true) or e[6]:find("SCHLIESST", 1, true) or e[6]:find("endgültige", 1, true)) and " |cffff4040[endgültig]|r" or ""
      if rank >= e[1] then
        L[#L + 1] = ns.fmt("|cff00ff00%s|r%s (ab Skill %d) – %s, %s", e[3], mark, e[1], e[4], e[5])
        L[#L + 1] = "   |cffcccccc" .. e[6] .. "|r"
      else
        L[#L + 1] = ns.fmt("|cffffff00Bald: %s|r (ab Skill %d) – %s, %s", e[3], e[1], e[4], e[5])
        L[#L + 1] = "   |cff999999" .. e[6] .. "|r"
      end
    end
  end
  return L
end

-- Wegpunkt-Buttons zu den Questgebern (max. 6)
function ns.QuestActions(key, rank)
  local q = ns.quests and ns.quests[key]
  local out = {}
  if not q then return out end
  local fac, seen = myFaction(), {}
  for _, e in ipairs(q) do
    if relevant(e, rank, fac) and #out < 6 then
      local id = e[4] .. e[8] .. e[9]
      if not seen[id] then
        seen[id] = true
        local loc = { e[7], e[8], e[9], e[4] .. " (" .. e[3] .. ")" }
        out[#out + 1] = { text = ns.fmt("Quest: %s – %s", e[4], e[3]), fn = function() ns.GoToLoc(loc) end }
      end
    end
  end
  return out
end

-- Endgueltige Entscheidungen und teure Fehlkaeufe: { von, bis, Warnung } (rot angezeigt)
ns.warnings = {
  leder = {
    { 205, 300, "Spezialisierung (Drachen-, Elementar- oder Stammesleder) ist ENDGÜLTIG und schließt die anderen aus. Erst entscheiden, wenn du weißt, welche Rezepte du wirklich willst (Quest ab Skill 225, Lvl 40)." },
    { 235, 300, "Muster für Boshafte Lederstulpen und Skorpidhelm kosten Gold: vorher Skillpunkte und Material (Runenfaden, Schwarzer Farbstoff, Skorpidschuppen) einplanen." },
  },
  ingenieur = {
    { 190, 300, "Goblin- oder Gnomen-Ingenieurskunst (ab Skill 200, Lvl 30) ist ENDGÜLTIG. Nach der Wahl kannst du nur noch eine der beiden Richtungen lernen." },
  },
  schmied = {
    { 190, 300, "Rüstungs- oder Waffenschmied (ab Skill 200, Lvl 40) ist ENDGÜLTIG. Die Spezialisierung verlangt viele hergestellte Teile: Material vorher zusammenstellen." },
  },
  kochen = {
    { 215, 300, "Artisan-Quest erst starten, wenn Riesenei, Muschelfleisch und Käse im Beutel sind (Reise nach Gadgetzan)." },
  },
  ersthilfe = {
    { 215, 240, "Triage ist zeitkritisch: 15 Patienten retten, bevor 6 sterben. Genug Triage-Verbände einpacken." },
  },
}

function ns.WarnLines(key, rank)
  local L = {}
  for _, w in ipairs((ns.warnings and ns.warnings[key]) or {}) do
    if rank >= w[1] and rank <= w[2] then
      if #L == 0 then L[1] = " "; L[2] = "|cffff4040Wichtig – Entscheidungen:|r" end
      L[#L + 1] = "|cffff8040! " .. w[3] .. "|r"
    end
  end
  return L
end

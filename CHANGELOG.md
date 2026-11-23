# Changelog

## 1.12.6
- Händlergunst: neuer Tipp bei allen sieben Herstellungsberufen mit Lagerhändler, woher der Ruf für die höheren Rezepte kommt (Handwerksverfügungen: 75/125/200 Ruf, jede einmal täglich, keine Gunst).
- Geprüft: QuestieDB 1.1.5 (Berufsquests unverändert; Handwerksverfügungen jetzt als täglich markiert), Auctionator 352, WoW-Client unverändert.
- Merchant's Favor: new tip for all seven crafting professions with a camp vendor on where the reputation for the higher recipes comes from (Craftsman's Writs: 75/125/200 reputation, each once a day, no Favor).
- Checked: QuestieDB 1.1.5 (profession quests unchanged; Craftsman's Writs now marked daily), Auctionator 352, WoW client unchanged.

## 1.12.5
- Mehrere Charaktere: Skill, Rezept-Stand und die angezeigten Berufe werden jetzt pro Charakter gespeichert (vorher accountweit gemischt). Beim Einloggen zeigt SkillPfad automatisch nur die Berufe, die der Charakter erlernt hat; wer in den Optionen selbst wählt, behält seine Auswahl. Einstellungen wie Optik, Fenster, Routen und Preise bleiben accountweit.
- Multiple characters: skill, recipe state and the shown professions are now saved per character (previously mixed account-wide). On login SkillPfad automatically shows only the professions the character has learned; if you choose in the options yourself, your choice is kept. Settings such as look, window, routes and prices stay account-wide.

## 1.12.4
- Alchemie: Rezeptnamen der Routen an die deutschen Spielnamen angepasst (laut Wowhead Forever und QuestieDB): Elixier der schwachen Gewalt, Elixier der schwachen Verteidigung, Elixier der schwachen Seelenstärke, Trunk der Untotenentdeckung, Erheblicher verfärbter Heiltrank, Geringes Arkanelixier. Bei 270-300 zählt jetzt auch das Murlocauge (31) zum Gesamtbedarf.
- CurseForge-Projekt-ID in der .toc (SkillPfad ist jetzt auf CurseForge).
- Geprüft: QuestieDB 1.1.4 (keine Änderung an Berufsquests), Auctionator 351, keine neuen Berufs-Hotfixes.
- Alchemy: recipe names of the routes now match the in-game names (per Wowhead Forever and QuestieDB): Elixir of Minor Force, Elixir of Minor Defense, Elixir of Minor Fortitude, Elixir of Detect Undead, Major Discolored Healing Potion, Lesser Arcane Elixir. At 270-300 the Murloc Eye (31) now counts towards total needs.
- CurseForge project ID in the .toc (SkillPfad is now on CurseForge).
- Checked: QuestieDB 1.1.4 (no change to profession quests), Auctionator 351, no new profession hotfixes.

## 1.12.3
- Fenster größer (860 x 660) und mit dem Griff unten rechts frei in der Größe veränderbar (760 x 600 bis 1600 x 1200); Größe wird gespeichert, die Karten passen sich der Breite an. "Fenster sperren" sperrt auch die Größe.
- Optionen neu geordnet: links "Anzeige und Verhalten", "Fenster und Inhalt", "Route, Sprache und Preise", rechts "Berufe anzeigen" und "Optik" mit Status. Optik-Seite mit Vorschau rechts daneben.
- "Fenstergröße" heißt jetzt "Skalierung"; "Fenster zurücksetzen" setzt Position und Größe zurück.
- Larger window (860 x 660), freely resizable with the grip at the bottom right (760 x 600 to 1600 x 1200); size is saved and cards adapt to the width. "Lock window" also locks the size.
- Options reorganized: left "Display and behavior", "Window and content", "Route, language and prices", right "Show professions" and "Look" with status. Look page with preview alongside.
- "Window size" is now called "Scale"; "Reset window" resets position and size.

## 1.12.2
- Optionen → "Optik anpassen …": Schriftgröße (9-18), Zeilenabstand, Farbschema (Leder, Dunkel, Nachtblau, Wald), Textfarbe (Creme, Weiß, Hellgrau, Gold) und Hintergrund-Deckkraft, mit Vorschau und "Standard wiederherstellen". Die Schriftgröße gilt für Karten, Abschnittstitel und Seitenleiste.
- Options → "Customize look …": font size (9-18), line spacing, color scheme (Leather, Dark, Midnight blue, Forest), text color (Cream, White, Light grey, Gold) and background opacity, with preview and "Restore defaults". The font size applies to cards, section titles and the sidebar.

## 1.12.1
- Layout näher am Entwurf: Alternativen eine Zeile pro Rezept (Materialien direkt dahinter), Fundorte fehlender Materialien nur noch einmal ("Fehlt: ..."), "Jetzt"-Karte mit Pfeil und goldenem Rahmen, Abschnitte mit farbigem Rahmen statt Seitenbalken, engere Zeilenabstände.
- Skillbalken zeigt die aktuelle Obergrenze (z.B. 31 / 75) statt immer / 300.
- Layout closer to the draft: alternatives on one line per recipe (materials right after), sources of missing materials shown only once ("Missing: ..."), "Now" card with arrow and gold border, sections with colored border instead of side bar, tighter line spacing.
- Skill bar shows the current cap (e.g. 31 / 75) instead of always / 300.

## 1.12.0
- Neues, übersichtlicheres Fenster: Tipps, Händlergunst, Berufsquests, Einkaufsliste, Gesamtbedarf und "Der ganze Weg" sind einklappbare Abschnitte (Klick auf die Kopfzeile, mit Anzahl bzw. Kurzinfo). Der Zustand wird pro Beruf gespeichert; "Wichtig" und "Alternativen" sind anfangs offen.
- Oben steht die Karte "Jetzt": bestes Rezept mit allen Materialien in einer Zeile (grün vorhanden, rot fehlend) und Fundort der fehlenden.
- Kopfzeile zeigt die aktuelle Phase unter dem Berufsnamen; "Beruf öffnen" sitzt unter dem Skillbalken.
- TomTom-Knöpfe stehen im passenden Abschnitt (Material in "Jetzt"/"Alternativen", Quests bei den Berufsquests, Lager bei Händlergunst, Auctionator-Listen beim Gesamtbedarf); übrige wie Lehrer unter "Wegpunkte (TomTom)".
- "Der ganze Weg" jetzt auch in Herstellungsberufen, mit Phasenbalken (grün erledigt, gold aktuell).
- New, clearer window: tips, Merchant's Favor, profession quests, shopping list, total needs and "The whole path" are collapsible sections (click the header, with count or short info). The state is saved per profession; "Important" and "Alternatives" start open.
- A "Now" card at the top: best recipe with all materials on one line (green available, red missing) and where to get the missing ones.
- The header shows the current phase below the profession name; "Open profession" sits below the skill bar.
- TomTom buttons sit in the matching section (materials in "Now"/"Alternatives", quests under profession quests, camp under Merchant's Favor, Auctionator lists under total needs); the rest such as trainers under "Waypoints (TomTom)".
- "The whole path" now also for crafting professions, with a phase bar (green done, gold current).

## 1.11.10
- Kräuterkunde: Tipps zu Kräutersamen (vier Stufen, Gewächshaus ab Skill 140) und zum Saatenkreuzer (Samenhybridisierer, ab Skill 300): Material, Lagerfeuer, 2 Samen derselben Stufe, Hotfix vom 19.11. (Fehlschlagchance, keine Raren Kräutersamen mehr). Fundort des Bauplans laut Guides noch unbekannt.
- Herbalism: tips on herb seeds (four tiers, Greenhouse from skill 140) and the Seed Hybridizer (from skill 300): materials, campfire, 2 seeds of the same tier, 19 Nov hotfix (failure chance, no Scarce Herb Seeds). Blueprint source still unknown according to guides.

## 1.11.9
- Berufsquests mit der aktuellen QuestieDB (1.1.3) abgeglichen: neue Bergbau-Quest "Material für die Schmiede" (Allianz, Loch Modan, 10 Bronzebarren); Schmiede-Quests "Nachschub für die Front" ab Skill 25 (vorher 30) und "Die Aufrüstung im Rotkammgebirge" ab Skill 35 (vorher 60).
- Schmiedekunst: "Die alten Traditionen" gibt laut Hotfix vom 17.11. das Rezept Orc-Kriegsgamaschen als Gegenstand; Ersatz bei Sumi.
- Profession quests checked against QuestieDB 1.1.3: new Mining quest "Ingredients for the Forge" (Alliance, Loch Modan, 10 Bronze Bars); Blacksmithing quests "Supplying the Front" from skill 25 (was 30) and "Gearing Redridge" from skill 35 (was 60).
- Blacksmithing: per the 17 Nov hotfix "The Old Ways" grants the Orcish War Leggings recipe as an item; replacement from Sumi.

## 1.11.8
- Angeln: Tipp zum Angelgestell (Lager, ab Angeln 140): Bauplan von Gelihast, Material, Wirkung und der Hotfix vom 16.11. (Köder für alle, mehr aufgeblähte Fische).
- Angeln: Ködernamen wie im Spiel (Glänzende Schmuckstücke, Helle Schmuckstücke) statt "Glitzerköder"/"Helle Köder".
- Fishing: tip on the Fishing Rack (camp, from Fishing 140): blueprint from Gelihast, materials, effect and the 16 Nov hotfix (lures for everyone, more bloated fish).
- Fishing: German lure names now match the game client.

## 1.11.7
- Händlergunst für alle Berufe: Alchimie, Schmiedekunst, Ingenieurskunst, Schneiderei und Verzauberkunst zeigen den Lagerhändler (Rezeptzahl, ab welchem Skill, Gunstpreise) und welche Materialien aus dem Skillweg in die Abgefangenen Kisten passen. Bergbau, Kräuterkunde und Erste Hilfe zeigen die passenden Kisten. Ab Skill 300 Hinweis auf das Berufszertifikat (Titel, 1.000 Gunst).
- Merchant's Favor for all professions: Alchemy, Blacksmithing, Engineering, Tailoring and Enchanting show the camp vendor (recipe count, minimum skill, favor cost) and which leveling materials fit the Waylaid Crates. Mining, Herbalism and First Aid show the matching crates. At skill 300 a note on the profession certification (title, 1,000 favor).

## 1.11.6
- Händlergunst (neue Währung in WoW Forever) als Tipps eingebaut: Lederverarbeitung (Kisten mit Gegerbten Häuten, 81 Muster beim Lederhändler im Lager), Kürschnerei (Leder für Abgefangene Kisten), Kochen (6 Smoothie-Rezepte). Die Muster gehören nicht zum Skillweg.
- Neuer Wegpunkt `/sp weg gunst`: Lager Versorgung und Logistik Durotar (Brachland, Dokimi) bzw. Handelskommission von Azeroth (Rotkammgebirge, Marcy Baker), Koordinaten aus QuestieDB.
- Merchant's Favor (new WoW Forever currency) added as tips: Leatherworking (crates with cured hides, 81 patterns at the camp vendor), Skinning (leather for Waylaid Crates), Cooking (6 smoothie recipes). The patterns are not part of the leveling path.
- New waypoint `/sp weg gunst`: Durotar Supply and Logistics camp (Barrens, Dokimi) or Azeroth Commerce Authority camp (Redridge, Marcy Baker), coordinates from QuestieDB.

## 1.11.5
- Hotfixes vom 10.11.: Hinweis Schmiedekunst (Grober Schleifstein gibt bis Skill 90 Punkte, vorher 75) und Kochen (Lagerfeuer des Gesellen ab Kochen 90, vorher 140).
- Deutsche Itemnamen korrigiert: Raue/Grobe/Schwere Schleifsteine (statt "Mahlsteine"), Verdichteter Wetzstein, Verdichteter Gewichtsstein.
- Englische Übersetzung für die neuen Kürschnerei-Zonen und Hinweise aus 1.11.4 ergänzt.
- Hotfixes of 10 Nov: notes for Blacksmithing (Coarse Grinding Stone gives skill-ups to 90, was 75) and Cooking (Journeyman Campfire Kit from Cooking 90, was 140).
- German item names corrected (grinding stones, Dense Sharpening Stone, Dense Weightstone).
- English translation added for the new skinning zones and notes from 1.11.4.

## 1.11.4
- Kürschnerei nach Wowhead-Stand 7.11. (Patch 1.60.1): Zonen 75-125 Brachland/Loch Modan/Dunkelküste, 125-175 Eschental/Dämmerwald/Hügelland/Sumpfland, 175-225 Arathihochland/Schlingendorntal/Tausend Nadeln. Ab 225 nennt der Guide keine Zonen (bisherige Richtwerte bleiben, Hinweis ergänzt).
- Lederverarbeitung: Hinweis zum Hotfix vom 6.11. (Gerberrahmen: Skillanforderung 140 auf 125, Skillpunkte dort um 15 reduziert).
- Skinning per Wowhead (7 Nov, patch 1.60.1): zones 75-125 Barrens/Loch Modan/Darkshore, 125-175 Ashenvale/Duskwood/Hillsbrad/Wetlands, 175-225 Arathi/STV/Thousand Needles. No zones listed above 225 (old estimates kept, note added).
- Leatherworking: note on the 6 Nov hotfix (Tanning Rack skill requirement 140 to 125, skill-ups there reduced by 15).

## 1.11.3
- Fenster lässt sich jetzt auch im Kampf öffnen, schließen und verschieben (der Knopf "Beruf öffnen" hängt nicht mehr am Fenster und wird im Kampf ausgeblendet).
- Beutelmengen aktualisieren sich auch bei geschlossenem Berufsfenster; Umschalten der Sortierung wirkt sofort auf die gespeicherte Rezeptliste.
- Weniger Last: neu gezeichnet wird nur bei geänderten Inhalten, Dauer-Scan etwa alle 3 s statt 0,7 s; Übersetzungs-Cache begrenzt.
- Neu: `/sp help` (Befehlsübersicht). `/sp weg` findet auch englische Namen und Allianz-Orte.
- Fehler-Handler anderer Addons (z. B. BugSack) wird beim Login nicht mehr überschrieben. Einkaufsliste rechnet bis zum Phasenende (z. B. 115 statt 114). Icon in der Addon-Liste.
- The window can now be opened, closed and moved in combat (the "open profession" button is no longer attached to the window and hides during combat).
- Bag counts update while the profession window is closed; toggling the sort order applies to the cached recipe list right away.
- Lower load: redraw only when content changes, background rescan about every 3 s instead of 0.7 s; translation cache is capped.
- New: `/sp help` (command overview). `/sp weg` also finds English names and Alliance locations.
- Other addons' error handlers (e.g. BugSack) are no longer overwritten at login. Shopping list counts to the end of the phase (e.g. 115, not 114). Icon in the addon list.

## 1.11.2
- Alchemie nach Wowhead-Stand 3.11.: Großer Manatrank 205-240 (Stein der Weisen bei 225 aufheben), Mächtiger Verfärbter Heiltrank 270-300.
- Alchemy per Wowhead (3 Nov): Greater Mana Potion 205-240 (keep the Philosopher's Stone made at 225), Major Discolored Healing Potion 270-300.

## 1.11.1
- Rechenfehler beim Anzeigen werden abgefangen (Cache wird verworfen, eine Meldung statt Fehlerflut); SkillPfadDB trägt eine Versionsnummer (dbVersion) für künftige Migrationen.
- Errors while building the display are caught (cache is discarded, one message instead of an error flood); SkillPfadDB now has a dbVersion for future migrations.

## 1.11.0
- Englische Oberfläche und Texte: automatisch nach Client-Sprache (deDE = Deutsch, sonst English).
- Umschalten per `/sp lang de|en|auto` oder Knopf "Sprache / Language" in den Optionen.
- English UI and texts, chosen automatically by client language; switch with `/sp lang de|en|auto` or the language button in the options.
- Nicht-deutsche Clients: Itemnamen kommen aus dem Client (Auktionator-Listen), "Beruf öffnen" nutzt den englischen Berufsnamen.

## 1.10.0
- Empfehlungen und Einkaufsliste erscheinen auch ohne offenes Berufsfenster (letzter Stand, Beutel aktuell).
- Knopf "Beruf öffnen" im Fenster öffnet das Berufsfenster.

## 1.9.4
- AH-Scan-Knopf ausgegraut, wenn der Client keinen eigenen Scan erlaubt; Hinweis auf Auctionator.

## 1.9.3
- Routenvergleich: "noch keine Preise" statt "ca. 0", solange nichts gescannt ist.

## 1.9.2
- Optionen: Überlappungen behoben, Routen-Knopf zeigt jetzt den Namen.

## 1.9.1
- Berufe in den Einstellungen ein-/ausschaltbar.

## 1.9.0
- Einkaufsliste per Klick an Auctionator übergeben (bis Phasenende oder Skill 300).

## 1.8.0
- `/sp check` Selbsttest, Kostenvergleich der Routen.

## 1.7 – 1.5
- Neues Fensterlayout, Planung für zwei Berufe, Routenvarianten, Paarungen Sammel- ↔ Herstellberuf.
- Warnungen vor unumkehrbaren Entscheidungen, Einkaufsliste mit Kosten.

## 1.4.x
- Berufsquests mit TomTom-Wegpunkten, Allianz-Unterstützung, Wowhead-basierte Phasen.

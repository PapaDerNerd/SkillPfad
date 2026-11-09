# Changelog

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

# Changelog

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

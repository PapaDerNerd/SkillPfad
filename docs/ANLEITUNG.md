# Anleitung

## Erste Schritte
1. Addon installieren (siehe [README](../README.md)).
2. Im Spiel `/sp` eingeben oder den Minimap-Knopf anklicken.
3. Öffne ein Berufsfenster (z. B. Lederverarbeitung): SkillPfad erkennt deinen Skill und schlägt das beste Rezept vor. Das Fenster öffnet sich auf Wunsch automatisch.

## Das Fenster
- **Links:** Berufe mit deinem aktuellen Skill. Unten „Optionen“.
- **Oben rechts:** Fortschrittsleiste (Skill / 300).
- **Karten:** farbige Streifen – rot *Wichtig* (Warnungen), blau *Berufsquests*, grün *Einkaufsliste/Gesamtbedarf*, lila *Planung*.
- **Wegpunkte (TomTom):** Buttons für Material, Trainer, Händler, Quests und die Auctionator-Liste.

## Einkaufsliste & Auctionator
- Die Einkaufsliste rechnet das Fehlende bis zum Phasenende bzw. bis 300 aus (dein Beutel zählt, Barren zählen über ihr Erz).
- Button „Auctionator-Liste …“ legt in Auctionator die Liste „SkillPfad: <Beruf>“ an. Am Auktionshaus im Reiter *Einkaufslisten* öffnen. Eine gleichnamige Liste wird ersetzt.
- Preise: Auctionator wird bevorzugt, sonst eigener Scan (`/sp scan` am offenen AH).

## Routen & Paarungen
Viele Berufe haben mehrere Routen (`/sp route <beruf>` oder Button in den Optionen). Der Kostenvergleich markiert die günstigste vollständige Route. Sammelberufe (Bergbau, Kräuterkunde, Angeln, Kürschnerei) zeigen, was du für Schmiedekunst/Ingenieurskunst, Alchemie, Kochen bzw. Lederverarbeitung farmen musst.

## Berufe ausschalten
`/sp einst` → rechte Spalte „Berufe anzeigen“. Abgewählte Berufe verschwinden aus der Liste und öffnen das Fenster nicht mehr automatisch.

## Wegpunkte
Mit TomTom setzt SkillPfad echte Pfeile. Sitzen sie falsch, in den Optionen „Wegpunkte per TomTom-Befehl /way setzen“ aktivieren. `/sp mapcheck` prüft die Karten-IDs.

## Fehlersuche
- `/sp check` ausführen und die Ausgabe (OK/FEHLT/HINWEIS) mit einem Issue melden.
- Leere Empfehlungen: Berufsfenster einmal öffnen, damit der Skill gescannt wird.
- Lua-Fehler: `/spdiag` zeigt gesammelte Fehler.

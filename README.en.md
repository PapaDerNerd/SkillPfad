# SkillPfad

[Deutsche Version](README.md)

**Profession guide for WoW Forever (Classic ruleset).** For all 12 professions SkillPfad shows the best path from 1 to 300: which recipe to craft next, the materials needed, where to get them, their auction house price, and optionally sets TomTom waypoints. The UI is available in **English and German** (chosen by client language, switch with `/sp lang de|en|auto`).

![Leatherworking: "Now", alternatives and collapsible sections](docs/images/leder-guide.jpg)

| Planning & the whole path | Options | Customize look |
|---|---|---|
| ![Planning and phase bar](docs/images/weg-planung.jpg) | ![Options](docs/images/optionen.jpg) | ![Customize look](docs/images/optik.jpg) |

## Features

- 12 professions (leatherworking, skinning, cooking, first aid, alchemy, blacksmithing, engineering, tailoring, enchanting, mining, herbalism, fishing).
- Phased skill path with recommended recipe, materials and notes.
- Sources and vendors with map coordinates, for **Horde and Alliance**.
- TomTom waypoints for materials, trainers, vendors and profession quests (Blizzard waypoint as fallback).
- Profession quests, with warnings before irreversible choices.
- Shopping list with costs (Auctionator or own scan) and **one-click export to an Auctionator shopping list**.
- **Clear window:** a "Now" card with the best recipe and collapsible sections (tips, Merchant's Favor, quests, shopping list, total needs, the whole path with a phase bar).
- **Customizable:** window size via the resize grip, font size, line spacing, color scheme, text color and opacity (Options → "Customize look …").
- Several routes per profession with cost comparison; gatherer/crafter pairings.
- Recommendations stay visible without the profession window (last known state), plus an "open profession" button.
- Switch professions on/off. Self-test with `/sp check`. Command overview with `/sp help` (slash keywords are German, e.g. `/sp leder`).

## Installation

**Easiest:** install and keep it updated with the CurseForge app – [SkillPfad on CurseForge](https://www.curseforge.com/wow/addons/skillpfad).

Or manually:

1. Download the ZIP from [Releases](../../releases).
2. Copy the `SkillPfad` folder to `…/_forever_/Interface/AddOns/`.
3. Start the game or `/reload`. Optional: TomTom, Auctionator.

Commands: `/sp`, `/sp <profession>`, `/sp einst` (options), `/sp route`, `/sp scan`, `/sp preis`, `/sp weg`, `/sp mapcheck`, `/sp check`.

## Status

New addon. Verified in a mock environment but **not yet fully tested in game**. Some phases beyond skill 225 use unverified sources; some item or map IDs may be wrong. Please open an [issue](../../issues) with the output of `/sp check`.

## License

GPL-3.0 (quest/NPC data derived from [Questie](https://github.com/Questie/Questie), GPL-3.0). See [LICENSE](LICENSE) and [THIRD-PARTY.md](THIRD-PARTY.md). Not affiliated with Blizzard Entertainment.

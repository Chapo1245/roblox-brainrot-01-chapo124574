# Brainrot Bodega

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/Chapo1245/roblox-brainrot-01-chapo124574/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/Chapo1245/roblox-brainrot-01-chapo124574/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

A 3D Roblox brainrot game built for [make.fun's roblox-brainrot-01 bounty](https://make.fun/bounty/roblox-brainrot-01): a night market where absurd food brainrots ride the conveyor, players buy them, park them on their base, and watch the cash tick up — while thieves, a health inspector and runaway shopping carts keep everyone running.

## The game

- **48 original brainrots** in 9 rarities (Common → Prismatic), from Crumbly Carl ($5/s) to The Prismatic Pineapple ($100,000/s), plus 6 mutations (Golden, Spicy, Frozen, Neon, Shadow, Diamond).
- **The loop:** brainrots roll down the conveyor — click one to buy it, it walks to a free slot on your base and starts earning every second. Buy the next tier, then the next.
- **Stealing:** click a rival's brainrot to snatch it off their base and carry it home — unless their base is locked.
- **Base lock:** lock your base for 60 seconds when the thieves circle.
- **Events:** Health Inspector Raid (confiscates belt brainrots), Cart Stampede (runaway carts knock players down), Golden Hour (double income for 60s).
- **Progression:** Fuse-O-Matic (3 of one rarity become 1 of the next), 5 daily quests, an Index Book of all 48 brainrots, and Rebirth (+25% income per tier, forever).

## Layout

- `src/shared/` — `BrainrotCatalog.luau` (the 48-brainrot roster, rarities, mutations) and `GameConfig.luau` (all tuning).
- `src/server/` — `init.server.luau` boots the game; `WorldBuilder.luau` builds the whole 3D night market at runtime; `BrainrotSpawner.luau` runs the conveyor; `BaseService.luau` owns bases, slots, locks and stealing; `EconomyService.luau` owns cash, income, buying, selling and rebirth; `EventService.luau` runs the three events; `QuestService.luau` owns quests; `FuseService.luau` owns the Fuse-O-Matic; `InteractionService.luau` handles clicks; `NetworkService.luau` owns the remotes; `DataService.luau` is the single source of truth for live state.
- `src/client/` — `Game.client.luau` boots the client; `HudController.luau` builds the ScreenGui (cash, shop, base, quests, index, fuse); `EffectsController.luau` shows event banners and toasts.
- `game.rbxl` — the place, built with Rojo: `rojo build default.project.json --output game.rbxl`.
- `screenshots/` — 4 images of the game (the first is the cover and the Roblox thumbnail).
- `PLAY.json` — the published place link (filled in once the experience is published).
- `main.ts` — hands the entry in (copies `game.rbxl`, `src/`, `screenshots/`, `PLAY.json` to `/output` and writes `dossier.json`).

## Play

Walk up to the conveyor, click a brainrot to buy it, watch it earn on your base. Lock your base when thieves approach. Fuse three of a kind for something rarer. Rebirth when you are rich enough to start over stronger.

<sub>Entered on [make.fun](https://make.fun/?ref=wtacm6ft&utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards</sub>

# Bonsai · Mascot motion & Lottie spec

The mascot is the emotional core of Bonsai — a little potted tree with a minimal face that **grows,
withers, blooms and fruits** as you water it with context. Style (canonical, from the shipped
Lottie files): **thin clean ink outline · flat fills only · minimal face** (dot eyes, tiny smile,
blush) — 细线条、干净扁平配色、极简表情.

## Shipped assets (source of truth)
`lottie/` in this folder holds the canonical files — standard Bodymovin JSON, 300×300, 30fps.
The static SVG poses in `mascot.html` are redrawn **1:1 from these files** and serve as the model
sheet for the remaining animations.

| File | Motion | Loop |
|---|---|---|
| `bonsai-idle.json` | breathe (squash-stretch) + blink | loop 4s |
| `bonsai-cheer.json` | bounce + star eyes + sparks | 2.5s |
| `bonsai-thirsty.json` | sweat drop forms & falls | loop 3.3s |
| `bonsai-sleep.json` | slow breathe + drifting Z | loop 5s |

Flutter: `Lottie.asset('assets/bonsai-idle.json')` with the `lottie` package.

## Canonical palette (baked into the Lotties; SVG poses read the same values via `--m-*` tokens)
| Token | Hex | Used for |
|---|---|---|
| `--m-leaf` | `#3FA34D` | crown / leaves |
| `--m-ink` | `#33302B` | all outlines (w5; stem w7), eyes, mouth |
| `--m-pot` | `#E8703A` | pot rim + body |
| `--m-cheek` | `#F6B1B1` | blush |
| `--m-spark` | `#F5C242` | sparks, star eyes, yellow fruit |
| `--m-drop` | `#4FA3E0` | water / sweat drop |
| `--m-bud` | `#F2A9C4` | blossom buds |
| `--m-fruit` | `#E25C4A` | berries |
| `--m-withered` | `#A6A69C` | wilted crown |

The mascot keeps this fixed palette across UI themes (the Lottie files are baked); the UI re-themes
around it.

## Rig (from the shipped files — reuse for every new animation)
- Canvas 300×300 · 30fps. Two base layers: **`plant`** (crown + face groups `eyes/mouth/cheeks/crown`)
  and **`pot`** (groups `rim/body/stem`), plus overlay layers per effect (`drop`, `spark1/2`, `z1/2`).
- Crown = one smooth 8-point blob (see `#m-bonsai` path), fill `#3FA34D`, stroke w5.
- Pot = rounded rect rim (120×22, r9) + rounded trapezoid body, both `#E8703A` stroke w5; stem stroke w7.
- Face: 9×9 dot eyes at (132,105)/(168,105), 22-wide smile at y120 (w5), blush ellipses 15×10 at
  (119,119)/(181,119).
- **Flat fills only — no gradients.** Everything overshoots a touch and settles
  (`cubic-bezier(.34,1.5,.5,1)`); pot base is the anchor; plant squashes/stretches from there.

## Remaining animations to build (same rig; static pose in `mascot.html`)
| Lottie | Trigger | Loop | Dur | Key motion | Pose |
|---|---|---|---|---|---|
| `plant_seed` | onboarding done / first context | once | 1.4s | soil pat → sprout pops with overshoot; sleepy → awake | `#m-seed` |
| `grow_up` | context threshold (level up) | once | 1.8s | stem stretches, crown blob pops in; spark burst | `#m-sprout → #m-bonsai` |
| `bloom` | milestone / streak | once→idle | 2.0s | buds unfurl in sequence; eyes go ^ ^; a petal falls | `#m-bloom` |
| `fruit` | goal completed | once→idle | 2.0s | berries swell & bob; one drops and bounces | `#m-fruit` |
| `wither` | neglected | once→hold | 1.6s | crown sags + desaturates to `#A6A69C`; tear | `#m-wither` |
| `water_revive` | user waters / adds context | once | 2.2s | droplets fall, plant springs back, colour returns | `#m-wither → #m-bonsai` |
| `generating` | splash — AI building first UI | loop | 2.4s | leaf/spark swirl assembles into the crown | `#m-sprout` + swirl |

## State machine (how the app drives it)
```
              context saved          threshold           milestone         goal done
  [seed] ── plant_seed ─▶ [sprout] ── grow_up ─▶ [bonsai] ── bloom ─▶ [blooming] ── fruit ─▶ [fruiting]
     ▲                                   │  ▲                                                      │
     │            water_revive           ▼  │  stale 2d          neglected                         │
     └───────────────────────── [revive] ◀── [thirsty] ── thirsty/wither ─▶ [withered] ◀───────────┘
  (any state) + night ─▶ sleep    (any state) idle ─▶ idle    (any win) ─▶ cheer
```
- **Persistent stage** (seed/sprout/bonsai/blooming/fruiting) comes from the context/engagement level.
- **Overlay mood** (idle/thirsty/sleep/cheer) plays on top of the current stage's idle.
- Transitions (plant/grow/bloom/fruit/wither/revive) are one-shots that end on the next idle.

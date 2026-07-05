# Bonsai · Design System

A token-first, **extendable** design system for Bonsai — a self-growing mobile app whose interface
matures as you water it with context. Reference guideline: **Material token model + MUI component
breakdown** (cross-platform). The HTML/CSS here is the **canonical spec**; implement it in any
framework via the per-component **Copy as prompt** buttons (Flutter surfaced first).

## Files
| File | What it is |
|---|---|
| `styles.css` | The **source of truth** — all design tokens (`:root` CSS vars) + every component class. |
| `index.html` | Living style guide: foundations + the full component catalogue, a Figma-style **Dev Mode** inspector, and **Copy as prompt**. |
| `concept.html` | Two static concept screens (Garden Home + Module detail) built only from DS classes. |
| `icons.html` | The inline SVG icon sprite + the bonsai **mascot** (three growth stages). |
| `mascot.html` | The **mascot model sheet** — all growth + mood poses (seed/sprout/bonsai/bloom/fruit · thirsty/wilting/sleep/celebrate), themeable. |
| `motion-lottie.md` | The **Lottie motion spec** — every animation's trigger/loop/duration + the growth↔mood state machine. |

Open `index.html` in any browser (`file://`, no build). The **Concept preview** link sits at the top
of the sidebar; the concept page links back.

## Three layers
1. **Tokens** (`styles.css :root`) — color roles (each fill paired with an `--on-*`, WCAG-checked),
   spacing, typography, radius, elevation, motion, icon sizing. Neutrals are tinted **warm** (paper).
2. **Atomic components** — button, icon button, FAB, checkbox, radio, switch, text field, select,
   slider, chip, avatar, badge, rating, divider, icon, typography…
3. **Composed components** — card, app bar, bottom nav, drawer, tabs, list, table, accordion, dialog,
   snackbar, alert, stepper, menu, speed dial…

The catalogue mirrors the **MUI Required set** — same categories/components every build; only the
token values change between themes.

## The signature look
- A warm **`--ink`** outline (2–2.5px) + a hard **`--elev-pop`** offset shadow on primary buttons,
  `card--pop`, and the FAB — the picture-book cut-out that collapses to `--elev-pop-sm` on press.
- **Mascot**: a potted tree with a minimal face (dot eyes · tiny smile · blush), drawn as inline SVG
  **1:1 from the shipped Lottie files** (`lottie/bonsai-*.json`). Fills read the `--m-*` tokens,
  pinned to the Lottie hexes (`--m-leaf #3FA34D`, `--m-pot #E8703A`, `--m-ink #33302B`…) so static
  art and animation never drift. **Flat fills only — no gradients anywhere in the system.**
- Type: **Baloo 2** (display) × **Nunito** (body) × **Patrick Hand** (captions).

## Themes (switching is cheap by design)
Everything visual is a token, so a theme = **only the `:root` block**. Four ship in `styles.css`:
- default **Fresh Matcha** (milky cream, bright spring green + sky blue — high-key & airy),
- `[data-theme="sage"]` **Sage & Clay** (warm paper, leaf green + terracotta),
- `[data-theme="grove"]` **Bright Grove** (crisp, high-key, cooler),
- `[data-theme="dusk"]` **Dusk Garden** (dark-first).

Flip live with the 🎨 selector in `index.html` / `concept.html` / `mascot.html`. No component/markup changes.

## How to extend
- **Add a token** → add the CSS var in the right `:root` group; reference it by name. Never inline a
  raw value. If it's a fill, add its `--on-*` partner at the same time and check contrast.
- **Add an atomic component** → new class block in `styles.css` (tokens only) + a `<section id="key">`
  in `index.html` + a `SPECS.key` entry (props / tokens / metrics). The **Copy-as-prompt** button and
  Dev-Mode inspector are auto-wired from the section `id` matching the `SPECS` key.
- **Add a composed component** → same, built only from tokens + existing atomics.
- **Add a new theme** → add a `:root[data-theme="name"]{ … }` override block and an entry to the
  `THEMES` array in `index.html` / `concept.html`. Keep every `--on-*` pair.
- **Add an icon / mascot stage** → drop a `<symbol id="i-…">` (or `#m-…`) into the sprite in
  `icons.html` and copy it into the sprite block at the top of `index.html` / `concept.html`.

## Accessibility bar
- Every fill/`--on-*` pair is WCAG-checked by math (body ≥ 4.5:1, large/UI ≥ 3:1).
- Touch targets ≥ 48dp. One spacing scale everywhere. Visible 2px focus ring with an offset gap.

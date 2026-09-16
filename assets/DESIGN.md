---
name: Midnight Neon Arcade
colors:
  surface: '#051424'
  surface-dim: '#051424'
  surface-bright: '#2c3a4c'
  surface-container-lowest: '#010f1f'
  surface-container-low: '#0d1c2d'
  surface-container: '#122131'
  surface-container-high: '#1c2b3c'
  surface-container-highest: '#273647'
  on-surface: '#d4e4fa'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#d4e4fa'
  inverse-on-surface: '#233143'
  outline: '#849495'
  outline-variant: '#3b494b'
  surface-tint: '#00dbe9'
  primary: '#dbfcff'
  on-primary: '#00363a'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#006970'
  secondary: '#ffb1c4'
  on-secondary: '#65002e'
  secondary-container: '#ff4a8d'
  on-secondary-container: '#590028'
  tertiary: '#fff3f4'
  on-tertiary: '#640034'
  tertiary-container: '#ffccda'
  on-tertiary-container: '#b90066'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#ffd9e1'
  secondary-fixed-dim: '#ffb1c4'
  on-secondary-fixed: '#3f001a'
  on-secondary-fixed-variant: '#8f0044'
  tertiary-fixed: '#ffd9e3'
  tertiary-fixed-dim: '#ffb0c9'
  on-tertiary-fixed: '#3e001e'
  on-tertiary-fixed-variant: '#8e004c'
  background: '#051424'
  on-background: '#d4e4fa'
  surface-variant: '#273647'
typography:
  display-hero:
    fontFamily: Sora
    fontSize: 56px
    fontWeight: '800'
    lineHeight: 60px
    letterSpacing: -0.04em
  display-hero-mobile:
    fontFamily: Sora
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Sora
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Sora
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Sora
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Sora
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-numeric:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.08em
  label-sm:
    fontFamily: Space Grotesk
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.1em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style
The design system channels an atmospheric, late-night arcade mood combining retro-futuristic arcade velocity with high-end mobile minimalism. The interface captures late-night immersion: deep abyss-like midnight tones pierced by razor-sharp electric cyan and charged magenta luminescence. 

The aesthetic synthesizes minimalism with atmospheric neon glassmorphism. Surfaces stay ultra-dark to preserve peripheral vision and eliminate nighttime glare, relying on calibrated neon drop-shadows and subtle luminous borders to establish interactive hierarchy. Structural chrome is eliminated in favor of clean geometric silhouettes and restrained glowing vector lines, evoking the precision of modern vector displays with zero visual clutter.

## Colors
The palette balances deep canvas blacks with narrow, intense bursts of saturated light:

- **Canvas & Surface Base:** Deepest pitch black (`#020308`) transitioning into abyssal midnight blue (`#050813`) for primary viewport backdrops. Elevated panels and HUD containers utilize semi-translucent midnight tints (`#090E1E` at 65% to 85% opacity).
- **Electric Cyan (`#00F0FF`):** The primary kinetic driver. Used for primary interactions, jump physics indicators, active scores, combo trails, and interactive high-priority elements.
- **Intense Magenta & Neon Rose (`#FF007F`, `#FF2E93`):** The secondary thrill driver. Reserved for multipliers, critical hazards, store purchases, game-over accents, and streak milestones.
- **Subdued Functional Neutrals:** Slate white (`#E2E8F0`) provides crisp, legible primary text and prominent glyphs; slate glow (`#94A3B8`) serves secondary readouts, subtle inactive states, and structural division without emitting harsh luminance.

## Typography
Typographic hierarchy uses a distinct three-tier structure to maintain instantaneous readability during high-speed play:

- **Sora** anchors high-impact display moments, scores, and modal headers with geometric curvature and modern sci-fi character.
- **Plus Jakarta Sans** provides comfortable, rounded human readability for settings, tooltips, dialogs, and mission briefings without visual fatigue.
- **Space Grotesk** drives all technical HUD elements, arcade data, timers, high scores, and button labels with clean proportional geometry and tracking.

Labels and numerical meters employ uppercase casing with expanded letter spacing to ensure rapid peripheral legibility against dynamic canvas gameplay.

## Layout & Spacing
The layout follows an edge-safe, thumb-zone fluid model built for portrait and landscape mobile screens. 

- **HUD Grid:** In-game HUD components float within fixed safe-area insets (`1.25rem` mobile margin) anchored to perimeter screen corners, maximizing unobstructed gameplay view in the central canvas.
- **Menu Overlays:** Centered sheet layers conform to a 4-column mobile grid with `1rem` gutters. Tablet and foldables pin menus to a strict 420px max-width tactical column.
- **Safe Vertical Rythym:** Interactive touch targets must adhere to a minimum 48px footprint with at least `0.5rem` (`space-sm`) clearance from adjacent tap points to prevent input errors during tense play sessions.

## Elevation & Depth
Elevation abandons traditional muddy shadows in favor of emitted light, backdrop diffusion, and optical glow:

- **Surface Base (Level 0):** Pure screen canvas (`#020308`) with a subtle radial gradient to `#050813`. Zero elevation.
- **HUD Glass (Level 1):** Floating stats panels and passive containers use `#090E1E` filled at 60% opacity with `16px` backdrop-filter blur and a 1px border colored `#00F0FF` at 15% opacity.
- **Interactive Overlay (Level 2):** Pause dialogs and achievement panels use `#070A18` at 85% opacity, `24px` backdrop blur, a 1px border of `#00F0FF` at 30% opacity, and a soft ambient glow: `0 8px 32px -4px rgba(0, 240, 255, 0.15)`.
- **Active / Neon Glow (Level 3):** Focus states, active jump platforms, and primary arcade buttons project dual-layer light:
  - Inner crisp rim: `0 0 12px rgba(0, 240, 255, 0.5)`
  - Outer ambient diffusion: `0 0 28px rgba(0, 240, 255, 0.25)`
  - For magenta elements, substitute with `rgba(255, 0, 127, 0.5)` and `rgba(255, 0, 127, 0.22)`.

## Shapes
Geometry is smooth and aerodynamic. The baseline radius sits at `0.5rem` (`roundedness: 2`), balancing athletic technical discipline with tactile softness.

Secondary panels, cards, and modal sheets scale to `1rem` (`rounded-lg`). Micro badges and compact chips use `0.25rem` (`rounded-sm`). Floating action buttons, jump charge indicators, and pill toggles use full capsule bounds (`9999px`) to create high tactile affordance under touch.

## Components

### Buttons
- **Primary Arcade Action:** Full cyan fill (`#00F0FF`) with `#020308` text in Space Grotesk Bold. Soft neon glow: `0 0 20px rgba(0, 240, 255, 0.4)`. In active/pressed state, scale drops to `0.97` and glow intensifies to `0 0 28px rgba(0, 240, 255, 0.7)`.
- **Secondary Action:** Glass fill (`#090E1E` at 70% opacity) with a 1px border in `#00F0FF` (40% opacity), text in `#E2E8F0`. Hover/press illuminates the border to 100% with a cyan inner flare.
- **Critical / Danger Action:** Outlined or filled in `#FF007F` with a matching magenta ambient glow (`0 0 20px rgba(255, 0, 127, 0.4)`).

### Chips & Score Badges
- Compact capsules using `roundedness: 3` geometry. Background `#090E1E` at 80% opacity with a 1px perimeter line tinted to match the chip's metric (Cyan for Score, Magenta for Streak Multipliers, Slate for Level indicators).
- Left-aligned glowing micro-dot or vector icon followed by numerical text in Space Grotesk.

### Lists & Leaderboards
- Row items float as decoupled horizontal cards separated by `space-sm`.
- Surfaces utilize translucent dark slate (`#070B1A` at 65% opacity).
- Top 3 ranks receive distinct left-border lightbars: 1st Rank in Electric Cyan, 2nd Rank in Magenta, 3rd Rank in Slate White.

### Checkboxes, Toggles & Radios
- **Toggles:** Pill track (`24px` height, `44px` width) filled with deep navy (`#0B1226`). The thumb is a perfect circle that glides horizontally; when active, the track illuminates in cyan at 20% opacity and the thumb shifts to solid `#00F0FF` emitting an `8px` neon aura.
- **Checkboxes:** Rounded squares (`0.25rem` radius) with a 1.5px border in `#94A3B8`. Checked state fills `#00F0FF` with a deep black `#020308` check glyph.

### Input Fields
- Dark recessed input containers filled with `#040712`, inset with a 1px border in `#94A3B8` at 25% opacity.
- Focus state activates a 1px glowing `#00F0FF` outline and an ambient bloom: `0 0 14px rgba(0, 240, 255, 0.25)`. Text sits in `#E2E8F0`.

### Cards & Arcade HUD Displays
- **In-Game Score Meter:** Ultra-minimalist HUD counter anchoring the top-center. No background card during gameplay; raw numeric display in Sora font with a soft cyan drop shadow (`0 2px 10px rgba(0, 240, 255, 0.3)`).
- **Post-Run Summary Card:** Tier-2 overlay panel featuring a subtle 1px gradient border running from `#00F0FF` at the top-left to `#FF007F` at the bottom-right.
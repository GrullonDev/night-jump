# Night Jump — Contributor & AI Agent Guide

> Put this file in front of any contributor — human or AI — before they touch the project.
> Path: `.agents/Agents.md`. Stack: Flutter + Flame. Language of the UI: Spanish.
> Product goal: a **relaxing night arcade** — the player should leave stress behind, never find more of it.
> Fully offline: no network dependencies, no external services — everything runs locally.

## 1. What this project is

**Night Jump** is a Flappy-style neon arcade game built with Flutter and the Flame engine.
The player taps anywhere to make a glowing orb jump, threads it through gaps between
scrolling neon bars, and scores +1 per gate cleared. Any touch of a bar, the ceiling,
or the floor ends the run.

Design pillars (never break these):

1. **Calm over pressure** — no timers shouting at the player, no punishing waits, no fake urgency.
2. **Fair over hard** — forgiving hitbox, edge warnings, selectable pace, gentle ramps.
3. **Dark neon readability** — deep-navy backgrounds, cyan/magenta glow, Sora + Space Grotesk type.

## 2. Tech stack (pinned facts — verify with `pubspec.yaml` before changing)

| Layer      | Choice |
|------------|--------|
| SDK        | Flutter stable 3.47 / Dart 3.13 |
| Game engine| `flame ^1.38.2` (FlameGame, collisions, tap callbacks) |
| Audio      | `flame_audio` (low-latency SFX) + `audioplayers` global context (playback session on iOS), procedural WAVs in `assets/audio/` |
| Persistence| `shared_preferences` (high score, missions/stardust, themes, settings) |
| Network    | None — no `http`/`dio`/`firebase`/connectivity deps; all assets bundled; works offline |
| Android    | AGP 9.1, NDK 28.2 (`flutter.ndkVersion`), compile/target SDK 36, minSdk 24, `useLegacyPackaging = false` for the 16 KB page-size rule |
| iOS        | Deployment target 15.0, `TARGETED_DEVICE_FAMILY = 1,2` (iPhone + iPad), no required device capabilities |

## 3. Repository map

```
lib/
  main.dart                          # entry point -> utils/app.dart
  utils/app.dart                     # MaterialApp
  utils/theme/app_color.dart         # single source of truth for color
  utils/responsive/                  # mobile/tablet helpers
  features/game/
    night_jump_game.dart             # THE engine: statuses, spawning, pause, difficulty ramp
    state/game_status.dart           # menu | countdown | playing | paused | gameOver
    state/game_difficulty.dart       # chill | classic | intense (+ speed/interval/gap numbers)
    state/sound_service.dart         # SFX wrapper, guarded by the sound toggle
    state/score_repository.dart      # high score
    components/orb_component.dart    # player: physics, forgiving hitbox, edge-danger glow
    components/obstacle_component.dart # neon bar pairs, live speed from the game
    components/starfield_component.dart # parallax background
    overlays/                        # menu, hud, countdown, pause, game_over,
                                     # how_to_play_dialog, difficulty_dialog,
                                     # soft_entrance (shared gentle entrance)
    page/game_page.dart              # GameWidget + overlay registration (ALL overlays must be registered here)
  features/home/                     # menu screen (HomePage + HomeLayout + widgets,
                                     # CharacterOrb breathes gently, static on reduced motion)
  features/home/                     # menu screen (HomePage + HomeLayout + widgets)
  features/missions/                 # daily/weekly challenges + stardust (SharedPreferences)
  features/leaderboard/              # rankings — NOTE: rival rows are a fixed local sample roster, not live data
  features/themes/                   # neon palette gallery (stardust unlocks)
  features/settings/                 # sound/haptics toggles, tutorial flag, difficulty, reset-progress
assets/audio/                        # jump, score, go, game_over, ui (procedural 16-bit/44.1 kHz WAV)
assets/images/                       # app icon
test/game_test.dart                # offline unit tests: difficulty table, ramp base values, sound guard
Agents/Agents.md                     # this file
```

## 4. Core gameplay numbers (tune here, nowhere else)

| System | Current tuning |
|--------|----------------|
| Physics | gravity `900`, jump velocity `-320` (`orb_component.dart`) |
| Visual / hitbox | visual radius `22`, hitbox radius `16` (~73 % — intentional forgiveness) |
| Difficulties | chill `130px/s · 2.0s · gap 230` / classic `180 · 1.6 · 190` / intense `235 · 1.25 · 170` |
| Progressive ramp | `ln(1 + t/18) / ln(6)` over flight time `t`: **+100 px/s** speed, **−0.5 s** interval, capped at ~90 s; gap fixed per run; pause-safe (time only accrues while `playing`) |
| Countdown | 3-2-1-¡GO!, 850 ms/step, obstacles gated on `status == playing`; gentle scale (0.85→1.0, easeOutCubic), instant when reduced motion is on |
| Motion | overlays fade + rise 280 ms (`soft_entrance.dart`); menu orb breathes 2.6 s; everything static under reduced motion |
| Edge warning | red pulsing lerp within `80 px` of ceiling/floor |
| Pause | `pauseEngine()` + overlay; resume is **in place** (no re-countdown); HUD button toggles ⏸/▶ via `isPaused` |

## 5. Conventions every contribution must follow

- **UI copy in Spanish**, calm tone ("Tranquilo…", "Sin presión…"). Never add shaming/urgent copy.
- **Colors only from `AppColor`**; fonts only Sora (titles) / Space Grotesk (body).
- **Responsive first**: use `context.responsive(mobile:, tablet:)` and `contentMaxWidth`; dialogs capped ~340–480 px.
- **Overlays**: registering in `game_page.dart`'s `overlayBuilderMap` is mandatory — an unregistered overlay fails silently at runtime (this exact bug happened with pause).
- **Sound**: all SFX through `SoundService` (never raw `FlameAudio` calls); guard is automatic via the sound toggle; failures must be swallowed — audio never breaks a run.
- **Persistence**: new flags go in `SettingsRepository` with a `settings.*` key; decide explicitly whether `resetProgress()` keeps or wipes them (tutorial flag, difficulty, sound/haptics are kept).
- **No fake-backend claims**: the leaderboard roster and season labels are local samples — never present them as live data.
- **One improvement = one commit**, small and revertible, e.g. `feat: …`, `fix: …`, `docs: …`.

## 6. How to work (humans and AI assistants alike)

1. Read this file, then the files listed in §3 for the area you will touch.
2. Check `git log --oneline` and `git status` — work is incremental; uncommitted work may already exist.
3. Implement the smallest change that solves the problem; update Spanish copy and docs if user-facing.
4. Verify: `flutter analyze` must report **No issues found**. Prefer `flutter build appbundle --release` / `flutter build ios --release --no-codesign` for platform work.
5. Commit independently per improvement so each can be tested and rolled back alone.
6. Never commit `pubspec.lock` (gitignored), `build/`, or incidental files like `ios/Podfile.lock` churn unless they are the point of the change.

## 7. Known issues & honest TODOs (good first contributions)

- `test/game_test.dart` covers difficulty params, ramp base values and the sound guard. Extend it (repositories with fake SharedPreferences, overlay registration) rather than adding widget tests that need a device.
- Unused deps were removed (`zo_animated_border`, `cupertino_icons`). Do not re-add a dependency without a used import.
- Release Android build recently hit a corrupt Gradle transforms cache (`immutable workspace … modified`); clearing `gradle/caches/<ver>/transforms` is the known workaround — investigate a durable fix.
- Weekly mission target (`50000`) and leaderboard rival scores are unreachable versus real single-digit scores — retune or reframe.
- Selected neon palette / comfort toggle affect only the gallery preview, not the in-game orb/bars — wire through or remove the claim.
- Countdown runs ~3.4 s on every retry; consider tap-to-skip or shorter steps.

## 8. How an AI assistant can help most

- **Audit before coding**: read the engine (`night_jump_game.dart`), the component involved, and its overlay before proposing changes.
- **Respect the calm goal**: challenge any idea that adds pressure, grind, or startle (loud sounds, harsh copy, forced waits).
- **Verify by execution**: run `flutter analyze`; sanity-check math (e.g. ramp curves) with a quick script; inspect `overlayBuilderMap` after overlay work.
- **Keep commits atomic** and say which files changed with `path:line` references so the developer can review fast.
- Ask when ambiguous (difficulty numbers, copy wording, platform scope) instead of guessing — a wrong guess here ships player-facing stress.

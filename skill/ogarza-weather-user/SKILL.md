---
name: ogarza-weather-user
description: Control the ogarza.plugins.weather Omarchy overlay with IPC. mode follow does not turn the overlay on — use power on after weather was off. Custom for fire+clouds; layer loudness is param custom strengthA/B/C. Not plugin source.
---

# Omarchy weather overlay (end user)

Control `ogarza.plugins.weather` with IPC. Do not edit `Service.qml`, shaders, `~/.config/hypr/`, or `/usr/share/omarchy/`. IPC setters persist for you.

```bash
omarchy-shell ogarza.plugins.weather <command> [args]
```

Pass `""` to read an optional value without changing it.

## Workflow

1. Map **intent**, then change those knobs. Vague is OK: “raining kind of hard” → bump `param rain density` (read, then raise; default 0.8, max 2.4 — a moderate bump like 1.3, not the max). “Make it beautiful” / pretty / magical on sun, rain, or a mix → **Add Rainbow** (`enableC on` for the current condition). Forest fireflies / floating specks / fairy lights → `mode motes` (or Custom with a motes layer). Night sparkle → `mode stars`. Still field → `param stars sheen 0`. No meteors → `param stars lightning 0`. Ground fog → `mode mist`. Dandelion seeds → `mode pollen`. Bigger drops → `scale`. Faster → `speed`.
2. Do **not** “improve” unrelated sliders. If they did not ask for drop size, leave **scale** (rain/stormy default `1`, not max `2`). Do not crank every key toward 2.
3. `overlay` to learn mode / live weather. Tune the matching condition (`sunshower`, `rain`, …). Stay on Follow if they are following.
4. Read the key, then set. Rain a bit harder:

```bash
omarchy-shell ogarza.plugins.weather param rain density ""
omarchy-shell ogarza.plugins.weather param rain density 1.3
omarchy-shell ogarza.plugins.weather power on
```

5. Two or more looks at once (fire and clouds, rain and fire, …) if it is not a named mix → **Custom**. Clouds = `fog`. See Custom below. “Make the fire less strong” then → that **slot’s** `param custom strengthA|B|C`, not `param fire strength`.
6. `mode rain` only if they want that as the mode. Rain mixes share `param rain …`.
7. **Power vs mode:** turning weather off is `power off`. Follow / Exclusive / a look they want to *see* also needs `power on`. `mode follow` alone leaves the overlay off.
8. Plugin source or shaders: out of scope.

## Commands

| Command | Use |
|---------|-----|
| `power` `[on\|off\|toggle]` | Overlay on/off. **Independent of mode.** `mode follow` does not turn it on. After they asked to turn weather off, any “show it again” / Follow / rain / Custom needs `power on` |
| `mode` `[id]` | `none`, `rain`, `snow`, `fog`, `sunny`, `partly`, `overcast`, `sunshower`, `moonlit`, `drizzle`, `squall`, `wintry`, `stormy`, `follow`, `exclusive`, `fire`, `motes`, `mist`, `stars`, `pollen`, `rainbow`, `custom` |
| `track` `[preset]` | Exclusive track only (not fire/motes/mist/stars/pollen/rainbow/custom) |
| `layer` `<a\|b\|c>` `[shader]` | Custom mode only. Slot shader: `rain`, `snow`, `fog`, `sunny`, `stormy`, `fire`, `motes`, `mist`, `stars`, `pollen`, `rainbow`, or `none` |
| `param` `<preset>` `<key>` `[value]` | Slider. `%` ok. **Add Rainbow** is `enableC` `on`/`off`/`toggle` on the condition id (`sunshower`, `rain`, …). `nightVisible` and `overrideHue` same. |
| `quality` `[low\|medium\|high\|extreme]` | Sets both Resolution and Effect detail. Read may be `resolution,detail` if they differ |
| `resolution` `[low\|medium\|high\|native]` | Overlay render scale |
| `detail` `[level]` or `rain high` etc. | All shaders that have Effect detail, or one of rain/stormy/snow/fog/sunny/fire/motes/mist/stars/rainbow. Pollen has no detail row. Blank read is one word if they match |
| `distortion` / `hypr` `[on\|off\|toggle]` | Distortion. Whole screen: Hyprland warp. Wallpaper: cached wallpaper image. Default on. Read with `distortion ""`. `hypr` is the same |
| `target` `[screen\|wallpaper\|toggle]` | Whole screen vs wallpaper only. Default `screen`. Read with `target ""` |
| `reset` | Default sliders (not mode/resolution/detail/distortion/target) |
| `preview` `<preset>` | Follow + fade to that look |
| `refresh` | Fetch weather again |
| `overlay` | JSON state (`target`, `wallpaperWarp`, mode, detail, Distortion, …) |

## Param keys

Shader presets (`param rain density`, not the mix id):

| Preset | Keys |
|--------|------|
| `rain` | `density` (0–2.4), `speed`, `scale` (0–2), `glow` (sheen), `darken`, `refract` (0–1) |
| `snow` | `density`, `speed`, `scale`, `glow` |
| `fog` | `density`, `speed`, `scale` |
| `sunny` | `glow`, `speed`, `density` (dust), `azimuth` (position), `lightning` (height; −2–2, 0 = just above the top), `scale` (source; 0 = point, up = sphere), `distance`, `overrideHue` (`on`/`off`/`toggle`), `frequency` (hue when override is on) |
| `stormy` | `density` (0–2.4), `speed`, `scale` (0–2), `sheen`, `refract`, `lightning`, `frequency`, `glow` (gloom), `azimuth` |
| `fire` | `density`, `speed`, `scale`, `glow` |
| `motes` | `density`, `speed`, `scale` (size), `glow`, `lightning` (glow pulse), `azimuth` (hue 0–2), `frequency` (saturation) |
| `mist` | `density`, `speed`, `scale`, `glow`, `sheen` (start; −2–2, 0 = floor), `lightning` (height; packs the bank), `azimuth` (hue) |
| `stars` | `density` (0–2.4), `speed` (twinkle amount; 0 = off), `scale`, `glow`, `sheen` (parallax; 0 = still), `lightning` (shooting stars; 0 = none), `azimuth` (hue), `frequency` (saturation) |
| `pollen` | `density`, `speed`, `scale`, `glow`, `sheen` (wind; 0 = up), `lightning` (tumble), `azimuth` (hue), `frequency` (saturation) |
| `rainbow` | `glow`, `density`, `scale` (0–4), `azimuth`, `lightning` (−2–2 height), `distance`, `speed`, `nightVisible`, `nightTint`, `nightStrength` |

Unless noted, sliders are 0–2. Named mixes take `strengthA` / `strengthB` / `strengthC` on the **condition** id (`param drizzle strengthB`). Standalone Rain uses `param rain strength`. **Custom mix loudness is `param custom strengthA` / `strengthB` / `strengthC` (0–1)** for slots A/B/C. Shader look (density, glow, …) stays on the shader (`param fire glow`). `param fire strength` only affects standalone `mode fire`, not a Custom fire layer.

Factory defaults (stored numbers). Start from these or from the live value (`param … ""`). `reset` restores the table. Do not write a default back unless they asked to reset.

| Preset | Defaults |
|--------|----------|
| `rain` | strength 1, density 0.8, speed 1, **scale 1**, glow 0.6, darken 1, refract 1, enableC off, strengthC 0.65 |
| `snow` | strength 1, density 0.8, speed 1, **scale 0.8**, glow 0.3, enableC off, strengthC 0.65 |
| `fog` | strength 1, density 1, speed 0.9, **scale 1**, enableC off, strengthC 0.65 |
| `sunny` | strength 1, glow 1, speed 1, density 1.2, azimuth 1.2, lightning 0 (height), **scale 0** (point source), distance 1, overrideHue off, frequency 0.24 (hue), enableC off, strengthC 0.65 |
| `stormy` | strength 1, density 1, speed 1.15, **scale 1**, sheen 0.6, refract 1, lightning 1.5, frequency 1, glow 1, azimuth 1, enableC off, strengthC 0.65 |
| `fire` | strength 1, density 1, speed 0.5, **scale 1**, glow 1, enableC off, strengthC 0.65 |
| `motes` | strength 1, density 1, speed 0.7, **scale 1**, glow 1.1, lightning 1, azimuth 0.24, frequency 1.1, enableC off, strengthC 0.65 |
| `mist` | strength 1, density 1.1, speed 0.55, **scale 1.15**, glow 0.85, sheen 0 (floor), lightning 1.5 (height), azimuth 0.58, enableC off, strengthC 0.65 |
| `stars` | strength 1, density 1.7, speed 0.85, **scale 0.4**, glow 0.9, sheen 0.7, lightning 0.55, azimuth 0.58, frequency 0.2, enableC off, strengthC 0.65 |
| `pollen` | strength 1, density 0.75, speed 0.5, **scale 1.1**, glow 0.45, sheen 0 (wind up), lightning 0.85, azimuth 0.14, frequency 0.55, enableC off, strengthC 0.65 |
| `rainbow` | strength 1, glow 1, density 1, **scale 1**, azimuth 0.8, lightning 0.65, distance 1, speed 1, nightVisible off, nightTint 1, nightStrength 0.7 |

Mix layer strengths default per condition (enableC off, strengthC 0.65): partly A 0.5 B 0.85; overcast A 1 B 0.18; sunshower A 0.6 B 0.7; moonlit A 0.35 B 0.9; drizzle A 0.55 B 0.5; squall A 0.8 B 0.4; wintry A 1 B 0.5; custom A/B/C 0.7.

## Add Rainbow

Panel **Add Rainbow** is `enableC` on that condition (not on `follow` / `exclusive` / `rainbow` / `custom`). Off by default. Bow look is `param rainbow …`. Strength is `param <condition> strengthC`. Custom uses `layer c rainbow` instead.

Already in Sun shower:

```bash
omarchy-shell ogarza.plugins.weather param sunshower enableC ""
omarchy-shell ogarza.plugins.weather param sunshower enableC on
omarchy-shell ogarza.plugins.weather param sunshower enableC toggle
omarchy-shell ogarza.plugins.weather param sunshower enableC off
```

Follow with live sun shower: still `param sunshower enableC on` (leave `mode follow`). Same pattern for `rain`, `sunny`, `drizzle`, `stormy`, `fire`, and the other mixes.

## Distortion

`distortion` is the global toggle (same as the panel switch). `hypr` is an alias. Do not edit `~/.config/hypr/`.

- **On** (default): rain/storm **Refract** warps. Screen target: Hyprland `screen_shader`. Wallpaper target: `wallpaper_warp.frag` over Omarchy’s background. Painted rain is skipped while refract is above 0.
- **Off**: overlay only; Refract sliders stay as they are. The screen shader clears.
- Amount is still the slider: `param rain refract`, `param stormy refract`. `refract 0` is painted rain even with `distortion on`.

```bash
omarchy-shell ogarza.plugins.weather distortion ""
omarchy-shell ogarza.plugins.weather distortion off
omarchy-shell ogarza.plugins.weather distortion on
omarchy-shell ogarza.plugins.weather distortion toggle
omarchy-shell ogarza.plugins.weather target ""
omarchy-shell ogarza.plugins.weather target wallpaper
omarchy-shell ogarza.plugins.weather target screen
```

## Custom (three layers)

Named mixes are only the mode ids (`sunshower`, `drizzle`, `partly`, …). **Fire + clouds is not a named mix.** Stack it with Custom. Clouds / Cloud/Fog = `fog`.

`mode custom` then `layer` (only works in Custom). `none` turns a slot off. `overlay` does not list slots — read them:

```bash
omarchy-shell ogarza.plugins.weather layer a ""
omarchy-shell ogarza.plugins.weather layer b ""
omarchy-shell ogarza.plugins.weather layer c ""
```

How loud that slot is: `param custom strengthA` (slot a), `strengthB` (b), `strengthC` (c). Default 0.7. How the fire *looks* (flames, glow): `param fire …`.

Fire and clouds:

```bash
omarchy-shell ogarza.plugins.weather mode custom
omarchy-shell ogarza.plugins.weather layer a fog
omarchy-shell ogarza.plugins.weather layer b fire
omarchy-shell ogarza.plugins.weather layer c none
omarchy-shell ogarza.plugins.weather power on
```

Then “make the fire less strong” (fire is B):

```bash
omarchy-shell ogarza.plugins.weather param custom strengthB ""
omarchy-shell ogarza.plugins.weather param custom strengthB 0.35
```

If fire is on A, use `strengthA`. Do not set `param fire strength` for this.

## Examples

- “Raining kind of hard” → raise `param rain density` from current/default 0.8 (e.g. 1.2–1.5). Leave scale at 1 unless they want bigger drops.
- “Make it beautiful” on sun shower / rain / sunny → `param <condition> enableC on` (Add Rainbow). Do not max scale.
- Rays from mid-screen → `param sunny lightning` around 1 (0 is just above the top). Horizontal is `param sunny azimuth`. Ball of light → raise `param sunny scale` from 0 (point) toward 1–2 (sphere). Lock color off the clock → `param sunny overrideHue on` then `param sunny frequency` (hue).
- Forest fireflies / fairy lights → `mode motes` then `power on`. More specks → `param motes density`. Color is `param motes azimuth` (hue) and `param motes frequency` (saturation). Size `scale`, halo `glow`, breathe `lightning`.
- Night sparkle / stars → `mode stars` then `power on`. Still field → `param stars sheen 0`. No twinkle → `param stars speed 0`. Harder pulse → raise `param stars speed` (amount, not rate). No meteors → `param stars lightning 0`. `mode sparkle` is the same as Stars.
- Ground mist / rolling fog → `mode mist` then `power on`. Not Cloud/Fog (`fog`). Shorter denser bank → lower `param mist lightning`. Lift off the floor → raise `param mist sheen`. Heavier on the floor / below the bezel → negative `param mist sheen`.
- Pollen / dandelion seeds → `mode pollen` then `power on`. Wind heading is `param pollen sheen` (0 = up). Spin is `param pollen lightning`. There is no `detail pollen` — Effect detail does not apply.
- Bigger flakes/drops → `param snow scale` or `param rain scale` (rain max 2; default 1).
- Rainbow on Sun shower → `param sunshower enableC on`. Follow: same, do not switch mode.
- “Fire and clouds” / fire + fog → Custom: `layer a fog`, `layer b fire`, `layer c none`. Then weaker fire → `param custom strengthB` (the fire slot), not `param fire strength`.
- Stack rain, fog, and fire → Custom, three layers.
- Turn off desktop warp → `distortion off`. Weaker warp → lower `param rain refract`.
- Follow the forecast → `mode follow` **and** `power on` (mode does not enable the overlay). After they turned weather off, both:

```bash
omarchy-shell ogarza.plugins.weather mode follow
omarchy-shell ogarza.plugins.weather power on
```
- Overlay off → `power off`.

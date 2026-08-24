---
name: ogarza-weather-user
description: Control the ogarza.plugins.weather Omarchy overlay with IPC. Interpret look requests (harder rain → density, beautiful → Add Rainbow, bigger drops → scale). Use for modes, Custom stacks, Follow, Hyprland distortion — not plugin source.
---

# Omarchy weather overlay (end user)

Control `ogarza.plugins.weather` with IPC. Do not edit `Service.qml`, shaders, `~/.config/hypr/`, or `/usr/share/omarchy/`. IPC setters persist for you.

```bash
omarchy-shell ogarza.plugins.weather <command> [args]
```

Pass `""` to read an optional value without changing it.

## Workflow

1. Map **intent**, then change those knobs. Vague is OK: “raining kind of hard” → bump `param rain density` (read, then raise; default 0.8, max 2.4 — a moderate bump like 1.3, not the max). “Make it beautiful” / pretty / magical on sun, rain, or a mix → **Add Rainbow** (`enableC on` for the current condition). Bigger drops → `scale`. Faster → `speed`.
2. Do **not** “improve” unrelated sliders. If they did not ask for drop size, leave **scale** (rain/stormy default `1`, not max `2`). Do not crank every key toward 2.
3. `overlay` to learn mode / live weather. Tune the matching condition (`sunshower`, `rain`, …). Stay on Follow if they are following.
4. Read the key, then set. Rain a bit harder:

```bash
omarchy-shell ogarza.plugins.weather param rain density ""
omarchy-shell ogarza.plugins.weather param rain density 1.3
omarchy-shell ogarza.plugins.weather power on
```

5. `mode rain` only if they want that as the mode. Rain mixes share `param rain …`.
6. Plugin source or shaders: out of scope.

## Commands

| Command | Use |
|---------|-----|
| `power` `[on\|off\|toggle]` | Overlay on/off |
| `mode` `[id]` | `none`, `rain`, `snow`, `fog`, `sunny`, `partly`, `overcast`, `sunshower`, `moonlit`, `drizzle`, `squall`, `wintry`, `stormy`, `follow`, `exclusive`, `fire`, `rainbow`, `custom` |
| `track` `[preset]` | Exclusive track only (not fire/rainbow/custom) |
| `layer` `<a\|b\|c>` `[shader]` | Custom mode only. Slot shader: `rain`, `snow`, `fog`, `sunny`, `stormy`, `fire`, `rainbow`, or `none` |
| `param` `<preset>` `<key>` `[value]` | Slider. `%` ok. **Add Rainbow** is `enableC` `on`/`off`/`toggle` on the condition id (`sunshower`, `rain`, …). `nightVisible` same. Temperature: °C or `90F` |
| `quality` `[low\|medium\|high\|extreme]` | Cost vs sharpness |
| `hypr` `[on\|off\|toggle]` | Panel **Hyprland distortion**. Global on/off for desktop warp. Default on. Read with `hypr ""` |
| `reset` | Default sliders (not mode/quality/hypr) |
| `preview` `<preset>` | Follow + fade to that look |
| `refresh` | Fetch weather again |
| `overlay` | JSON state |

## Param keys

Shader presets (`param rain density`, not the mix id):

| Preset | Keys |
|--------|------|
| `rain` | `density` (0–2.4), `speed`, `scale` (0–2), `glow` (sheen), `darken`, `refract` (0–1) |
| `snow` | `density`, `speed`, `scale`, `glow` |
| `fog` | `density`, `speed`, `scale` |
| `sunny` | `glow`, `speed`, `density` (dust), `azimuth`, `distance`, `haze` (0–1), `temperature` (10–49 °C) |
| `stormy` | `density` (0–2.4), `speed`, `scale` (0–2), `sheen`, `refract`, `lightning`, `frequency`, `glow` (gloom), `azimuth` |
| `fire` | `density`, `speed`, `scale`, `glow`, `haze` |
| `rainbow` | `glow`, `density`, `scale` (0–4), `azimuth`, `lightning` (−2–2 height), `distance`, `speed`, `nightVisible`, `nightTint`, `nightStrength` |

Unless noted, sliders are 0–2. Mixes also take `strengthA` / `strengthB` / `strengthC` (0–1) on the **condition** id (`param drizzle strengthB`). Singles use `param rain strength`. Custom uses `param custom strengthA` / `strengthB` / `strengthC` (0–1); look knobs stay on the shader (`param rain density`).

Factory defaults (stored numbers). Start from these or from the live value (`param … ""`). `reset` restores the table. Do not write a default back unless they asked to reset.

| Preset | Defaults |
|--------|----------|
| `rain` | strength 1, density 0.8, speed 1, **scale 1**, glow 0.6, darken 1, refract 1, enableC off, strengthC 0.65 |
| `snow` | strength 1, density 0.8, speed 1, **scale 0.8**, glow 0.3, enableC off, strengthC 0.65 |
| `fog` | strength 1, density 1, speed 0.9, **scale 1**, enableC off, strengthC 0.65 |
| `sunny` | strength 1, glow 1, speed 1, density 1.2, azimuth 1.2, distance 1, haze 0.5, temperature 32.2 (°C), enableC off, strengthC 0.65 |
| `stormy` | strength 1, density 1, speed 1.15, **scale 1**, sheen 0.6, refract 1, lightning 1.5, frequency 1, glow 1, azimuth 1, enableC off, strengthC 0.65 |
| `fire` | strength 1, density 1, speed 0.5, **scale 1**, glow 1, haze 0.5, enableC off, strengthC 0.65 |
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

## Hyprland distortion

`hypr` is the global toggle (same as the panel switch). Do not edit `~/.config/hypr/`.

- **On** (default): rain/storm **Refract** and sunny/fire **Haze** can warp the real desktop. Painted rain is skipped while refract is above 0.
- **Off**: overlay only; refract/haze sliders stay as they are. The screen shader clears.
- Amount is still the slider: `param rain refract`, `param stormy refract`, `param sunny haze`, `param fire haze`. `refract 0` is painted rain even with `hypr on`. Sunny haze also needs outdoor temperature at or above `param sunny temperature`.

```bash
omarchy-shell ogarza.plugins.weather hypr ""
omarchy-shell ogarza.plugins.weather hypr off
omarchy-shell ogarza.plugins.weather hypr on
omarchy-shell ogarza.plugins.weather hypr toggle
```

## Custom (three layers)

`mode custom` stacks up to three shaders. `layer` does nothing in other modes. `none` turns a slot off. Look sliders are shared with standalone Rain, Fog, etc.

```bash
omarchy-shell ogarza.plugins.weather mode custom
omarchy-shell ogarza.plugins.weather layer a rain
omarchy-shell ogarza.plugins.weather layer b fog
omarchy-shell ogarza.plugins.weather layer c fire
omarchy-shell ogarza.plugins.weather power on
```

## Examples

- “Raining kind of hard” → raise `param rain density` from current/default 0.8 (e.g. 1.2–1.5). Leave scale at 1 unless they want bigger drops.
- “Make it beautiful” on sun shower / rain / sunny → `param <condition> enableC on` (Add Rainbow). Do not max scale.
- Bigger flakes/drops → `param snow scale` or `param rain scale` (rain max 2; default 1).
- Rainbow on Sun shower → `param sunshower enableC on`. Follow: same, do not switch mode.
- Stack rain, fog, and fire → Custom recipe above.
- Turn off desktop warp → `hypr off`. Weaker warp → lower `param rain refract` / `param sunny haze`.
- Follow the forecast → `mode follow`.
- Overlay off → `power off`.

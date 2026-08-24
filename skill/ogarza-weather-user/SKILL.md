---
name: ogarza-weather-user
description: Control the ogarza.plugins.weather Omarchy overlay with IPC (rain, snow, fog, sun, storm, fire, rainbow, Custom three-layer stack, Follow, Hyprland refraction/haze). Use when the user wants to change the look, make it rain harder, stack custom layers, turn distortion on or off, or switch modes — not when editing plugin source.
---

# Omarchy weather overlay (end user)

Control `ogarza.plugins.weather` with IPC. Do not edit `Service.qml`, shaders, `~/.config/hypr/`, or `/usr/share/omarchy/`. IPC setters persist for you.

```bash
omarchy-shell ogarza.plugins.weather <command> [args]
```

Pass `""` to read an optional value without changing it.

## Workflow

1. `overlay` if you need current mode / power / hypr.
2. Relative tweaks: read, then set a number in range. Example — rain harder:

```bash
omarchy-shell ogarza.plugins.weather param rain density ""
omarchy-shell ogarza.plugins.weather param rain density 1.4
omarchy-shell ogarza.plugins.weather power on
```

3. Switch to `mode rain` only if they want rain as the mode. If they are on Follow / Exclusive / a rain mix (drizzle, stormy, sunshower, wintry), leave the mode and change `param rain …` — those sliders are shared.
4. Plugin source or shaders: out of scope.

## Commands

| Command | Use |
|---------|-----|
| `power` `[on\|off\|toggle]` | Overlay on/off |
| `mode` `[id]` | `none`, `rain`, `snow`, `fog`, `sunny`, `partly`, `overcast`, `sunshower`, `moonlit`, `drizzle`, `squall`, `wintry`, `stormy`, `follow`, `exclusive`, `fire`, `rainbow`, `custom` |
| `track` `[preset]` | Exclusive track only (not fire/rainbow/custom) |
| `layer` `<a\|b\|c>` `[shader]` | Custom mode only. Slot shader: `rain`, `snow`, `fog`, `sunny`, `stormy`, `fire`, `rainbow`, or `none` |
| `param` `<preset>` `<key>` `[value]` | Slider. `%` ok. `enableC` / `nightVisible`: `on`/`off`. Temperature: °C or `90F` |
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

Unless noted, sliders are 0–2. Mixes also take `strengthA` / `strengthB` / `strengthC` (0–1) and `enableC` (`on`/`off`) on the **mode** id (`param drizzle strengthB`). Singles use `param rain strength`. Custom uses `param custom strengthA` / `strengthB` / `strengthC` (0–1); look knobs stay on the shader (`param rain density`).

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
omarchy-shell ogarza.plugins.weather param custom strengthA 0.7
omarchy-shell ogarza.plugins.weather param custom strengthB 0.5
omarchy-shell ogarza.plugins.weather param custom strengthC 0.4
omarchy-shell ogarza.plugins.weather power on
```

## Examples

- Rain harder → read/set `param rain density`; `power on`.
- Stack rain, fog, and fire → Custom recipe above.
- Turn off desktop warp → `hypr off`. Turn it back on → `hypr on`. Weaker warp with distortion still on → lower `param rain refract` / `param sunny haze`.
- Follow the forecast → `mode follow`.
- Overlay off → `power off`.

# ogarza.plugins.weather

Omarchy Quickshell plugin: fullscreen Wayland overlay shaders plus an optional Hyprland screen shader. Id `ogarza.plugins.weather`.

## Layout

| Path | Role |
|------|------|
| `Service.qml` | Overlay, fetch, persist, compositor, Hyprland apply/clear, wallpaper target |
| `Panel.qml` / `BarWidget.qml` | UI + IPC `ogarza.plugins.weather` |
| `Model.js` | Modes, mixes, WMO/wttr maps, params, `visualNeedsScreenShader`, `pluginId` |
| `PollenSim.js` | CPU UV pollen flock; each seed is a small `ShaderEffect` sprite (`pollen.frag`) |
| `MotesSim.js` | CPU UV motes; same wander as the old hash-grid (home + sin/cos), one sprite each |
| `HyprShader.js` | Generated GLES 300 es `decoration.screen_shader` (rain refract) |
| `shaders/*.frag` | Overlay effects + `wallpaper_warp.frag`; committed `*.frag.qsb` |
| `docs/wallpaper-target.md` | Screen vs wallpaper, GPU cache, path watch |

Do not edit `/usr/share/omarchy/`. Hot-reload on save under `~/.config/omarchy/plugins/`.

## Rules of thumb

- Overlay is premultiplied alpha. Uniform block must stay aligned across shaders (unused fields still listed). End the block with `float quality` (0–3, **effect detail**). Framebuffer `resolution` is device pixels × **Resolution** scale (not the Settings enum name). Pollen and motes are CPU lists drawn as one small overlay sprite per seed (not a fullscreen particle loop).
- Hyprland screen shader: while `hyprEnabled` and overlay target is screen, keep one program applied (rain helpers; unused rain amount is 0). Generate via `HyprShader.js` into `${XDG_STATE_HOME}/ogarza.plugins.weather/current.a.frag` or `current.b.frag`. `hyprctl eval` with `damage_tracking` first then `screen_shader`. Uniforms: `tex`, `fullSize`, `time` only. Bake sliders as consts. Rain amount mixes `FROM`→`TO` on `time`; motion uses `time + TIME_OFFSET`. Fade length is `hyprRainFadeSec`, or the overlay fade when a mode crossfade is running. Never write `~/.config/hypr/` or `/usr/share/omarchy/`. Wallpaper target (`overlayTarget`): `WlrLayer.Bottom`, **clear** `screen_shader` immediately (do not fade). Rain refraction via `wallpaper_warp.frag` (not in painted overlay). Skip painted rain when `hyprEnabled` and `refract` > 0 (`overlaySkipsRainDrops`). Stormy bolts stay overlay with drop density 0. Clear also when distortion turns off (with fade). Regen on `configreloaded`. Persist `hyprEnabled` (default on), `overlayTarget` (default `screen`), `resolution` (compositor scale; Native skips the downscale blit), `detail` (last all-shader LOD), and `shaderDetail` (per-shader LOD / `quality` uniform). Scan sibling plugin folders for `screen_shader` and surface names on the panel. Overlay `*.frag.qsb` are committed; `scanShaders` rebuilds them when `qsb` (`qt6-shadertools`, usually `/usr/lib/qt6/bin/qsb`) is present. Panel warns if a baked overlay shader is missing.
- Follow/Exclusive: never fire, motes, mist, stars, pollen, rainbow, or custom. Wait for `locationReady` before fetch. Open-Meteo if lat/lon; else wttr. Parse WMO `0` without `code \|\| ""`.
- Visual target is a mode id. Mixes use two or three shader slots + `strengthA`/`strengthB`/`strengthC`. Optional rainbow uses `enableC` on every visual except standalone rainbow. Custom layers persist `customShaderA` / `customShaderB` / `customShaderC` (`none` turns a slot off). **Resolution** (`low`/`medium`/`high`/`native`) downscales the compositor stack except Native. **Effect detail** is per shader (`shaderDetail`, rank 0–3 on `quality`). Crossfade: `overlayFromPreset` → `overlayToPreset`, 10s follow / 2s panel.
- Default mode is `none` (overlay off). Panel **Settings** (same row id) does not call `setMode`. First snap after persist load; then always fade.
- After `.frag` edits, next `scanShaders` rebuilds `.qsb` when `qsb` is installed; commit the new `.qsb`. **`qsb` OK ≠ overlay works.** Stormy lightning must stay scalar (`boltPoint` / `strokeChannel`). Arrays, `inout` point lists, midpoint-eval, and baked `const` tables all blanked the fullscreen ShaderEffect (rain included). See `.cursor/rules/shaders.mdc`.
- Panel: params in columns (`fieldsForVisualLayer` / `fieldsForPanel`). Settings page: Resolution + per-shader Effect detail (`settingsLodRows`). Follow uses `weatherPreset`; Exclusive uses `exclusivePreset`. Mixes edit layer strengths plus each layer shader’s params. User-facing changes also update README, CHANGELOG, and `manifest.json`.

## IPC

```
omarchy-shell ogarza.plugins.weather power toggle
omarchy-shell ogarza.plugins.weather mode rain
omarchy-shell ogarza.plugins.weather preview rain
omarchy-shell ogarza.plugins.weather overlay
omarchy-shell ogarza.plugins.weather quality high
omarchy-shell ogarza.plugins.weather resolution native
omarchy-shell ogarza.plugins.weather detail high
omarchy-shell ogarza.plugins.weather distortion off
omarchy-shell ogarza.plugins.weather target wallpaper
```

## Skills / rules

- `.cursor/rules/` — conventions (always + shaders + docs).
- `.cursor/skills/ogarza-weather/` — change workflow (plugin source).
- `skill/ogarza-weather-user/` — end-user IPC skill (install via README).

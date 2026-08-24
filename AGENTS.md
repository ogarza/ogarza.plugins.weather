# ogarza.plugins.weather

Omarchy Quickshell plugin: fullscreen Wayland overlay shaders plus an optional Hyprland screen shader. Id `ogarza.plugins.weather`.

## Layout

| Path | Role |
|------|------|
| `Service.qml` | Overlay, fetch, persist, compositor, Hyprland apply/clear |
| `Panel.qml` / `BarWidget.qml` | UI + IPC `ogarza.plugins.weather` |
| `Model.js` | Modes, mixes, WMO/wttr maps, params, `visualNeedsScreenShader`, `pluginId` |
| `HyprShader.js` | Generated GLES 300 es `decoration.screen_shader` (rain refract / haze) |
| `shaders/*.frag` | Overlay effects; committed `*.frag.qsb` (rebuild with `qsb` after edits) |

Do not edit `/usr/share/omarchy/`. Hot-reload on save under `~/.config/omarchy/plugins/`.

## Rules of thumb

- Overlay is premultiplied alpha. Uniform block must stay aligned across shaders (unused fields still listed). End the block with `float quality` (0–3). `resolution` is framebuffer pixels (DPR × quality).
- Hyprland screen shader (rain or stormy `refract` > 0, or sunny/fire `haze` > 0): generate via `HyprShader.js`, write `${XDG_STATE_HOME}/ogarza.plugins.weather/current.frag`, `hyprctl eval` with `damage_tracking` first then `screen_shader`. Uniforms: `tex`, `fullSize`, `time` only. Bake sliders as consts. Haze is a small heat warp, no cursor bulge. Never write `~/.config/hypr/` or `/usr/share/omarchy/`. Skip painted rain while Hyprland rain is live (`kind` contains `rain`), including stormy drops. Stormy bolts stay overlay. Regen on `configreloaded`. Clear restores captured `hyprBaseDamage`. Persist `hyprEnabled` (default on); off skips apply and clears. Scan sibling plugin folders for `screen_shader` and surface names on the panel. Overlay `*.frag.qsb` are committed; `scanShaders` rebuilds them when `qsb` (`qt6-shadertools`, usually `/usr/lib/qt6/bin/qsb`) is present. Panel warns if a baked overlay shader is missing.
- Follow/Exclusive: never fire, rainbow, or custom. Wait for `locationReady` before fetch. Open-Meteo if lat/lon; else wttr. Parse WMO `0` without `code \|\| ""`.
- Visual target is a mode id. Mixes use two or three shader slots + `strengthA`/`strengthB`/`strengthC`. Optional rainbow uses `enableC` on every visual except standalone rainbow. Custom layers persist `customShaderA` / `customShaderB` / `customShaderC` (`none` turns a slot off). Quality (`low`/`medium`/`high`/`extreme`) downscales the compositor stack (layer texture) except Extreme. Crossfade: `overlayFromPreset` → `overlayToPreset`, 10s follow / 2s panel.
- Default mode is `none`. First snap after persist load; then always fade.
- After `.frag` edits, next `scanShaders` rebuilds `.qsb` when `qsb` is installed; commit the new `.qsb`. **`qsb` OK ≠ overlay works.** Stormy lightning must stay scalar (`boltPoint` / `strokeChannel`). Arrays, `inout` point lists, midpoint-eval, and baked `const` tables all blanked the fullscreen ShaderEffect (rain included). See `.cursor/rules/shaders.mdc`.
- Panel: params in columns (`fieldsForVisualLayer` / `fieldsForPanel`). Follow uses `weatherPreset`; Exclusive uses `exclusivePreset`. Mixes edit layer strengths plus each layer shader’s params. User-facing changes also update README, CHANGELOG, and `manifest.json`.

## IPC

```
omarchy-shell ogarza.plugins.weather power toggle
omarchy-shell ogarza.plugins.weather mode rain
omarchy-shell ogarza.plugins.weather preview rain
omarchy-shell ogarza.plugins.weather overlay
omarchy-shell ogarza.plugins.weather quality high
omarchy-shell ogarza.plugins.weather hypr off
```

## Skills / rules

- `.cursor/rules/` — conventions (always + shaders + docs).
- `.cursor/skills/ogarza-weather/` — change workflow.

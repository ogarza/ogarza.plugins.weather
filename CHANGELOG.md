# Changelog

## 1.9.1

- Custom layers are **dropdowns** (A / B / C) instead of three full stacked lists, so the panel stays shorter.

## 1.9.0

- **Pollen** and **Motes** are CPU flocks (one overlay sprite per seed, not a fullscreen gather loop). Density 0–200% is about 4–192 specks. Pollen has **Wind** (`sheen`, 0 = up) and **Tumble**. Motes keep the old home + sin/cos wander and per-speck glow pulse.
- Settings Effect detail: Motes is wander grid (sprites, not a hash-grid). **Pollen has no Effect detail row** (sprite `quality` is unused). Wallpaper warp follows Rain or Stormy detail — no extra row. IPC `detail pollen …` returns `unknown-shader`. `overlay` JSON includes `target` and `wallpaperWarp`.
- Motes/Pollen panel sliders apply when you release the bar (rain and other GPU looks still update while dragging).
- Speck **Size** is about one third of the first sprite pass.

## 1.8.0

- **Mist**, **Stars**, and **Pollen** (manual only, overlay only). Follow never picks them. Custom can stack them.
- Stars: hash-grid field. **Twinkle amount** is pulse depth (0 = off / pixel-snapped). Rate is fixed. **Shooting stars** pick heading and near/far each pass, about one quarter the first meteor rate. Density 0–240%. IPC `mode sparkle` is Stars. Particle size against `1080 × pixelRatio` like rain.
- Mist is ground-hugging haze (the inverse of Cloud/Fog). Pollen is lifting dandelion-like seeds (**Tumble**).

## 1.7.0

- **Motes** (manual only): floating glowing specks. **Hue**, **Saturation**, **Size**, **Glow**, **Glow pulse** (per-mote, independent of drift). **Density** is mote count (not glow). Overlay only. Custom can stack it. Follow never picks it.
- **Settings** (was None): does not change the overlay. Wider panel with chips on the left and a what/cost note on the right. **Resolution** is render scale. **All looks** plus per-shader Effect detail (Rain, Stormy, Fire, Fog, Snow, Sunny, Motes, Rainbow). IPC `detail high` sets all; `detail rain low` sets one. **Quality** still sets Resolution + all detail (`extreme` → Native + Extreme). Overlay off is power or `mode none`.
- **Wallpaper only** (`target wallpaper`): overlay on the wallpaper layer. Hyprland `screen_shader` is cleared immediately. Rain refraction is `wallpaper_warp.frag`. Notes: `docs/wallpaper-target.md`.
- **Distortion** (panel + IPC `distortion`; `hypr` still works): rain and storm **Refract** only. Heat haze, Sunny/Fire Haze, and On above are gone.

## 1.6.5

- End-user agent skill updated so weaker models hit the right IPC: map vague looks (harder rain → density, beautiful → Add Rainbow), keep factory defaults instead of maxing scale, use Custom for fire+clouds, weaken a stacked fire with `param custom strengthA|B|C`, and pair `mode follow` with `power on` after the overlay was off.

## 1.6.4

- Optional end-user agent skill at `skill/ogarza-weather-user/` (IPC: modes, Custom, Hyprland distortion, Add Rainbow). README install and uninstall are both optional.
- Standardized IPC: optional values trim whitespace. Blank (`""` or spaces) prints the current setting and does not set; same rule for power, mode, track, layer, param, quality, and hypr. `enableC` / `nightVisible` accept `on`/`off`/`toggle` (toggle uses the current value). Add Rainbow is `param sunshower enableC on` while already in that look.

## 1.6.3

- Rain and Stormy drops keep their size when Hyprland distortion turns off or you leave those modes.
- Rain uses Hyprland or the painted overlay, not both — including while modes fade.
- Hyprland rain and haze ease in and out instead of cutting. Mode changes use the overlay fade length; the distortion toggle uses 0.6s.
- Distortion on keeps one combined Hyprland shader (rain + haze). Unused rain or haze is 0; Fog and Snow stay applied. Rebuilds keep the drop clock so a fade does not jump. Rain and Stormy ease to 0 when you leave them (including Cloud/Fog). Clear `screen_shader` only when distortion turns off.
- Rain **Darken** (default 100%) controls how much drops tint the glass.
- Rain and Stormy **Scale** go to 200%. The old 100% size is now 50% (default stays that size).

## 1.6.2

- Plugin id is `ogarza.plugins.weather` (bar slot, IPC, `omarchy plugin enable`). State dir is `~/.local/state/ogarza.plugins.weather/`.
- Bar icon is now the creation sparkle.
- Overlay `.frag.qsb` files ship in `shaders/` so the painted overlay works without `qt6-shadertools`. The panel warns only if those compiled shaders are missing. Rebuild with `qsb` after editing a `.frag`.
- Install and uninstall docs cover `qt6-shadertools` (`omarchy pkg add`, optional `omarchy pkg drop`).

## 1.6.1

- Rainbow **After sunset** (off by default) keeps the bow at night. **Night glow** cools it toward ice-blue; **Night strength** sets night opacity. Arc is placed in screen-height space so it lands on-screen at common aspects.
- Overlay shaders share one uniform layout and take **framebuffer** resolution (device pixel ratio × quality scale) so rain, snow, fire, bolts, and bows scale with HiDPI and Quality.
- Rain and Stormy drop LOD: Low uses the old Medium layers (static beads on), Medium matches High (second rolling pass, spec, meniscus). Extreme still adds a third pass. Render scale is unchanged (33% / 50% / 75% / 100%).
- Mode descriptions in the panel (and README) call out the easy-to-miss behaviors: twilight sun→moon, rainbow night fade, haze temperature gate, Hyprland skipping painted rain, and so on.

## 1.6.0

- Rain and Stormy **Refract** the real desktop (Hyprland). Default **100%**; **0** is the painted overlay. Drop heads warp more than trails and rims; silhouettes fade over about two pixels. Mixes that include rain skip the overlay rain slot while Hyprland rain is live.
- Sunny/Fire **Haze** is a light heat shimmer: fine at the ground, longer wavelength as it rises. Sunny waits for outdoor temperature (**On above**, default 90°F / 32.2°C). Fire haze is not gated.
- Stormy **Sheen** is separate from **Gloom** (default 60%). **Frequency** max is 200%. Lightning stays on the overlay (no desktop shake or shockwave).
- Screen shader is generated by `HyprShader.js` into `~/.local/state/ogarza.plugins.weather/current.frag` and applied at runtime. Damage tracking is forced off while it is live; a 1×1 ticker keeps `time` advancing. Hyprland has one shader slot (last apply wins). Clicks through warped pixels land slightly off.
- Panel warns if another plugin under `~/.config/omarchy/plugins` also sets Hyprland’s `screen_shader`.
- **Hyprland distortion** toggle (and IPC `hypr`) turns refraction and haze on or off globally. Off falls back to the painted overlay.
- IPC also covers overlay power, mode, Exclusive track, Custom layers, sliders, reset, and weather refresh.
- **Reset to defaults** is the first control in the parameter column.
- Fire **Scale** remapped: old 30% is the new 100%.

## 1.5.0

- **None** mode (default). Overlay stays off until a real effect is chosen; missing/unknown mode no longer becomes rain.
- Crossfade compositor: two or three shader slots (up to six fullscreen passes during a fade). Follow fades in 10s; panel / Exclusive / overlay toggle in 2s. Mid-fade retargets or reverses instead of stacking.
- Mix conditions (per-layer strength): partly cloudy, overcast, sun shower, moonlit clouds, drizzle, snow squall, wintry mix.
- Follow maps WMO / wttr codes onto singles and mixes. Fire, rainbow, and custom are never chosen. Partly cloudy becomes moonlit clouds after sunset. Thunder is Stormy. Clear (WMO `0`) is sunny.
- Follow waits for `weather.json` coords before fetching; prefers Open-Meteo; falls back to wttr. No stale rain from a premature wttr call.
- Faster fog and sunny motion baselines. Fog is clouds only (no extra top mist).
- **Rainbow** mode (manual only): primary and secondary bows opposite the sun, with a faint inner fringe. The bow fades after sunset.
- **Add Rainbow** is available on every condition except standalone Rainbow (Custom uses Layer C instead). Off by default.
- **Custom** mode (manual only): stacked Layer A / B / C pickers. Each layer can be **None**. Parameters for enabled layers expand to the right.
- Panel groups Fire, Rainbow, and Custom under **Manual only**, below a separator after Follow / Exclusive.
- Other conditions use the same expanding columns: one per mix layer, plus Rainbow when **Add Rainbow** is on. Exclusive **Track only** sits immediately to the right of the mode list, then those columns. Follow / Exclusive show parameters for the live or tracked condition.
- Exclusive notes that the overlay waits for matching local weather; the panel previews the tracked effect until you close it.
- **Quality** selector (Low / Medium / High / Extreme): render the overlay at 33% / 50% / 75% / 100% of native pixels and scale up. Default is High. Extreme skips the offscreen blit and adds extra shader work (FBM octaves, snow layers, sun motes/glow terms, rain layers and specular, storm bolt segments, rainbow fringe). High matches the original look.
- Quality persists with the plugin entry. IPC: `omarchy-shell ogarza.plugins.weather preview <preset>`, `overlay`, and `quality <level>`.
- Wired previously unused uniforms: fog size, rain sheen, snow brightness, sunny dust, storm gloom.
- Rain and stormy drop Scale caps at 100% so drops stay inside their cells.
- Sunny/moonlight Speed at 100% matches the previous 50% (half the motion baseline). Position defaults to 120%.
- Default sliders match the tuned look (rain sheen 50%, snow dimmer/smaller, storm Density 100% and Speed 115%, slower fire, mix layer balances, and so on).
- Stormy: **Flash** and **Frequency** sliders (100% Frequency is half the previous strike rate), Gloom defaults to 100%, a cool sheet flash with the bolt, a lingering ease-out, and a rare double blink. Angle slider for drop lean (100% is the original diagonal). Lightning flash envelope is adapted from Pavlo Zhukov (CC BY-NC-SA 3.0).
- Rainbow sliders: Glow, Vividness, Size (max 400%), Horizontal (default 80%), Height (−200% to 200%, default 65%), Distance, Shimmer (default 100%).

## 1.4.1

- Fire shader compiles again (comment header was missing a slash).

## 1.4.0

- Exclusive mode: track one weather type; overlay only when it matches; preview while the panel is open.
- Sunny/Moonlight Position and Distance sliders.
- Higher Density cap for rain and stormy (240%).
- Reset to defaults in the panel.
- Sparkles bar icon (not a weather glyph).
- Compiled `.qsb` shaders are gitignored and rebuilt from `.frag` on load.

## 1.3.0

- Sunny/Moonlight switch from sun position at the configured location.

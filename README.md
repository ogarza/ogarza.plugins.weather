# Omarchy Weather Effects

Fullscreen weather on your Omarchy desktop: rain on glass, snow, clouds, sun, storms, fire, motes, mist, stars, pollen, rainbows, and mixes. Most of it is a transparent overlay. Rain refraction goes through Hyprland (or the wallpaper warp) so drops warp the real desktop, not a painted copy.

Plugin id: `ogarza.plugins.weather` · version **1.9.1**

## Install

```bash
omarchy plugin add https://github.com/ogarza/ogarza.plugins.weather.git --enable
```

That clones into `~/.config/omarchy/plugins/ogarza.plugins.weather/` and puts the widget on the bar (right section by default). To enable later:

```bash
omarchy plugin enable ogarza.plugins.weather --section right
```

Update:

```bash
omarchy plugin update ogarza.plugins.weather
```

Optional — agent skill, so your default agent can change the overlay with IPC (e.g. “make it rain harder”). Skip this if you only use the panel.

```bash
src="$HOME/.config/omarchy/plugins/ogarza.plugins.weather/skill/ogarza-weather-user"
for dir in ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills; do
  mkdir -p "$dir"
  ln -sfn "$src" "$dir/ogarza-weather-user"
done
```

Restart the agent so it picks up the skill. The links follow plugin updates.

Generated Hyprland shaders stay under `~/.local/state/ogarza.plugins.weather/`. Overlay `.qsb` files ship in `shaders/` so the painted effects work without extra packages. The panel warns if those compiled shaders are missing.

To rebuild overlay shaders after editing a `.frag`, or if the panel says they are missing, install Qt Shader Baker. Omarchy does not ship it:

```bash
omarchy pkg add qt6-shadertools
```

Then reopen the weather panel, or run `omarchy restart shell`. `qsb` lives at `/usr/lib/qt6/bin/qsb` (not on PATH).

### Uninstall

If the overlay or Distortion was on when you removed the plugin, Hyprland can keep the last screen shader until you clear it. Settings live in the Omarchy shell plugin entry (not this repo). Generated files sit under the state directory.

```bash
omarchy plugin remove ogarza.plugins.weather

rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/ogarza.plugins.weather"

hyprctl eval 'hl.config({ decoration = { screen_shader = "" } })'
hyprctl eval 'hl.config({ debug = { damage_tracking = 2 } })'
```

The last two lines drop a leftover Hyprland shader and put damage tracking back to the usual full-monitor mode. Skip them if another plugin (Phosphor, for example) is supposed to own that slot.

If you installed the optional agent skill, remove those links too:

```bash
rm -f ~/.agents/skills/ogarza-weather-user ~/.claude/skills/ogarza-weather-user \
  ~/.codex/skills/ogarza-weather-user ~/.pi/agent/skills/ogarza-weather-user
```

If you installed Qt Shader Baker for this plugin and nothing else needs it, you can drop it:

```bash
omarchy pkg drop qt6-shadertools
```

## Usage

- **Left-click** the bar sparkle to open the panel (modes on the left, sliders on the right). **Settings** is the first row: Resolution and per-shader Effect detail (description to the right of each row), without turning the overlay off.
- **Right-click** to turn the overlay on or off.

**Settings → Resolution** (Low, Medium, High, Native) is how large the overlay is drawn: 33% / 50% / 75% / 100% of native pixels. Native skips the extra blit. High is the default. Drop this first if the desktop feels heavy.

**Settings → Effect detail** is per shader (Rain, Stormy, Fire, Cloud/Fog, Snow, Sunny/Moon, Motes, Mist, Stars, Rainbow), Low through Extreme. **All looks** sets those at once. Mixes use each layer’s shader. High is the default. Rain/Stormy are the most expensive (especially with Distortion). Wallpaper warp uses Rain or Stormy detail. **Pollen** has no Effect detail (count and look are sliders only). Rainbow and Stars are the cheapest; Motes cost scales with speck count.

IPC `quality` still sets Resolution plus **all** Effect detail (`low`…`extreme`; `extreme` is Native + Extreme). `resolution` is scale only. `detail high` sets every shader that has a row; `detail rain low` sets one. A blank `detail` read is one word if they match, otherwise `rain:high,stormy:low,…`.

**Wallpaper only** (off by default) draws the overlay on the wallpaper layer, below windows. Hyprland’s screen shader is cleared. **Distortion** on this target samples the cached wallpaper for rain refraction (`shaders/wallpaper_warp.frag`) and composites those pixels over Omarchy’s background so the swap animation still shows. See [docs/wallpaper-target.md](docs/wallpaper-target.md).

**Distortion** is a global switch for rain and storm refraction. On (the default) keeps one Hyprland shader while the target is **Whole screen**. On **Wallpaper only** the same switch drives the wallpaper warp shader instead of `screen_shader`. Off leaves the Refract sliders alone and uses the painted overlay.

Mode changes in the panel fade over about two seconds. Follow fades forecast changes over about ten.

### Modes

| Mode | Effect |
|------|--------|
| Settings | Resolution and per-shader Effect detail (notes on the right). Does not change the current mode. Overlay off is the header power switch or IPC `mode none` (default). |
| Rain | Glass beads and trails. Hyprland **Refract** warps the desktop (painted rain is skipped while that is live). Refract 0 is painted only. |
| Snow | Falling flakes (overlay only; lower Effect detail uses fewer layers) |
| Cloud/Fog | Soft clouds, denser high up; top and bottom faded so the desktop stays readable |
| Sunny | Warm glow by day. Over civil twilight (sun 0° to −6°, a few minutes) it eases to cool moonlight |
| Partly cloudy | Clouds and sun (sun→moonlight like Sunny). Follow becomes Moonlit clouds after sunset |
| Overcast | Heavy clouds, faint sun (same twilight rules as Sunny) |
| Sun shower | Sun and rain. Optional rainbow fades at night unless **After sunset** is on |
| Moonlit clouds | Clouds and moon. Exclusive treats this and Partly cloudy as a match |
| Drizzle | Light rain through clouds (same refraction rules as Rain) |
| Snow squall | Snow through clouds (no desktop warp) |
| Wintry mix | Rain and snow (rain can still refract) |
| Stormy | Diagonal rain, Gloom wash, overlay lightning. **Angle** is drop lean. Refraction like Rain |
| Follow | Live forecast for your Omarchy location. Never Fire, Motes, Mist, Stars, Pollen, Rainbow, or Custom. Clear = Sunny; thunder = Stormy; partly cloudy → moonlit after sunset. Fades in about ten seconds |
| Exclusive | Same fetch as Follow; overlay only when weather matches **Track only**. The panel previews until you close it |
| Fire | Ground fire (manual only) |
| Motes | Floating glowing specks (manual only). Overlay only. **Hue**, **Saturation**, **Size**, **Glow**, **Glow pulse** |
| Mist | Ground-hugging rolling haze (manual only). Overlay only. Opposite of Cloud/Fog. **Hue** tints the mist |
| Stars | Twinkling starfield (manual only). Overlay only. Three slow **Parallax** layers (0 is still). **Twinkle amount** is pulse depth (0 off). **Shooting stars** are rare and brief (0 off); each pass picks a heading and near/far size. **Hue**, **Saturation**, **Size**, **Glow** |
| Pollen | Dandelion-like seeds that lift and sway (manual only). Overlay only. **Wind** (0 = up), **Tumble**, **Hue**, **Saturation**, **Size**, **Glow** |
| Rainbow | Primary and secondary bows (manual only). Hidden after sunset unless **After sunset** is on (**Night glow** / **Night strength**) |
| Custom | Up to three stacked shaders; **None** turns a layer off (manual only). Sliders are shared with the standalone modes |

The panel lists forecast modes first, then **Manual only** for Fire, Motes, Mist, Stars, Pollen, Rainbow, and Custom. Mixes open one parameter column per layer. **Add Rainbow** adds a Rainbow column. Custom uses a **dropdown** per Layer A / B / C (each can be **None**).

**Follow** and **Exclusive** read `~/.local/state/omarchy/settings/weather.json` — the same location Omarchy uses. With coordinates they ask [Open-Meteo](https://open-meteo.com/) for the current weather code and outdoor temperature. Without coordinates they fall back to [wttr.in](https://wttr.in/). Refresh is about every 15 minutes.

Follow never picks fire, motes, mist, stars, pollen, rainbow, or custom. Clear sky is sunny. Partly cloudy becomes moonlit clouds after sunset. Thunder is stormy.

**Exclusive** uses the same fetch, then only shows the overlay when the live weather matches **Track only**. While the panel is open you can preview the tracked effect. After you close it, the overlay waits until that weather is actually happening. Partly cloudy and moonlit clouds count as a match for each other.

### Tweaks

Columns to the right of the mode list show a short description and the sliders for that look. Overlay uniforms update while you drag except **Motes** and **Pollen** (sprite flocks): those apply when you release the slider so the panel stays snappy. Distortion rebuilds when you release the slider. Values persist in shell config.

- **Strength** — overall intensity on single-shader modes
- **Clouds / Sun / Moon / Rain / Snow / Fog / Layer A / B / C** — mix layer strengths
- **Add Rainbow** — optional rainbow on any other condition (off by default)
- **Density** / **Speed** — coverage and motion. Stars Density is how many grid cells light up. Motes and Pollen Density is seed count (about 4–192). At 0 they are a handful of specks; the rest of the slider is linear
- **Twinkle amount** — Stars only: how hard each star pulses (0 is off / steady). Rate is fixed
- **Scale** / **Size** — drop, flake, flame, cloud, mote, star, seed, or rainbow size. Rain and Stormy Scale go to 200%; default 100% is the old max
- **Sheen** — glints on rain and storm drops
- **Parallax** — Stars only: slow drift between near/mid/far layers (0 is still)
- **Shooting stars** — Stars only: how often a brief meteor appears (0 is none). Each one gets a random heading and near/far scale
- **Wind** — Pollen heading (0 = up, then around the compass)
- **Tumble** — Pollen seed spin
- **Darken** — how much raindrops tint the glass.
- **Refract** — warp the real desktop through rain or storm drops. Default 100%. 0 keeps the painted overlay
- **Brightness** — snow flakes
- **Glow** — sun, fire, motes, mist, stars, pollen, or rainbow brightness
- **Glow pulse** — each mote’s halo breathes on its own clock (0 is steady; 200% is a strong staggered blink)
- **Hue** / **Saturation** — mote, star, pollen, and mist color (Hue walks the wheel; Saturation 0 is near-white; mist has Hue only)
- **Vividness** — rainbow bands
- **Dust** — motes in sunny / moonlight
- **Position** / **Distance** — sun and moon placement
- **Horizontal** / **Height** / **Distance** — rainbow placement
- **Shimmer** — rainbow motion
- **After sunset** — keep the rainbow at night (off by default). **Night glow** cools the bands toward ice-blue; **Night strength** is how visible the bow stays
- **Angle** — how much storm rain leans
- **Flash** — lightning brightness
- **Frequency** — how often bolts strike
- **Gloom** — storm dark wash
- **Reset to defaults** — first control in the parameter column. Restores sliders for every mode; does not change the selected mode, Resolution, or Effect detail

Shared shaders share sliders: changing rain density from Drizzle also changes standalone Rain.

## IPC

Quickshell exposes these under `ogarza.plugins.weather`. From a terminal:

```bash
omarchy-shell ogarza.plugins.weather <command> [args]
```

| Command | What it does |
|---------|----------------|
| `open` / `show` | Open the panel |
| `close` / `hide` | Close the panel |
| `toggle` | Open or close the panel |
| `power` / `active` `[on\|off\|toggle]` | Overlay on or off (same as right-click on the bar). Independent of mode — `mode follow` does not turn the overlay on |
| `mode` `[id]` | Set the mode (`rain`, `follow`, `custom`, …). Does not change power |
| `track` / `exclusive` `[preset]` | Exclusive **Track only** (`rain`, `stormy`, …) |
| `layer` `<a\|b\|c>` `[shader]` | Custom layer shader (`none` turns a slot off) |
| `param` `<preset>` `<key>` `[value]` | Read or set a slider. Value is the stored number, or a percent (`80%`). **Add Rainbow** is `enableC` `on`/`off`/`toggle` on the condition (`sunshower`, `rain`, …), not on `follow`. `nightVisible` is `on`/`off`/`toggle` |
| `reset` | Restore every mode’s sliders (does not change mode, resolution, detail, Distortion, or target) |
| `refresh` | Fetch Follow / Exclusive weather again |
| `preview <preset>` | Switch to Follow and fade to that look |
| `quality` `[level]` | Preset that sets **both** Resolution and Effect detail: `low`, `medium`, `high`, or `extreme` (`extreme` → Native + Extreme). If they differ, a read returns `resolution,detail` |
| `resolution` `[level]` | Render scale: `low`, `medium`, `high`, or `native` |
| `detail` `[level]` or `[shader] [level]` | Effect detail. One level sets every shader that has a Settings row. `rain` / `stormy` / `snow` / `fog` / `sunny` / `fire` / `motes` / `mist` / `stars` / `rainbow` plus a level sets one. Pollen has no row (`unknown-shader`). Blank read is one word if they match |
| `distortion` / `hypr` `[on\|off\|toggle]` | Distortion on or off. Whole screen: Hyprland `screen_shader`. Wallpaper only: wallpaper warp. `hypr` is the same command |
| `target` `[screen\|wallpaper\|toggle]` | Whole screen vs wallpaper only |
| `overlay` | Print compositor state (JSON: mode, `target` screen/wallpaper, `wallpaperWarp`, Distortion, resolution, detail, …) |

IPC always needs the typed string arguments. Pass `""` (or any whitespace) for an optional value to print the current setting instead of changing it. Omitting the argument can fail at the call site. Same blank-read rule for power, mode, track, layer, param, quality, resolution, detail, distortion, hypr, and target.

Examples:

```bash
omarchy-shell ogarza.plugins.weather power toggle
omarchy-shell ogarza.plugins.weather power ""
omarchy-shell ogarza.plugins.weather mode stormy
omarchy-shell ogarza.plugins.weather mode ""
omarchy-shell ogarza.plugins.weather track snow
omarchy-shell ogarza.plugins.weather layer a rain
omarchy-shell ogarza.plugins.weather layer a ""
omarchy-shell ogarza.plugins.weather param rain refract 0
omarchy-shell ogarza.plugins.weather param rain refract ""
omarchy-shell ogarza.plugins.weather param sunshower enableC on
omarchy-shell ogarza.plugins.weather param sunshower enableC ""
omarchy-shell ogarza.plugins.weather reset
omarchy-shell ogarza.plugins.weather preview rain
omarchy-shell ogarza.plugins.weather quality high
omarchy-shell ogarza.plugins.weather quality ""
omarchy-shell ogarza.plugins.weather resolution native
omarchy-shell ogarza.plugins.weather resolution ""
omarchy-shell ogarza.plugins.weather detail medium
omarchy-shell ogarza.plugins.weather detail rain low
omarchy-shell ogarza.plugins.weather detail ""
omarchy-shell ogarza.plugins.weather distortion off
omarchy-shell ogarza.plugins.weather distortion ""
omarchy-shell ogarza.plugins.weather target wallpaper
omarchy-shell ogarza.plugins.weather target ""
omarchy-shell ogarza.plugins.weather overlay
```

IPC `toggle` is the panel. `power` is the overlay.

## Distortion

On **Whole screen** with **Distortion** on, one screen shader stays applied while rain or storm **Refract** is above 0. Hyprland only has one shader slot. If another plugin (Phosphor, for example) also sets it, whichever applied last wins.

**Wallpaper only** never applies that slot and clears it as soon as you switch. Distortion then composites warped wallpaper samples for rain (`shaders/wallpaper_warp.frag`). Windows stay unwarped.

On load and when the panel opens, this plugin scans the other folders under `~/.config/omarchy/plugins` for `.qml` / `.js` that mention `screen_shader`. It skips its own folder. If it finds a sibling, the panel shows a warning with that plugin’s name from `manifest.json`. It does not disable the other plugin or fight for the slot — it is only a heads-up that refraction may disappear if the other shader applied last.

The generated files live in `${XDG_STATE_HOME:-~/.local/state}/ogarza.plugins.weather/current.a.frag` and `current.b.frag` (two paths so Hyprland reloads when rain changes). Nothing is written to `~/.config/hypr/`.

While refraction is on, the monitor redraws every frame so the warp can animate. Clicks through a warped drop land a little off from what you see.

A reboot clears the runtime shader. To drop it by hand from a TTY:

```bash
hyprctl eval 'hl.config({ decoration = { screen_shader = "" } })'
hyprctl eval 'hl.config({ debug = { damage_tracking = 2 } })'
```

Snow, fog, rainbow, and lightning stay on the overlay. When Hyprland is drawing the rain, the overlay does not paint drops.

## Requirements

- A GPU. Mixes use a few fullscreen passes; Refract adds a Hyprland pass on the whole monitor. Use Settings (Resolution, then Effect detail) if it feels heavy.
- Omarchy with `omarchy-shell` (Quickshell) and Hyprland
- `curl` for Follow and Exclusive
- Overlay `.qsb` files in `shaders/` (shipped). To rebuild after editing a `.frag`, or if the panel says they are missing:

```bash
omarchy pkg add qt6-shadertools
```

Then reopen the panel. `qsb` is at `/usr/lib/qt6/bin/qsb` (not on PATH).

## Shaders

Overlay sources are in `shaders/` (`rain.frag`, `snow.frag`, `fog.frag`, `sunny.frag`, `stormy.frag`, `fire.frag`, `motes.frag`, `mist.frag`, `stars.frag`, `pollen.frag`, `rainbow.frag`) with matching committed `.frag.qsb` packs (GLSL / HLSL / MSL, not GPU-vendor binaries). The Hyprland shader is generated by `HyprShader.js`. After you edit a `.frag`, rebuild with `qsb` (or reopen the panel so `scanShaders` does it) and keep the `.qsb` in git.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

Original work is MIT — see [LICENSE](LICENSE).

Rain, storm lightning, and fire include third-party material that is **not** covered by that MIT grant. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

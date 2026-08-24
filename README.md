# Omarchy Weather Effects

Fullscreen weather on your Omarchy desktop: rain on glass, snow, clouds, sun, storms, fire, rainbows, and mixes. Most of it is a transparent overlay. Rain refraction and heat haze go through Hyprland so they warp the real desktop, not a painted copy.

Plugin id: `ogarza.plugins.weather` · version **1.6.3**

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

Generated Hyprland shaders stay under `~/.local/state/ogarza.plugins.weather/`. Overlay `.qsb` files ship in `shaders/` so the painted effects work without extra packages. The panel warns if those compiled shaders are missing.

To rebuild overlay shaders after editing a `.frag`, or if the panel says they are missing, install Qt Shader Baker. Omarchy does not ship it:

```bash
omarchy pkg add qt6-shadertools
```

Then reopen the weather panel, or run `omarchy restart shell`. `qsb` lives at `/usr/lib/qt6/bin/qsb` (not on PATH).

### Uninstall

If the overlay or Hyprland distortion was on when you removed the plugin, Hyprland can keep the last screen shader until you clear it. Settings live in the Omarchy shell plugin entry (not this repo). Generated files sit under the state directory.

```bash
omarchy plugin remove ogarza.plugins.weather

rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/ogarza.plugins.weather"

hyprctl eval 'hl.config({ decoration = { screen_shader = "" } })'
hyprctl eval 'hl.config({ debug = { damage_tracking = 2 } })'
```

The last two lines drop a leftover Hyprland shader and put damage tracking back to the usual full-monitor mode. Skip them if another plugin (Phosphor, for example) is supposed to own that slot.

If you installed Qt Shader Baker for this plugin and nothing else needs it, you can drop it:

```bash
omarchy pkg drop qt6-shadertools
```

## Usage

- **Left-click** the bar sparkle to open the panel (modes and quality on the left, sliders on the right). The mark is a creation sparkle so it is not the stock weather pill.
- **Right-click** to turn the overlay on or off.

**Quality** (Low, Medium, High, Extreme) trades sharpness for cost. High is the default. The overlay still renders at 33% / 50% / 75% / 100% of native pixels. Rain and Stormy drop work no longer drops as far: Low uses the old Medium layers, Medium matches High, Extreme still adds another drop pass. If the desktop feels heavy, drop quality first.

**Hyprland distortion** is a global switch for refraction and haze. On (the default) keeps one combined Hyprland shader the whole time: rain and haze share that program, and the unused term is multiplied by 0 (Fog and Snow stay applied). Off leaves those sliders alone, uses the painted overlay, and clears the shader.

Mode changes in the panel fade over about two seconds. Follow fades forecast changes over about ten.

### Modes

| Mode | Effect |
|------|--------|
| None | Overlay off until you pick an effect (default) |
| Rain | Glass beads and trails. Hyprland **Refract** warps the desktop (painted rain is skipped while that is live). Refract 0 is painted only. Clicks through a warped drop land a little off |
| Snow | Falling flakes (overlay only; lower Quality uses fewer layers) |
| Cloud/Fog | Soft clouds, denser high up; top and bottom faded so the desktop stays readable |
| Sunny | Warm glow by day. Over civil twilight (sun 0° to −6°, a few minutes) it eases to cool moonlight. **Haze** warps the desktop only when outdoor temperature is at or above **On above** (default 90°F / 32.2°C) |
| Partly cloudy | Clouds and sun (sun→moonlight like Sunny). Follow becomes Moonlit clouds after sunset |
| Overcast | Heavy clouds, faint sun (same twilight and haze rules as Sunny) |
| Sun shower | Sun and rain. Optional rainbow fades at night unless **After sunset** is on |
| Moonlit clouds | Clouds and moon. Exclusive treats this and Partly cloudy as a match |
| Drizzle | Light rain through clouds (same refraction rules as Rain) |
| Snow squall | Snow through clouds (no desktop warp) |
| Wintry mix | Rain and snow (rain can still refract) |
| Stormy | Diagonal rain, Gloom wash, overlay lightning (no desktop shake). **Angle** is drop lean. Refraction like Rain |
| Follow | Live forecast for your Omarchy location. Never Fire, Rainbow, or Custom. Clear = Sunny; thunder = Stormy; partly cloudy → moonlit after sunset. Fades in about ten seconds |
| Exclusive | Same fetch as Follow; overlay only when weather matches **Track only**. The panel previews until you close it |
| Fire | Ground fire (manual only). **Haze** is not gated by temperature |
| Rainbow | Primary and secondary bows (manual only). Hidden after sunset unless **After sunset** is on (**Night glow** / **Night strength**) |
| Custom | Up to three stacked shaders; **None** turns a layer off (manual only). Sliders are shared with the standalone modes |

The panel lists forecast modes first, then **Manual only** for Fire, Rainbow, and Custom. Mixes open one parameter column per layer. **Add Rainbow** adds a Rainbow column. Custom stacks Layer A / B / C pickers (each can be **None**).

**Follow** and **Exclusive** read `~/.local/state/omarchy/settings/weather.json` — the same location Omarchy uses. With coordinates they ask [Open-Meteo](https://open-meteo.com/) for the current weather code and outdoor temperature. Without coordinates they fall back to [wttr.in](https://wttr.in/). Refresh is about every 15 minutes. That temperature also gates sunny **Haze** when **On above** is set.

Follow never picks fire, rainbow, or custom. Clear sky is sunny. Partly cloudy becomes moonlit clouds after sunset. Thunder is stormy.

**Exclusive** uses the same fetch, then only shows the overlay when the live weather matches **Track only**. While the panel is open you can preview the tracked effect. After you close it, the overlay waits until that weather is actually happening. Partly cloudy and moonlit clouds count as a match for each other.

### Tweaks

Columns to the right of the mode list show a short description and the sliders for that look (or the Follow / Exclusive condition). Overlay uniforms update while you drag. Hyprland distortion rebuilds when you release the slider. Values persist in shell config.

- **Strength** — overall intensity on single-shader modes
- **Clouds / Sun / Moon / Rain / Snow / Haze / Layer A / B / C** — mix layer strengths
- **Add Rainbow** — optional rainbow on any other condition (off by default)
- **Density** / **Speed** — coverage and motion
- **Scale** / **Size** — drop, flake, flame, cloud, or rainbow size. Rain and Stormy Scale go to 200%; default 100% is the old max
- **Sheen** — glints on rain and storm drops
- **Darken** — how much raindrops tint the glass (painted overlay and Hyprland)
- **Refract** — warp the real desktop through rain or storm drops (Hyprland). Default 100%. 0 keeps the painted overlay
- **Haze** — heat shimmer on Sunny and Fire
- **On above** — outdoor temperature where sunny haze turns on (default 90°F / 32.2°C). Fire haze ignores this
- **Brightness** — snow flakes
- **Glow** — sun, fire, or rainbow brightness
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
- **Reset to defaults** — first control in the parameter column. Restores sliders for every mode; does not change the selected mode or quality

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
| `power` / `active` `[on\|off\|toggle]` | Overlay on or off (same as right-click on the bar). No argument prints `on` or `off` |
| `mode` `[id]` | Set the mode (`rain`, `follow`, `custom`, …). No argument prints the current id |
| `track` / `exclusive` `[preset]` | Exclusive **Track only** (`rain`, `stormy`, …). No argument prints the current preset |
| `layer` `<a\|b\|c>` `[shader]` | Custom layer shader (`none` turns a slot off). No shader prints the current pick |
| `param` `<preset>` `<key>` `[value]` | Read or set a slider. Value is the stored number, or a percent (`80%`). `enableC` and `nightVisible` are `on`/`off`. Temperature is °C, or °F with an `F` suffix |
| `reset` | Restore every mode’s sliders (does not change mode, quality, or Hyprland distortion) |
| `refresh` | Fetch Follow / Exclusive weather again |
| `preview <preset>` | Switch to Follow and fade to that look |
| `quality` `[level]` | Set `low`, `medium`, `high`, or `extreme`. No argument prints the current level |
| `hypr` `[on\|off\|toggle]` | Hyprland distortion. No argument prints `on` or `off` |
| `overlay` | Print compositor state (JSON) |

Examples:

```bash
omarchy-shell ogarza.plugins.weather power toggle
omarchy-shell ogarza.plugins.weather mode stormy
omarchy-shell ogarza.plugins.weather track snow
omarchy-shell ogarza.plugins.weather layer a rain
omarchy-shell ogarza.plugins.weather param rain refract 0
omarchy-shell ogarza.plugins.weather param sunny temperature 90F
omarchy-shell ogarza.plugins.weather reset
omarchy-shell ogarza.plugins.weather preview rain
omarchy-shell ogarza.plugins.weather quality high
omarchy-shell ogarza.plugins.weather hypr off
omarchy-shell ogarza.plugins.weather overlay
```

IPC `toggle` is the panel. `power` is the overlay.

## Desktop refraction (Hyprland)

With **Hyprland distortion** on, one combined screen shader stays applied: rain and haze share it, and the unused term is 0. Hyprland only has one shader slot. If another plugin (Phosphor, for example) also sets it, whichever applied last wins.

On load and when the panel opens, this plugin scans the other folders under `~/.config/omarchy/plugins` for `.qml` / `.js` that mention `screen_shader`. It skips its own folder. If it finds a sibling, the panel shows a warning with that plugin’s name from `manifest.json`. It does not disable the other plugin or fight for the slot — it is only a heads-up that refraction or haze may disappear if the other shader applied last.

The generated files live in `${XDG_STATE_HOME:-~/.local/state}/ogarza.plugins.weather/current.a.frag` and `current.b.frag` (two paths so Hyprland reloads when rain or haze changes). Nothing is written to `~/.config/hypr/`.

While refraction or haze is on, the monitor redraws every frame so the warp can animate. Clicks through a warped drop or the haze band land a little off from what you see.

A reboot clears the runtime shader. To drop it by hand from a TTY:

```bash
hyprctl eval 'hl.config({ decoration = { screen_shader = "" } })'
hyprctl eval 'hl.config({ debug = { damage_tracking = 2 } })'
```

Snow, fog, rainbow, and lightning stay on the overlay. When Hyprland is drawing the rain, the overlay does not paint drops.

## Requirements

- A GPU. Mixes use a few fullscreen passes; Refract and Haze add a Hyprland pass on the whole monitor. Use Quality if it feels heavy.
- Omarchy with `omarchy-shell` (Quickshell) and Hyprland
- `curl` for Follow and Exclusive
- Overlay `.qsb` files in `shaders/` (shipped). To rebuild after editing a `.frag`, or if the panel says they are missing:

```bash
omarchy pkg add qt6-shadertools
```

Then reopen the panel. `qsb` is at `/usr/lib/qt6/bin/qsb` (not on PATH).

## Shaders

Overlay sources are in `shaders/` (`rain.frag`, `snow.frag`, `fog.frag`, `sunny.frag`, `stormy.frag`, `fire.frag`, `rainbow.frag`) with matching committed `.frag.qsb` packs (GLSL / HLSL / MSL, not GPU-vendor binaries). The Hyprland shader is generated by `HyprShader.js`. After you edit a `.frag`, rebuild with `qsb` (or reopen the panel so `scanShaders` does it) and keep the `.qsb` in git.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

Original work is MIT — see [LICENSE](LICENSE).

Rain, storm lightning, and fire include third-party material that is **not** covered by that MIT grant. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

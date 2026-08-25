# Wallpaper target

Screen vs Wallpaper. Default remains **Screen** (fullscreen overlay + optional Hyprland `screen_shader`).

**Wallpaper** moves the overlay to `WlrLayer.Bottom` (above `omarchy-background`, below windows and the bar). Hyprland’s screen shader is **cleared immediately**.

## Distortion

Rain refraction **does not exist in the painted overlay shaders**. On Whole screen it lives in Hyprland’s `screen_shader`. On Wallpaper it uses `wallpaper_warp.frag`, which samples a GPU cache of Omarchy’s current background and **only composites the warped drop pixels**. Omarchy’s wallpaper crossfade stays visible in the unwarped regions.

Painted rain is skipped while wallpaper warp rain is live (`overlaySkipsRainDrops`). Stormy bolts stay on the overlay.

## GPU cache vs path watch

| What | How often |
|------|-----------|
| Warp `texture(cached, uv)` | Every frame while distortion is on |
| Decode JPEG/PNG | When the resolved wallpaper path changes |
| `readlink -f` / FileView | Path watch + ~1s poll while warp is on |

## Limits

Warp is the wallpaper **file**, not windows. Theme wipe can lead by a frame. Fullscreen windows hide Bottom.

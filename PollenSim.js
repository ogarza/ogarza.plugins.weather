.pragma library

var MAX = 192
var seeds = []
var lastTime = -1

function countForDensity(d) {
  var t = Math.max(0, Math.min(1, (Number(d) || 0) * 0.5))
  return Math.max(4, Math.min(MAX, Math.round(4 + t * (MAX - 4))))
}

function hash01(i, salt) {
  var x = Math.sin((i + 1) * 127.1 + salt * 311.7) * 43758.5453
  return x - Math.floor(x)
}

function ensureCount(n) {
  while (seeds.length < n) {
    var i = seeds.length
    seeds.push({
      x: hash01(i, 1.1),
      y: hash01(i, 2.2),
      headingJitter: (hash01(i, 3.3) - 0.5) * 0.85,
      speedJitter: 0.5 + hash01(i, 4.4) * 1.0,
      tumblePhase: hash01(i, 5.5) * 6.2831853,
      sizeJitter: 0.55 + hash01(i, 6.6) * 0.9,
      flutterPhase: hash01(i, 7.7) * 6.2831853
    })
  }
  if (seeds.length > n)
    seeds.length = n
}

function wrap01(v) {
  return v - Math.floor(v)
}

function step(now, density, speed, sheen, active) {
  var tnow = Number(now) || 0
  if (!active) {
    lastTime = tnow
    return seeds
  }
  ensureCount(countForDensity(density))
  var dt = lastTime < 0 ? 0.016 : Math.min(0.05, Math.max(0, tnow - lastTime))
  lastTime = tnow
  var base = (Number(sheen) || 0) * Math.PI
  var spd = 0.11 * Math.max(Number(speed) || 0, 0)
  var i
  for (i = 0; i < seeds.length; i++) {
    var s = seeds[i]
    var a = base + s.headingJitter
    var dx = Math.sin(a)
    var dy = -Math.cos(a)
    var fl = 0.45 * Math.sin(tnow * (0.65 + s.speedJitter * 0.5) + s.flutterPhase)
    var px = -dy
    var py = dx
    var v = spd * s.speedJitter
    s.x = wrap01(s.x + (dx * v + px * fl * v) * dt)
    s.y = wrap01(s.y + (dy * v + py * fl * v) * dt)
  }
  return seeds
}

function seedCount() {
  return seeds.length
}

function xAt(i) {
  if (i < 0 || i >= seeds.length)
    return 0
  return seeds[i].x
}

function yAt(i) {
  if (i < 0 || i >= seeds.length)
    return 0
  return seeds[i].y
}

function sizeJitterAt(i) {
  if (i < 0 || i >= seeds.length)
    return 1
  return seeds[i].sizeJitter
}

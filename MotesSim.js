.pragma library

var MAX = 192
var motes = []
var lastTime = -1

function countForDensity(d) {
  var t = Math.max(0, Math.min(1, (Number(d) || 0) * 0.5))
  return Math.max(4, Math.min(MAX, Math.round(4 + t * (MAX - 4))))
}

function hash01(i, salt) {
  var x = Math.sin((i + 1) * 127.1 + salt * 311.7) * 43758.5453
  return x - Math.floor(x)
}

function gridForQuality(q) {
  var r = Number(q)
  if (r < 0.5)
    return 22
  if (r < 1.5)
    return 28
  if (r < 2.5)
    return 36
  return 44
}

function ensureCount(n) {
  while (motes.length < n) {
    var i = motes.length
    var rndx = hash01(i, 1.7)
    var rndy = hash01(i, 8.3)
    motes.push({
      hx: hash01(i, 13.9),
      hy: hash01(i, 4.1),
      cidX: hash01(i, 2.4) * 48,
      cidY: hash01(i, 3.1) * 48,
      w1: 0.32 + rndx * 1.15,
      w2: 0.26 + rndy * 1.05,
      sizeJitter: 0.5 + hash01(i, 2.6) * 1.05,
      pulsePhase: hash01(i, 21.4) * 6.2831853,
      pFreq: 0.7 + hash01(i, 4.2) * 1.9,
      x: 0,
      y: 0
    })
  }
  if (motes.length > n)
    motes.length = n
}

function wrap01(v) {
  return v - Math.floor(v)
}

function step(now, density, speed, quality, active) {
  var tnow = Number(now) || 0
  if (!active) {
    lastTime = tnow
    return motes
  }
  ensureCount(countForDensity(density))
  lastTime = tnow
  var t = tnow * 0.11 * Math.max(Number(speed) || 0, 0)
  var amp = 1 / gridForQuality(quality)
  var i
  for (i = 0; i < motes.length; i++) {
    var m = motes[i]
    var wx = 0.95 * Math.sin(t * m.w1 + m.cidY * 3.1) + 0.45 * Math.sin(t * m.w1 * 0.47 + 1.7)
    var wy = 0.85 * Math.sin(t * m.w2 + m.cidX * 2.4) + 0.4 * Math.cos(t * m.w2 * 0.73 + 0.9)
    m.x = wrap01(m.hx + wx * amp)
    m.y = wrap01(m.hy + wy * amp)
  }
  return motes
}

function seedCount() {
  return motes.length
}

function xAt(i) {
  if (i < 0 || i >= motes.length)
    return 0
  return motes[i].x
}

function yAt(i) {
  if (i < 0 || i >= motes.length)
    return 0
  return motes[i].y
}

function sizeJitterAt(i) {
  if (i < 0 || i >= motes.length)
    return 1
  return motes[i].sizeJitter
}

function pulsePhaseAt(i) {
  if (i < 0 || i >= motes.length)
    return 0
  return motes[i].pulsePhase
}

function pFreqAt(i) {
  if (i < 0 || i >= motes.length)
    return 1
  return motes[i].pFreq
}

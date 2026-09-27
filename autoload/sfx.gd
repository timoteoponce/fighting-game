extends Node
## Tiny sound effects generated in code, so the game needs no audio files.

const RATE := 22050

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	for i in 10:
		var p := AudioStreamPlayer.new()
		p.volume_db = -8.0
		add_child(p)
		_players.append(p)
	_streams["light"] = _tone(0.08, 320.0, 120.0, 0.75, false, 0.7)
	_streams["heavy"] = _tone(0.18, 170.0, 50.0, 0.6, false, 0.9)
	_streams["block"] = _tone(0.07, 950.0, 650.0, 0.25, true, 0.35)
	_streams["whoosh"] = _tone(0.11, 300.0, 900.0, 0.95, false, 0.22)
	_streams["special"] = _tone(0.28, 280.0, 1100.0, 0.1, true, 0.3)
	_streams["kick"] = _tone(0.12, 220.0, 80.0, 0.45, false, 0.8)
	_streams["magic"] = _tone(0.3, 1300.0, 2400.0, 0.05, false, 0.35)
	_streams["hyper"] = _tone(0.8, 140.0, 1000.0, 0.15, true, 0.35)
	_streams["ko"] = _tone(1.0, 700.0, 70.0, 0.3, true, 0.4)
	_streams["select"] = _tone(0.05, 880.0, 880.0, 0.0, true, 0.2)
	_streams["confirm"] = _tone(0.14, 660.0, 1320.0, 0.0, true, 0.25)
	_streams["land"] = _tone(0.06, 150.0, 90.0, 0.8, false, 0.3)


func play(sound: String, pitch := 1.0) -> void:
	if not _streams.has(sound):
		return
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _streams[sound]
	p.pitch_scale = pitch * randf_range(0.95, 1.05)
	p.play()


func _tone(dur: float, f0: float, f1: float, noise: float, square: bool, vol: float) -> AudioStreamWAV:
	var n := int(dur * RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	for i in n:
		var t := float(i) / n
		phase += TAU * lerpf(f0, f1, t) / RATE
		var s := sin(phase)
		if square:
			s = signf(s) * 0.6
		s = lerpf(s, randf_range(-1.0, 1.0), noise)
		var env := (1.0 - t) * minf(1.0, t * 60.0)
		data.encode_s16(i * 2, int(clampf(s * env * vol, -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	return w

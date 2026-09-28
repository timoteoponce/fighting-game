extends Node
## Tiny sound effects generated in code, so the game needs no audio files.
## Fighter voices are synthesized too (formant "vocal tract" filters), but real
## recordings win: put voices/<character>/<line>.wav or .ogg next to the game
## (or in the project folder). Lines: light, heavy, special, hyper, hurt, ko, win.

const RATE := 22050

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _voices := {}  # "character/line" -> stream
var _voice_player: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _music_files: PackedStringArray = PackedStringArray()
var _music_i := 0

const VOICE_LINES := ["light", "heavy", "special", "hyper", "hurt", "ko", "win"]
## Fallback voice pitch (Hz) when a character doesn't state one.
const DEFAULT_VOICE_PITCH := 280.0
## Vowel formants [F1, F2, F3] in Hz.
const VOWELS := {
	"a": [800.0, 1250.0, 2600.0], "e": [500.0, 1800.0, 2600.0], "i": [320.0, 2300.0, 3000.0],
	"o": [500.0, 900.0, 2500.0], "u": [350.0, 800.0, 2300.0],
}


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
	for i in 2:
		var vp := AudioStreamPlayer.new()
		vp.volume_db = -3.0
		add_child(vp)
		_voice_player.append(vp)
	_start_music()


## Plays a fighter shout. Each fighter uses its own channel so shouts cut each
## other off like in the arcade. Voices are built the first time a character
## speaks, from the pitch the character itself declares — so a new fighter never
## needs registering in a table here.
func voice(id: String, line: String, channel := 0, pitch := 0.0) -> void:
	if not _voices.has(id + "/" + line):
		_build_voices(id, pitch if pitch > 0.0 else DEFAULT_VOICE_PITCH)
	var s = _voices.get(id + "/" + line)
	if s == null:
		return
	var p := _voice_player[clampi(channel, 0, 1)]
	p.stream = s
	p.pitch_scale = randf_range(0.95, 1.06)
	p.play()


func _build_voices(id: String, pitch: float) -> void:
	for line in VOICE_LINES:
		var custom := _load_recording(id, line)
		_voices[id + "/" + line] = custom if custom else _voice(pitch, line)


func _load_recording(id: String, line: String) -> AudioStream:
	for dir in [OS.get_executable_path().get_base_dir() + "/voices", ProjectSettings.globalize_path("res://voices")]:
		var base := "%s/%s/%s" % [dir, id, line]
		if FileAccess.file_exists(base + ".wav"):
			# afconvert writes WAVE_FORMAT_EXTENSIBLE, which Godot's loader rejects.
			var parsed := _load_pcm_wav(base + ".wav")
			if parsed != null:
				return parsed
			var loaded := AudioStreamWAV.load_from_file(base + ".wav")
			if loaded != null:
				return loaded
		if FileAccess.file_exists(base + ".ogg"):
			return AudioStreamOggVorbis.load_from_file(base + ".ogg")
	return null


## PCM WAV, including the extensible header macOS afconvert writes.
func _load_pcm_wav(path: String) -> AudioStreamWAV:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 12 or _fourcc(bytes, 0) != "RIFF" or _fourcc(bytes, 8) != "WAVE":
		return null
	var channels := 1
	var rate := 22050
	var bits := 16
	var pcm_format := 0
	var data := PackedByteArray()
	var i := 12
	while i + 8 <= bytes.size():
		var id := _fourcc(bytes, i)
		var size := int(bytes.decode_u32(i + 4))
		var body := i + 8
		if size < 0 or body + size > bytes.size():
			break
		if id == "fmt " and size >= 16:
			pcm_format = bytes.decode_u16(body)
			channels = bytes.decode_u16(body + 2)
			rate = int(bytes.decode_u32(body + 4))
			bits = bytes.decode_u16(body + 14)
			# Extensible: the real format is the first field of the subformat GUID.
			if pcm_format == 0xFFFE and size >= 40:
				pcm_format = bytes.decode_u16(body + 24)
		elif id == "data":
			data = bytes.slice(body, body + size)
		i = body + size + (size & 1)
	if pcm_format != 1 or data.is_empty() or (channels != 1 and channels != 2):
		return null
	var stream := AudioStreamWAV.new()
	stream.mix_rate = rate
	stream.stereo = channels == 2
	if bits == 8:
		stream.format = AudioStreamWAV.FORMAT_8_BITS
	elif bits == 16:
		stream.format = AudioStreamWAV.FORMAT_16_BITS
	else:
		return null
	stream.data = data
	return stream


func _fourcc(bytes: PackedByteArray, at: int) -> String:
	return bytes.slice(at, at + 4).get_string_from_ascii()


## Synthesizes a shout: a buzzy glottal pulse shaped by three formant filters
## gliding between vowels, with a breathy "h" attack.
func _voice(f0: float, line: String) -> AudioStreamWAV:
	# [vowel path, duration, pitch start, pitch end, breath at start, volume]
	var spec: Array = {
		"light": [["a", "a"], 0.13, 1.1, 0.95, 0.04, 0.8],
		"heavy": [["i", "a", "a"], 0.26, 1.15, 0.9, 0.05, 0.9],
		"special": [["a", "o", "a", "a"], 0.36, 1.0, 1.25, 0.04, 0.9],
		"hyper": [["a", "a", "i", "a", "a"], 0.75, 0.95, 1.35, 0.06, 1.0],
		"hurt": [["u", "a"], 0.2, 0.95, 0.75, 0.03, 0.8],
		"ko": [["a", "a", "o", "u"], 0.9, 1.3, 0.55, 0.02, 0.9],
		"win": [["i", "e", "a"], 0.38, 1.0, 1.3, 0.0, 0.8],
	}[line]
	var path: Array = spec[0]
	var dur: float = spec[1]
	var n := int(dur * RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	var st := [[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]]
	var coef := [[], [], []]
	var peak := 0.0
	var raw := PackedFloat32Array()
	raw.resize(n)
	for i in n:
		var t := float(i) / n
		if i % 64 == 0:
			var pos := t * (path.size() - 1)
			var v0: Array = VOWELS[path[int(pos)]]
			var v1: Array = VOWELS[path[mini(int(pos) + 1, path.size() - 1)]]
			var fr := pos - int(pos)
			for k in 3:
				coef[k] = _bandpass(lerpf(v0[k], v1[k], fr), [9.0, 12.0, 14.0][k])
		var pitch := f0 * lerpf(spec[2], spec[3], t) * (1.0 + 0.02 * sin(t * 40.0))
		phase = fmod(phase + pitch / RATE, 1.0)
		var src := (1.0 - 2.0 * phase) * 0.8 + randf_range(-0.15, 0.15)
		if t < spec[4] / dur:
			src = randf_range(-1.0, 1.0) * 0.6  # breathy "h"
		var out := 0.0
		for k in 3:
			var c: Array = coef[k]
			var s: Array = st[k]
			var y: float = c[0] * src + c[1] * s[0] + c[2] * s[1] - c[3] * s[2] - c[4] * s[3]  # s = [x1, x2, y1, y2]
			s[1] = s[0]
			s[0] = src
			s[3] = s[2]
			s[2] = y
			out += y * [1.0, 0.7, 0.35][k]
		var env := minf(1.0, t * 25.0) * pow(1.0 - t, 0.6)
		raw[i] = out * env
		peak = maxf(peak, absf(out * env))
	for i in n:
		data.encode_s16(i * 2, int(clampf(raw[i] / maxf(peak, 0.001) * spec[5] * 0.9, -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.data = data
	return w


## Biquad band-pass coefficients [b0, b1, b2, a1, a2] (normalized).
static func _bandpass(freq: float, q: float) -> Array:
	var w0 := TAU * freq / RATE
	var alpha := sin(w0) / (2.0 * q)
	var a0 := 1.0 + alpha
	return [alpha / a0, 0.0, -alpha / a0, -2.0 * cos(w0) / a0, (1.0 - alpha) / a0]


## Tracks in music/ (ogg, wav, or mp3), next to the game or in the project.
## They play in order, under the hits and the voices.
func _start_music() -> void:
	if "--test" in OS.get_cmdline_user_args():
		return
	for dir in [OS.get_executable_path().get_base_dir() + "/music", ProjectSettings.globalize_path("res://music")]:
		var listing := DirAccess.open(dir)
		if listing == null:
			continue
		for name in listing.get_files():
			var ext := name.get_extension().to_lower()
			if ext in ["ogg", "wav", "mp3"]:
				_music_files.append(dir.path_join(name))
	_music_files.sort()
	if _music_files.is_empty():
		return
	_music = AudioStreamPlayer.new()
	_music.volume_db = -16.0
	_music.finished.connect(_advance_music)
	add_child(_music)
	_play_music(0)


func _advance_music() -> void:
	_play_music(_music_i + 1)


func _play_music(i: int) -> void:
	if _music == null or _music_files.is_empty():
		return
	var n := _music_files.size()
	for step in n:
		_music_i = (i + step) % n
		var stream := _load_music(_music_files[_music_i])
		if stream == null:
			continue
		_music.stream = stream
		_music.play()
		return


func _load_music(path: String) -> AudioStream:
	var ext := path.get_extension().to_lower()
	if ext == "wav":
		var wav := _load_pcm_wav(path)
		if wav != null:
			return wav
		return AudioStreamWAV.load_from_file(path)
	if ext == "ogg":
		return AudioStreamOggVorbis.load_from_file(path)
	if ext == "mp3":
		var bytes := FileAccess.get_file_as_bytes(path)
		if bytes.is_empty():
			return null
		var mp3 := AudioStreamMP3.new()
		mp3.data = bytes
		return mp3
	return null


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

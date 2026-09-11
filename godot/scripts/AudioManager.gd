extends Node
## 오디오 (Autoload).
## 효과음(SFX)은 코드로 생성한 짧은 파형 → 오디오 파일 없이도 소리가 난다.
## BGM 은 res://audio/bgm/<track>.ogg 가 있으면 재생, 없으면 조용히 무시 (아트처럼 나중에 추가).

var music_volume := 0.7   # 설정에서 조절 예정
var sfx_volume := 0.7

var _sounds := {}
var _sfx_players: Array = []
var _tick_player: AudioStreamPlayer
var _bgm: AudioStreamPlayer

func _ready() -> void:
	_sounds["tick"]    = _seq([[1200.0, 0.02]], 0.12)
	_sounds["confirm"] = _seq([[660.0, 0.05], [880.0, 0.05]], 0.20)
	_sounds["select"]  = _seq([[520.0, 0.06], [780.0, 0.06]], 0.20)
	_sounds["win"]     = _seq([[523.0, 0.08], [659.0, 0.08], [784.0, 0.14]], 0.26)
	_sounds["lose"]    = _seq([[400.0, 0.12], [300.0, 0.20]], 0.24)
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_sfx_players.append(p)
	_tick_player = AudioStreamPlayer.new()
	add_child(_tick_player)
	_bgm = AudioStreamPlayer.new()
	add_child(_bgm)

func play(sound: String) -> void:
	if not _sounds.has(sound):
		return
	var vdb := linear_to_db(clampf(sfx_volume, 0.001, 1.0))
	if sound == "tick":
		_tick_player.stream = _sounds[sound]
		_tick_player.volume_db = vdb
		_tick_player.play()
		return
	for p in _sfx_players:
		if not p.playing:
			p.stream = _sounds[sound]
			p.volume_db = vdb
			p.play()
			return

func play_bgm(track: String) -> void:
	var path := "res://audio/bgm/%s.ogg" % track
	if not ResourceLoader.exists(path):
		return   # 파일 없으면 무시
	_bgm.stream = load(path)
	_bgm.volume_db = linear_to_db(clampf(music_volume, 0.001, 1.0))
	_bgm.play()

func stop_bgm() -> void:
	_bgm.stop()

## 사인파 음을 이어붙여 짧은 효과음 파형 생성
func _seq(notes: Array, vol: float) -> AudioStreamWAV:
	var rate := 22050
	var data := PackedByteArray()
	for note in notes:
		var f: float = note[0]
		var dur: float = note[1]
		var n := int(rate * dur)
		var base := data.size()
		data.resize(base + n * 2)
		for i in n:
			var t := float(i) / rate
			var env := 1.0 - float(i) / float(n)   # 감쇠
			var s := sin(TAU * f * t) * env * vol
			data.encode_s16(base + i * 2, int(clampf(s, -1.0, 1.0) * 32767))
	var st := AudioStreamWAV.new()
	st.format = AudioStreamWAV.FORMAT_16_BITS
	st.mix_rate = rate
	st.stereo = false
	st.data = data
	return st

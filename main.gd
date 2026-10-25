extends Control
## 打地鼠 —— 纯代码构建 UI，不依赖额外素材

const ROUND_TIME := 30.0
const HOLE_COUNT := 9

var _score := 0
var _time_left := ROUND_TIME
var _running := false
var _mole_index := -1
var _timer := 0.0

var _holes: Array[Button] = []
var _moles: Array[Panel] = []
var _score_label: Label
var _time_label: Label
var _overlay: Control
var _overlay_title: Label
var _overlay_button: Button


func _ready() -> void:
	_apply_font()
	_build_ui()
	_show_overlay("打地鼠", "开始游戏")
	print("打地鼠已启动")


func _apply_font() -> void:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Noto Sans CJK SC", "Noto Sans SC", "Source Han Sans SC", "Sans"])
	var theme := Theme.new()
	theme.default_font = font
	theme.default_font_size = 40
	self.theme = theme


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.13, 0.18)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var top := HBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_top = 60
	top.offset_bottom = 160
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_theme_constant_override("separation", 120)
	add_child(top)

	_score_label = Label.new()
	_score_label.add_theme_font_size_override("font_size", 52)
	top.add_child(_score_label)

	_time_label = Label.new()
	_time_label.add_theme_font_size_override("font_size", 52)
	top.add_child(_time_label)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 28)
	grid.add_theme_constant_override("v_separation", 28)
	center.add_child(grid)

	for i in HOLE_COUNT:
		var hole := Button.new()
		hole.custom_minimum_size = Vector2(300, 300)
		hole.focus_mode = Control.FOCUS_NONE
		hole.pressed.connect(_on_hole_pressed.bind(i))

		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.22, 0.28, 0.21)
		normal.set_corner_radius_all(30)
		hole.add_theme_stylebox_override("normal", normal)

		var pressed_style := StyleBoxFlat.new()
		pressed_style.bg_color = Color(0.16, 0.21, 0.16)
		pressed_style.set_corner_radius_all(30)
		hole.add_theme_stylebox_override("pressed", pressed_style)

		var hover := StyleBoxFlat.new()
		hover.bg_color = Color(0.26, 0.33, 0.25)
		hover.set_corner_radius_all(30)
		hole.add_theme_stylebox_override("hover", hover)

		grid.add_child(hole)
		_holes.append(hole)

		var mole := Panel.new()
		mole.set_anchors_preset(Control.PRESET_FULL_RECT)
		mole.offset_left = 55
		mole.offset_top = 55
		mole.offset_right = -55
		mole.offset_bottom = -55
		mole.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mole_style := StyleBoxFlat.new()
		mole_style.bg_color = Color(0.96, 0.78, 0.42)
		mole_style.set_corner_radius_all(200)
		mole.add_theme_stylebox_override("panel", mole_style)
		mole.visible = false
		hole.add_child(mole)
		_moles.append(mole)

	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.05, 0.06, 0.09, 0.88)
	add_child(_overlay)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 60)
	_overlay.add_child(vbox)

	_overlay_title = Label.new()
	_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_title.add_theme_font_size_override("font_size", 64)
	vbox.add_child(_overlay_title)

	_overlay_button = Button.new()
	_overlay_button.text = "开始游戏"
	_overlay_button.custom_minimum_size = Vector2(360, 120)
	_overlay_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_overlay_button.add_theme_font_size_override("font_size", 48)
	_overlay_button.pressed.connect(_start_game)
	vbox.add_child(_overlay_button)


func _show_overlay(title: String, button_text: String) -> void:
	_overlay_title.text = title
	_overlay_button.text = button_text
	_overlay.visible = true


func _start_game() -> void:
	_score = 0
	_time_left = ROUND_TIME
	_mole_index = -1
	_timer = 0.6
	_running = true
	_overlay.visible = false
	for mole in _moles:
		mole.visible = false
	_update_labels()
	print("开始游戏")


func _update_labels() -> void:
	_score_label.text = "得分 %d" % _score
	_time_label.text = "时间 %d" % int(ceil(max(_time_left, 0.0)))


func _on_hole_pressed(index: int) -> void:
	if not _running:
		return
	if index != _mole_index:
		return
	_score += 1
	_moles[_mole_index].visible = false
	_mole_index = -1
	_timer = 0.15
	_update_labels()


func _process(delta: float) -> void:
	if not _running:
		return

	_time_left -= delta
	_update_labels()
	if _time_left <= 0.0:
		_end_game()
		return

	_timer -= delta
	if _timer > 0.0:
		return

	if _mole_index >= 0:
		_moles[_mole_index].visible = false
		_mole_index = -1
		_timer = randf_range(0.20, 0.45)
	else:
		_mole_index = randi() % HOLE_COUNT
		_moles[_mole_index].visible = true
		_timer = randf_range(0.65, 0.95)


func _end_game() -> void:
	_running = false
	_time_left = 0.0
	if _mole_index >= 0:
		_moles[_mole_index].visible = false
		_mole_index = -1
	_update_labels()
	_show_overlay("时间到！\n得分 %d" % _score, "再玩一次")
	print("游戏结束，得分 %d" % _score)

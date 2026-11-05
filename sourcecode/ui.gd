extends CanvasLayer

@onready var hp_bar: ProgressBar = $HUD/HBoxContainer/HPBar
@onready var pause_menu: Control = $PauseMenu
@onready var continue_button: Button = $PauseMenu/CenterContainer/VBoxContainer/ContinueButton
@onready var quit_button: Button = $PauseMenu/CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# supaya Esc tetap terbaca dan tombol bisa diklik saat game di-pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.hide()
	continue_button.pressed.connect(resume)
	quit_button.pressed.connect(get_tree().quit)

	# tunggu satu frame agar player sudah masuk group "player"
	await get_tree().process_frame
	var p = get_tree().get_first_node_in_group("player")
	if p:
		p.health_changed.connect(_on_health_changed)
		_on_health_changed(p.hp, p.max_hp)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # tombol Esc
		if get_tree().paused:
			resume()
		else:
			pause()
		get_viewport().set_input_as_handled()

	# TEMPORARY: tekan H untuk tes bar HP, hapus nanti
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		var p = get_tree().get_first_node_in_group("player")
		if p:
			p.take_damage(10)

func pause() -> void:
	get_tree().paused = true
	pause_menu.show()
	continue_button.grab_focus()

func resume() -> void:
	get_tree().paused = false
	pause_menu.hide()

func _on_health_changed(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

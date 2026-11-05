extends player

var is_attack := false
var is_guard := false

@onready var attack_ray: RayCast2D = get_node_or_null("AttackRay")
@onready var sfx_attack: AudioStreamPlayer2D = get_node_or_null("SfxAttack")
@onready var sfx_run: AudioStreamPlayer2D = get_node_or_null("SfxRun")

func _ready() -> void:
	add_to_group("player")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _process(dt: float) -> void:
	var input_direction := Vector2.ZERO

	# controls
	var right := Input.is_key_pressed(KEY_D)
	var left := Input.is_key_pressed(KEY_A)
	var forward := Input.is_key_pressed(KEY_W)
	var backward := Input.is_key_pressed(KEY_S)
	var m1 := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var m2 := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

	if right:
		input_direction.x += 1
		look_at = 1
		$AnimatedSprite2D.flip_h = false
	if left:
		input_direction.x -= 1
		look_at = -1
		$AnimatedSprite2D.flip_h = true
	if forward:
		input_direction.y -= 1
	if backward:
		input_direction.y += 1

	# arah raycast mengikuti arah hadap karakter
	if attack_ray:
		attack_ray.target_position = Vector2(48 * look_at, 0)

	input_direction = input_direction.normalized() * speed

	# serangan hanya dipicu sekali per klik
	if m1 and not is_guard and not is_attack:
		_start_attack()

	if m2:
		if not is_attack:
			is_guard = true
			input_direction = input_direction.normalized() * guard_speed
	else:
		is_guard = false

	velocity = input_direction

	if not is_zero_approx(velocity.length()):
		if $AnimatedSprite2D.animation != "run" and (not is_attack and not is_guard):
			$AnimatedSprite2D.play("run")
	else:
		if $AnimatedSprite2D.animation != "idle" and (not is_attack and not is_guard):
			$AnimatedSprite2D.play("idle")

	if is_attack:
		$AnimatedSprite2D.play("attack")

	if is_guard:
		if $AnimatedSprite2D.animation != "guard":
			$AnimatedSprite2D.play("guard")
	else:
		if $AnimatedSprite2D.animation == "guard":
			$AnimatedSprite2D.stop()

	_update_run_sound()
	move_and_slide()

func _update_run_sound() -> void:
	if not sfx_run:
		return
	var is_moving := not is_zero_approx(velocity.length())
	if is_moving and not is_attack and not is_guard:
		if not sfx_run.playing:
			sfx_run.play()
	else:
		if sfx_run.playing:
			sfx_run.stop()

func _start_attack() -> void:
	is_attack = true
	if sfx_attack:
		sfx_attack.play()
	do_attack_hit()

func do_attack_hit() -> void:
	if not attack_ray:
		return
	attack_ray.force_raycast_update()
	if attack_ray.is_colliding():
		var target = attack_ray.get_collider()
		if target.has_method("take_damage"):
			target.take_damage(10)

func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "attack":
		is_attack = false

func take_damage(amount: int) -> void:
	if is_guard:
		amount = int(amount * 0.5)  # guard mengurangi damage setengahnya
	hp = maxi(hp - amount, 0)
	health_changed.emit(hp, max_hp)
	if hp <= 0:
		get_tree().reload_current_scene()

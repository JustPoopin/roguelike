extends player

var is_attack := false
var is_guard := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation_finished.connect(animation_finished)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		
	input_direction = input_direction.normalized() * speed
	
	if m1:
		if not is_guard:
			is_attack = true
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
			$AnimatedSprite2D.stop("guard")
	
	move_and_slide()
	pass

# Fungsi ini otomatis dipanggil Godot saat animasi NON-LOOP mencapai frame terakhir
func animation_finished() -> void:
	if $AnimatedSprite2D.animation == "attack":
		is_attack = false

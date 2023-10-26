extends KinematicBody2D

signal life_changed
signal dead

export (int) var run_speed
export (int) var jump_speed
export (int) var gravity

enum {IDLE, RUN, JUMP, HURT, DEAD}
var state
var anim
var new_anim
var velocity = Vector2()
var life

func ready():
	change_state(IDLE)

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = 'idle'
		RUN:
			new_anim = 'run'
		HURT:
			new_anim = 'hurt'
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			emit_signal('life_changed', life)
			yield(get_tree().create_timer(0.5), 'timeout')
			change_state(IDLE)
			if life <= 0:
				change_state(DEAD)
		JUMP:
			new_anim = 'jump_up'
		DEAD:
			emit_signal('dead')
			hide()

func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	if new_anim != anim:
		anim = new_anim
		$AnimationPlayer.play(anim)
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	if state == JUMP and velocity.y > 0:
		new_anim = 'jump_down'

func get_input():
	if state == HURT:
		return
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed("jump")
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite.flip_h = true
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)

func start(pos):
	life = 3
	emit_signal('life_changed', life)
	position = pos
	show()
	change_state(IDLE)

func hurt():
	if state != HURT:
		change_state(HURT)

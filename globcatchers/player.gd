extends CharacterBody3D

signal done_digging

const SPEED = 3.0
const RUN_SPEED = 7.0
const JUMP_VELOCITY = 5.5

var mouse_sensitivity := 0.005
var twist_input := 0.0
var pitch_input := 0.0
var can_move = true

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var catch_player := $CatchPlayer
@onready var buraco_atual: Area3D = null

@export var texture1: Texture2D
@export var texture2: Texture2D
@onready var current_material: Material = $Skeleton3D/PlayerMesh.get_surface_override_material(0)
var is_using_texture1: bool = true
var is_colliding_buraco = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not current_material:
		current_material = StandardMaterial3D.new()
		$Skeleton3D.set_surface_override_material(0, current_material)

func _physics_process(delta: float) -> void:
	#Handling cursor visibility
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("mouse_click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(-30),
		deg_to_rad(30)
	)
	twist_input = 0.0
	pitch_input = 0.0
	
	if can_move: 
		
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta * 2

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction : Vector3 = (twist_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if input_dir != Vector2(0,0):
			$Skeleton3D.rotation_degrees.y = twist_pivot.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90

		if direction != Vector3.ZERO:
			if Input.is_action_pressed("ui_run"):
				velocity.x = direction.x * RUN_SPEED
				velocity.z = direction.z * RUN_SPEED
				$RunPlayer.play("running")
				$WalkPlayer.stop()
				$IdlePlayer.stop()
			else:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
				$WalkPlayer.play("walking")
				$RunPlayer.stop()
				$IdlePlayer.stop()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			if is_on_floor():
				$IdlePlayer.play("idle")
				$RunPlayer.stop()
				$WalkPlayer.stop()
		
		move_and_slide()
		
		cavar_buraco()

	if Input.is_action_just_pressed("pe"):
		if is_using_texture1 and texture2:
			current_material.set("albedo_texture", texture2)
			is_using_texture1 = false
		elif not is_using_texture1 and texture1:
			current_material.set("albedo_texture", texture1)
			is_using_texture1 = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity

func _on_node_added(node):
	if node.is_in_group("buraco"):
		node.player_entered.connect(_on_buraco_player_entered)
		node.player_exited.connect(_on_buraco_player_exited)

func _on_buraco_player_entered(area) -> void:
	is_colliding_buraco = true
	buraco_atual = area

func _on_buraco_player_exited() -> void:
	is_colliding_buraco = false
	buraco_atual = null

func cavar_buraco():
	if is_colliding_buraco:
		if Input.is_action_just_pressed("mouse_click"):
			if catch_player:
				can_move = false
				catch_player.play("catch")
				await catch_player.animation_finished
				buraco_atual.queue_free()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				done_digging.emit()
				can_move = true

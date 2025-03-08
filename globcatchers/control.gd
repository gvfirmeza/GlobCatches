extends Control

var glob_list = ["Globão", "Globinho", "Rare Glob", "Dumb Glob"]
var weights = [50, 30, 15, 5]
var glob_images = {
	"Globão": "res://assets/globs/globao.png",
	"Globinho": "res://assets/globs/lixo.jpg",
	"Rare Glob": "res://assets/globs/nerd.jpg",
	"Dumb Glob": "res://assets/globs/o.jpg"
}
var unlocked_globs = {}

func _ready() -> void:
	for glob_name in glob_images.keys():
		var slot = preload("res://BestiarySlot.tscn").instantiate()
		slot.get_node("Label").text = glob_name
		$BestiaryPopUp/BestiaryGrid.add_child(slot)
		unlocked_globs[glob_name] = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("bestiary_key"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$BestiaryPopUp.visible = true

func _on_button_pressed() -> void:
	$GlobPopUp.visible = false
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_button_button_down() -> void:
	$GlobPopUp.visible = false
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_player_novo_done_digging() -> void:
	var chosen_index = choose_with_weights(weights)
	var chosen_glob = glob_list[chosen_index]

	unlock_glob(chosen_glob)
	$GlobPopUp/Label.text = chosen_glob
	var image_path = glob_images.get(chosen_glob, "res://assets/globs/o.jpg")
	var texture = load(image_path)
	$GlobPopUp/TextureRect.texture = texture
	$GlobPopUp.visible = true

func choose_with_weights(weights: Array) -> int:
	var total_weight = 0
	for weight in weights:
		total_weight += weight

	var random_value = randi() % total_weight
	var cumulative_weight = 0

	for i in range(weights.size()):
		cumulative_weight += weights[i]
		if random_value < cumulative_weight:
			return i

	return 0

func unlock_glob(glob_name: String) -> void:
	if glob_name in unlocked_globs:
		unlocked_globs[glob_name] = true
		update_bestiary()

func update_bestiary() -> void:
	for slot in $BestiaryPopUp/BestiaryGrid.get_children():
		var glob_name = slot.get_node("Label").text
		if unlocked_globs.get(glob_name, false):
			var texture = load(glob_images.get(glob_name, "res://assets/globs/o.jpg"))
			slot.set_slot(glob_name, texture)

func _on_button_bestiary_pressed() -> void:
	$BestiaryPopUp.visible = false
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_button_bestiary_button_down() -> void:
	$BestiaryPopUp.visible = false
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

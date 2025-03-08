extends Control

var glob_list = ["Globão", "Globinho", "Rare Glob", "Dumb Glob"]
var weights = [50, 30, 15, 5]
var glob_images = {
	"Globão": "res://assets/globs/globao.png",
	"Globinho": "res://assets/globs/lixo.jpg",
	"Rare Glob": "res://assets/globs/nerd.jpg",
	"Dumb Glob": "res://assets/globs/o.jpg"
}

func _on_button_pressed() -> void:
	$GlobPopUp.visible = false

func _on_button_button_down() -> void:
	$GlobPopUp.visible = false

func _on_player_novo_done_digging() -> void:
	var chosen_index = choose_with_weights(weights)
	var chosen_glob = glob_list[chosen_index]

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

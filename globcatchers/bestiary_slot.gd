extends Control

func set_slot(glob_name: String, texture: Texture) -> void:
	$Label2.visible = false
	$Label.text = glob_name
	$Label.visible = true
	$TextureRect.texture = texture
	$TextureRect.visible = true
	

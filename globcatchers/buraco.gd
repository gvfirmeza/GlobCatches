extends Area3D

signal player_entered(area)
signal player_exited()

func _ready():
	add_to_group("buraco")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	if body.name == "PlayerNovo":
		player_entered.emit(self)

func _on_body_exited(body):
	if body.name == "PlayerNovo":
		player_exited.emit()

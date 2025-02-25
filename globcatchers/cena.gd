extends Node3D

@export var objeto_spawnado: PackedScene

@onready var BuracoSpawnTimer = $BuracoSpawn

func _on_buraco_spawn_timeout() -> void:
	spawn_buraco()

func spawn_buraco():
	if objeto_spawnado:
		var instancia = objeto_spawnado.instantiate() 
		add_child(instancia)

		var area = $Area3D
		var shape = area.get_child(0).shape
		if shape is BoxShape3D:
			var pos_x = randf_range(-shape.size.x / 2, shape.size.x / 2)
			var pos_y = randf_range(-shape.size.y / 2, shape.size.y / 2)
			var pos_z = randf_range(-shape.size.z / 2, shape.size.z / 2)
			instancia.position = area.position + Vector3(pos_x, pos_y, pos_z)

		var player_node = get_node("PlayerNovo")
		instancia.player_entered.connect(player_node._on_buraco_player_entered)
		instancia.player_exited.connect(player_node._on_buraco_player_exited)

func _ready():
	BuracoSpawnTimer.connect("timeout", _on_buraco_spawn_timeout)

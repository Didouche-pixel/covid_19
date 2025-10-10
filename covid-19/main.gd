extends Node3D

const ZOMBIE_COUNT := 50
const HUMAN_COUNT := 50

var min_x: float = -50
var max_x: float = 50
var min_z: float = -50
var max_z: float = 50

var zombie_scene := preload("res://zombie.tscn")
var human_scene := preload("res://humain.tscn")

func _ready() -> void:
	randomize()

	# Créer zombies
	for i in ZOMBIE_COUNT:
		var z := zombie_scene.instantiate()
		add_child(z)
		z.global_transform.origin = Vector3(
			randf_range(min_x, max_x), 0.0, randf_range(min_z, max_z)
		)

	# Créer humains
	for i in HUMAN_COUNT:
		var h := human_scene.instantiate()
		add_child(h)
		h.global_transform.origin = Vector3(
			randf_range(min_x, max_x), 0.0, randf_range(min_z, max_z)
		)

extends Node3D

const COUNT_VIRUS := 50
const HUMAN_COUNT := 50

var min_x: float = -50
var max_x: float = 50
var min_z: float = -50
var max_z: float = 50

var scene_de_virus := preload("res://virus.tscn")
var scene_des_humains := preload("res://humain.tscn")

func _ready() -> void:
	randomize()

	# Création de virus
	for i in COUNT_VIRUS:
		var z := scene_de_virus.instantiate()
		add_child(z)
		z.global_transform.origin = Vector3(
			randf_range(min_x, max_x), 0.0, randf_range(min_z, max_z)
		)

	# Création des humains
	for i in HUMAN_COUNT:
		var h := scene_des_humains.instantiate()
		add_child(h)
		h.global_transform.origin = Vector3(
			randf_range(min_x, max_x), 0.0, randf_range(min_z, max_z)
		)

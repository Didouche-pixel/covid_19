extends Node3D
# Scène principale : crée N virus et M humains, puis leur passe les bornes de la zone.

# Combien d’agents au départ
@export var VIRUS_COUNT: int = 3
@export var HUMAN_COUNT: int = 25

# Bornes de la zone (comme dans tes exemples)
@export var min_x: float = -50.0
@export var max_x: float =  50.0
@export var min_z: float = -50.0
@export var max_z: float =  50.0

# Références vers les scènes à instancier
@export var virus_scene: PackedScene = preload("res://virus.tscn")
@export var human_scene: PackedScene = preload("res://homme.tscn")

func _ready() -> void:
	randomize()

	# --- Spawn des virus ---
	for i in VIRUS_COUNT:
		var v := virus_scene.instantiate()
		add_child(v)
		# Position aléatoire dans la zone
		v.global_transform.origin = Vector3(
			randf_range(min_x, max_x), 0.0, randf_range(min_z, max_z)
		)
		# Passe les bornes (appelle une méthode utilitaire du virus)
		v.call_deferred("_set_bounds", min_x, max_x, min_z, max_z)

	# --- Spawn des humains (sains au départ) ---
	for i in HUMAN_COUNT:
		var h := human_scene.instantiate()
		add_child(h)
		h.global_transform.origin = Vector3(
			randf_range(min_x, max_x), 0.0, randf_range(min_z, max_z)
		)
		h.call_deferred("_set_bounds", min_x, max_x, min_z, max_z)

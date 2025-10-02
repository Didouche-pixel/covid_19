extends RigidBody3D
# Virus : poursuit l'humain sain le plus proche et l'infecte au contact.

# Réglages : vitesse de poursuite et rotation
@export var chase_speed: float = 1.8
@export var turn_speed: float = 8.0

# Texture du virus
@export var tex_virus: Texture2D

# Bornes (zone de jeu)
var min_x: float = -50.0
var max_x: float =  50.0
var min_z: float = -50.0
var max_z: float =  50.0

# Référence au Mesh
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	add_to_group("virus")         # pour être reconnu comme virus
	set_contact_monitor(true)     # activer détection collisions
	set_max_contacts_reported(6)
	_apply_texture(tex_virus)

func _physics_process(delta: float) -> void:
	# Cherche l'humain sain le plus proche
	var target: RigidBody3D = _closest_healthy()
	if target != null:
		# Direction vers la cible (maintenant bien typée)
		var dir: Vector3 = (target.global_transform.origin - global_transform.origin).normalized()
		
		# Rotation vers la cible
		var torque: Vector3 = (dir.cross(Vector3.UP)).normalized() * turn_speed
		apply_torque_impulse(torque)

		# Avance vers la cible
		apply_central_impulse(dir * chase_speed)

	# Wrap aux bords de la zone
	if position.x > max_x: position.x = min_x
	if position.x < min_x: position.x = max_x
	if position.z > max_z: position.z = min_z
	if position.z < min_z: position.z = max_z

# Quand le virus touche un humain sain → infection
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("homme"):
		body.call_deferred("become_infected")

# --- Helpers ---
func _closest_healthy() -> RigidBody3D:
	# Retourne l'humain sain le plus proche (RigidBody3D)
	var best: RigidBody3D = null
	var best_d: float = 1e9
	var humans := get_tree().get_nodes_in_group("homme")
	for h in humans:
		var hb := h as RigidBody3D
		if hb != null and hb.is_inside_tree():
			var d: float = global_transform.origin.distance_to(hb.global_transform.origin)
			if d < best_d:
				best_d = d
				best = hb
	return best

func _apply_texture(tex: Texture2D) -> void:
	if tex == null:
		return
	var mat := mesh.get_active_material(0)
	if mat == null:
		mat = StandardMaterial3D.new()
	else:
		mat = mat.duplicate()
	mat.albedo_texture = tex
	mat.albedo_color = Color.WHITE
	mesh.set_surface_override_material(0, mat)

func _set_bounds(a: float, b: float, c: float, d: float) -> void:
	min_x = a; max_x = b; min_z = c; max_z = d

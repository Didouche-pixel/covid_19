extends RigidBody3D

# --- Déplacement lent / errance ---
var speed: float = 0.5
var direction: Vector3 = Vector3.ZERO
var turn_speed: float = 0.5
var change_direction_time: float = 1.0
var time_since_change: float = 0.0

# --- Limites (si besoin) ---
var min_x: float = -50
var max_x: float = 50
var min_z: float = -50
var max_z: float = 50

# --- États ---
var est_virus: bool = false       
var following_human: Node = null

# --- Timer optionnel pour revenir à la couleur d’origine ---
@onready var _hit_timer := Timer.new()
var _restore_after_sec: float = 0.0 # 0 => reste rouge; >0 => redevient blanc après X sec

func _ready() -> void:
	add_to_group("humans")

	# Connexion du signal
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	# set_contact_monitor(true) # utile si tu es en 3.x
	choose_new_direction()

	# Timer de retour couleur (désactivé par défaut)
	add_child(_hit_timer)
	_hit_timer.one_shot = true
	_hit_timer.timeout.connect(func ():
		# Repeint en "blanc" (ou la couleur de base)
		_tint_meshes(self, Color(1, 1, 1))
	)

func choose_new_direction() -> void:
	if not following_human:
		direction = Vector3(randf() * 2.0 - 1.0, 0, randf() * 2.0 - 1.0).normalized()

func _process(delta: float) -> void:
	time_since_change += delta

	if following_human and following_human.is_inside_tree():
		direction = (following_human.global_transform.origin - global_transform.origin).normalized()
	else:
		following_human = null
		if time_since_change > change_direction_time:
			choose_new_direction()
			time_since_change = 0.0

	# Prendre la fuite si un virus rapproche
	if est_virus_detected():
		flee_from_virus()

	# Tourner et avancer
	var rotation_torque := (direction.cross(Vector3.UP)).normalized() * turn_speed
	apply_torque_impulse(rotation_torque)
	apply_central_impulse(direction * speed)

# --- COLORATION ROUGE AU TOUCHER ---
# --- COLORATION ROUGE AU TOUCHER ---
#func mark_hit() -> void:
#if is_zombie:
# return
#print("Humain touché ! Devient rouge.")
#_tint_meshes(self, Color(1, 0, 0))
#if _restore_after_sec > 0.0:
#_hit_timer.start(_restore_after_sec)
# --- COLORATION ROUGE AU TOUCHER ---


func mark_hit() -> void:
	if est_virus:
		return
	print("Humain touché ! Instance d'un humain mort.")

	# Création et ajout de l'humain mort (cadavre)
	var humain_mort_scene := preload("res://humain_mort.tscn")
	var humain_mort: Node3D = humain_mort_scene.instantiate()
	humain_mort.global_transform = global_transform
	get_parent().add_child(humain_mort)

# --- Position couchée du cadavre---
	var rotation_couchee: Vector3 = humain_mort.rotation
	rotation_couchee.x = deg_to_rad(-90.0) # mets -90 selon l'orientation de modèle	
	humain_mort.rotation = rotation_couchee

	# pour toucher le sol
	humain_mort.position.y -= -0.5

	# Teinte en rouge 
	_tint_meshes(humain_mort, Color(1.0, 0.0, 0.0, 1.0))

	# Suppression de l'humain vivant
	queue_free()


# Teinte récursivement toutes les MeshInstance3D sous ce nœud
func _tint_meshes(node: Node, color: Color) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh:
			for s in mi.mesh.get_surface_count():
				var mat := mi.get_surface_override_material(s)
				if mat == null:
					var base := mi.mesh.surface_get_material(s)
					if base != null:
						mat = base.duplicate()
					else:
						mat = StandardMaterial3D.new()
				else:
					mat = mat.duplicate()
				if mat is StandardMaterial3D:
					(mat as StandardMaterial3D).albedo_color = color
				mi.set_surface_override_material(s, mat)

	for child in node.get_children():
		_tint_meshes(child, color)

# --- Comportements existants utiles ---
func est_virus_detected() -> bool:
	var viruses := get_tree().get_nodes_in_group("viruses")
	for virus in viruses:
		if virus.is_inside_tree() and global_transform.origin.distance_to(virus.global_transform.origin) < 10.0:
			return true
	return false

func flee_from_virus() -> void:
	var direction_to_flee := (global_transform.origin - get_closest_virus_position()).normalized()
	direction = direction_to_flee

func get_closest_virus_position() -> Vector3:
	var closest_virus_pos := global_transform.origin
	var closest_distance := 1e6
	var viruses := get_tree().get_nodes_in_group("viruses")
	for virus in viruses:
		if virus.is_inside_tree():
			var d := global_transform.origin.distance_to(virus.global_transform.origin)
			if d < closest_distance:
				closest_distance = d
				closest_virus_pos = virus.global_transform.origin
	return closest_virus_pos

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("viruses"):
		print("virus a touché un humain sain")
		mark_hit() # à la palce  de become_virus()
	elif body.is_in_group("humans") and not following_human:
		print("Humain trouve un autre humain, le pourvuivre pour prendre la fuite")
		following_human = body

func become_virus() -> void:
	if est_virus:
		return
	print("Humain touché par le virus (Contaminé et deviens cadavre !)")
	est_virus = true
	# Désactivée dans ce scénario : on ne transforme plus.

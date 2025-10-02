extends RigidBody3D
# Humain : se déplace aléatoirement (random walk). Si infecté par virus au contact,
# démarre un chrono; au bout de ~5s, "meurt": devient cadavre (texture), s'arrête.

# États possibles
enum State { HEALTHY, INFECTED, DEAD }
var state: State = State.HEALTHY          # état initial : sain

# Réglages de mouvement (faibles pour éviter les "sauts")
@export var walk_speed: float = 1.2       # intensité d'impulsion
@export var turn_speed: float = 6.0       # "vitesse" de rotation vers la direction choisie

# Durée d'infection avant la mort (exigence : ~5 secondes)
@export var infection_duration: float = 5.0
var infected_time: float = 0.0            # chrono depuis infection

# Textures (à assigner dans l’Inspector)
@export var tex_human: Texture2D          # image pour Humain sain (ex: human.png)
@export var tex_cadaver: Texture2D        # image pour Cadavre (ex: cadaver.png)

# Bornes (mises à jour depuis Main)
var min_x: float = -50.0
var max_x: float =  50.0
var min_z: float = -50.0
var max_z: float =  50.0

# Direction actuelle + timer pour changer de direction
var dir: Vector3 = Vector3.ZERO
var change_dir_timer: float = 0.0

# Raccourci vers le Mesh pour changer la texture/couleur
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# Détection des contacts (nécessaire pour body_entered)
	set_contact_monitor(true)
	set_max_contacts_reported(4)

	# Groupe "humans" = identifie clairement les sains et infectés (pas les virus).
	add_to_group("homme")

	# Apparence initiale (image "humain")
	_apply_texture(tex_human)
	_pick_new_dir()  # première direction aléatoire

func _physics_process(delta: float) -> void:
	if state != State.DEAD:
		# Changement de direction périodique (marche aléatoire)
		change_dir_timer -= delta
		if change_dir_timer <= 0.0:
			_pick_new_dir()

		# Tourner progressivement vers la direction dir
		var torque := (dir.cross(Vector3.UP)).normalized() * turn_speed
		apply_torque_impulse(torque)

		# Avancer doucement dans la direction dir
		apply_central_impulse(dir * walk_speed)

		# Rebouclage aux bords de la zone
		if position.x > max_x: position.x = min_x
		if position.x < min_x: position.x = max_x
		if position.z > max_z: position.z = min_z
		if position.z < min_z: position.z = max_z

	# Gestion du chrono d'infection et passage à l'état "mort"
	if state == State.INFECTED:
		infected_time += delta
		if infected_time >= infection_duration:
			_die()

# Collision : appelée quand on touche un autre corps
# ⚠️ Connecte le signal "body_entered" du RigidBody3D vers cette méthode dans l’éditeur.
func _on_body_entered(body: Node) -> void:
	# Si je suis sain et que je touche un virus -> je deviens infecté
	if state == State.HEALTHY and body.is_in_group("virus"):
		become_infected()

# --- Transitions d'état ---
func become_infected() -> void:
	if state != State.HEALTHY:
		return
	state = State.INFECTED
	infected_time = 0.0
	# Option visuelle : teinte orange (on garde la texture humain, mais teintée)
	_tint_current_material(Color(1.0, 0.6, 0.0))  # orange = infecté

func _die() -> void:
	state = State.DEAD
	# Devient un "cadavre" (on peut le sortir du groupe "humans" et le mettre "Dead")
	remove_from_group("homme")
	add_to_group("Dead")
	# Met la texture "cadavre", s'arrête et "s'endort"
	_apply_texture(tex_cadaver)
	linear_velocity = Vector3.ZERO
	sleeping = true  # fige le RigidBody3D

# --- Helpers visuels / utilitaires ---
func _pick_new_dir() -> void:
	# Nouvelle direction aléatoire dans le plan XZ
	dir = Vector3(randf()*2.0 - 1.0, 0.0, randf()*2.0 - 1.0).normalized()
	change_dir_timer = randf_range(0.6, 1.2)

func _apply_texture(tex: Texture2D) -> void:
	# Applique une texture au matériau du mesh
	if tex == null:
		return
	var mat := mesh.get_active_material(0)
	if mat == null:
		mat = StandardMaterial3D.new()
	else:
		mat = mat.duplicate()  # unique à cette instance
	mat.albedo_texture = tex
	mat.albedo_color = Color.WHITE
	mesh.set_surface_override_material(0, mat)

func _tint_current_material(c: Color) -> void:
	# Teinte le matériau courant (utile pour afficher "infecté" sans changer de texture)
	var mat := mesh.get_active_material(0)
	if mat == null:
		mat = StandardMaterial3D.new()
	else:
		mat = mat.duplicate()
	mat.albedo_color = c
	mesh.set_surface_override_material(0, mat)

func _set_bounds(a: float, b: float, c: float, d: float) -> void:
	# Reçoit les bornes depuis Main
	min_x = a; max_x = b; min_z = c; max_z = d

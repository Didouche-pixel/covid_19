extends RigidBody3D

# --- Poursuite + contrôle physique ---
@export var speed_max: float = 20.0
@export var accel: float = 30.0
@export var turn_speed: float = 15.0
var target: Node3D = null

# --- DISPERSION ---
@export var separation_radius: float = 6.0     # rayon de "bulle perso"
@export var separation_weight: float = 1.5     # poids de la séparation dans la direction finale
@export var wander_weight: float = 0.25        # poids du wander (bruit de direction)
var _wander: Vector3 = Vector3.ZERO            # direction erratique lissée

# --- Retarget (pour éviter que tous pick la même personne trop longtemps) ---
@export var retarget_interval: float = 1.2
var _retarget_timer: float = 0.0

func _ready() -> void:
	add_to_group("zombies")
	linear_damp = 0.05
	angular_damp = 0.05
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	choose_target()

func choose_target() -> void:
	var humans := get_tree().get_nodes_in_group("humans")
	if humans.size() > 0:
		# Choix aléatoire simple pour briser la synchro entre zombies
		target = humans[randi() % humans.size()] as Node3D

func _physics_process(delta: float) -> void:
	# Retarget périodique pour éviter la cohorte
	_retarget_timer -= delta
	if _retarget_timer <= 0.0:
		choose_target()
		_retarget_timer = retarget_interval

	# WANDER (petit bruit lissé sur le plan XZ)
	var jitter := Vector3(randf() * 2.0 - 1.0, 0.0, randf() * 2.0 - 1.0).normalized() * 0.5
	_wander = (_wander + jitter * delta * 4.0).limit_length(1.0)

	var pursuit_dir := Vector3.ZERO
	if target != null and target.is_inside_tree():
		var to_target := (target.global_transform.origin - global_transform.origin)
		if to_target.length() > 0.001:
			pursuit_dir = to_target.normalized()

	# SÉPARATION : pousse loin des zombies dans un rayon
	var sep := _compute_separation()

	# Direction finale pondérée (poursuite + séparation + wander)
	var final_dir := (pursuit_dir + sep * separation_weight + _wander * wander_weight)
	if final_dir.length() < 0.001:
		return
	final_dir = final_dir.normalized()

	# Rotation vers la direction finale
	var rotation_torque: Vector3 = (final_dir.cross(Vector3.UP)).normalized() * turn_speed
	apply_torque_impulse(rotation_torque)

	# Vitesse désirée + accélération
	var desired_vel := final_dir * speed_max
	linear_velocity = linear_velocity.move_toward(desired_vel, accel * delta)

func _compute_separation() -> Vector3:
	var sum := Vector3.ZERO
	var count := 0
	var my_pos := global_transform.origin

	for z in get_tree().get_nodes_in_group("zombies"):
		if z == self or not (z is Node3D):
			continue
		var other_pos := (z as Node3D).global_transform.origin
		var to_me := my_pos - other_pos
		var d := to_me.length()
		if d > 0.001 and d < separation_radius:
			# plus c'est proche, plus la répulsion est forte
			var strength := 1.0 - (d / separation_radius)   # 1 à très proche -> 0 à la limite
			sum += (to_me / d) * strength                   # normalisé * force
			count += 1

	if count > 0:
		sum /= float(count)
	# clamp pour éviter des pics violents
	return sum.limit_length(1.0)

func attack_human(human: Node) -> void:
	if human.is_in_group("humans"):
		print("Zombie attaque l'humain ! (marque en rouge)")
		human.call("mark_hit")

func _on_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("humans"):
		print("Zombie a touché un humain")
		attack_human(body)

extends Node3D

@export var lifetime: float = 5.0
@export var max_allowed_scale: float = 2.0

func _ready() -> void:
	# Si l'objet est trop grand (bug ou mauvais scale), on le supprime immédiatement
	if abs(scale.x) > max_allowed_scale or abs(scale.y) > max_allowed_scale or abs(scale.z) > max_allowed_scale:
		print("⚠️ Squelette trop grand, suppression automatique.")
		queue_free()
		return

	# Optionnel : supprimer le corps après quelques secondes pour nettoyer la scène
	await get_tree().create_timer(lifetime).timeout
	queue_free()

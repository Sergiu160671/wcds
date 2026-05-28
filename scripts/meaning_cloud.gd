## MeaningCloud — облако конкретного значения слова.
## Имеет положение, вес, энтропию и скорость. Дрейфует под контекстным ветром.
class_name MeaningCloud
extends RefCounted

enum CloudType {
	ABSTRACT,   # 🔵 абстрактное
	PRACTICAL,  # 🟢 практическое
	CONFLICT,   # 🔴 конфликтное
	METAPHOR,   # 🟣 метафорическое
	TECHNICAL,  # 🟡 техническое
	NEUTRAL     # ⚪ нейтральное
}

var label: String
var position: Vector2
var initial_position: Vector2
var weight: float
var entropy: float
var velocity: Vector2
var cloud_type: CloudType
var trail: Array[Vector2] = []

const MAX_TRAIL_LENGTH := 60


func _init(
	cloud_label: String,
	cloud_weight: float,
	cloud_entropy: float,
	pos: Vector2,
	meaning_type: String = "neutral"
) -> void:
	label = cloud_label
	position = pos
	initial_position = pos
	weight = cloud_weight
	entropy = cloud_entropy
	velocity = Vector2.ZERO
	cloud_type = _parse_type(meaning_type)


func _parse_type(type_str: String) -> CloudType:
	match type_str.to_lower():
		"abstract":   return CloudType.ABSTRACT
		"practical":  return CloudType.PRACTICAL
		"conflict":   return CloudType.CONFLICT
		"metaphor":   return CloudType.METAPHOR
		"technical":  return CloudType.TECHNICAL
		_:            return CloudType.NEUTRAL


func apply_force(force: Vector2) -> void:
	velocity += force
	position += velocity
	# Damping
	velocity *= 0.95
	_apply_boundary_collision()
	_trail_update()


func _apply_boundary_collision() -> void:
	## Отскок облаков от краёв экрана.
	var viewport_size := Vector2(1600, 1140)  # Размер viewport из project.godot
	var margin := 50.0  # Отступ от края
	
	# Левая граница
	if position.x < margin:
		position.x = margin
		velocity.x = abs(velocity.x) * 0.8  # Отскок вправо с затуханием
	
	# Правая граница
	if position.x > viewport_size.x - margin:
		position.x = viewport_size.x - margin
		velocity.x = -abs(velocity.x) * 0.8  # Отскок влево с затуханием
	
	# Верхняя граница
	if position.y < margin:
		position.y = margin
		velocity.y = abs(velocity.y) * 0.8  # Отскок вниз
	
	# Нижняя граница
	if position.y > viewport_size.y - margin:
		position.y = viewport_size.y - margin
		velocity.y = -abs(velocity.y) * 0.8  # Отскок вверх


func _trail_update() -> void:
	trail.append(position)
	while trail.size() > MAX_TRAIL_LENGTH:
		trail.pop_front()


func drift_distance() -> float:
	return position.distance_to(initial_position)


func stability() -> float:
	return weight * (1.0 - entropy)
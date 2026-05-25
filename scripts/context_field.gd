## ContextField — контекстный ветер.
## Автозагружаемый синглтон, управляющий направлением и силой контекстного поля,
## которое воздействует на смысловые облака.
extends Node

## Направление контекстного смещения
var direction: Vector2 = Vector2.RIGHT
## Сила ветра (0.0 — 1.0)
var strength: float = 0.5
## Ключевые слова, которые усиливает текущий контекст
var bias_keywords: Array[String] = []


func configure(dir: Vector2, str_val: float, keywords: Array[String]) -> void:
	direction = dir.normalized()
	strength = clampf(str_val, 0.0, 1.0)
	bias_keywords = keywords.duplicate()
	print("[ContextField] Wind set → dir=%s strength=%.2f bias=%s" % [direction, strength, bias_keywords])


func force_for_cloud(cloud: MeaningCloud) -> Vector2:
	if bias_keywords.is_empty():
		return direction * strength * 0.5

	for keyword in bias_keywords:
		if keyword.to_lower() in cloud.label.to_lower():
			return direction * strength

	return direction * strength * 0.1


func update() -> void:
	# Placeholder for animated wind — could oscillate direction, add turbulence, etc.
	pass
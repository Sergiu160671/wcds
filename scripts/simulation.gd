## Simulation — ядро симуляции.
## Управляет всеми WordNode.
## Ведёт цикл обновления, детекцию доминантного смысла
## и «осадков смысла».
extends Node

signal word_added(word: WordNode)
signal word_removed(text: String)

var words: Array[WordNode] = []
var dictionary: SemanticDictionary

const WEIGHT_THRESHOLD: float = 0.85
const ENTROPY_THRESHOLD: float = 0.2
const WEIGHT_DECAY: float = 0.995
const WEIGHT_GROWTH: float = 0.01


func setup(dict: SemanticDictionary) -> void:
	dictionary = dict


func start() -> void:
	print("[Simulation] Logic engine started.")


func _get_spawn_rect() -> Rect2:
	var viewport_size := Vector2(1920, 1080)
	if is_inside_tree() and get_viewport():
		viewport_size = get_viewport().get_visible_rect().size

	var left_margin: float = 360.0
	var top_margin: float = 100.0
	var right_margin: float = 120.0
	var bottom_margin: float = 100.0
	var width: float = max(viewport_size.x - left_margin - right_margin, 100.0)
	var height: float = max(viewport_size.y - top_margin - bottom_margin, 100.0)
	return Rect2(Vector2(left_margin, top_margin), Vector2(width, height))


func add_word(text: String) -> WordNode:
	var spawn_rect := _get_spawn_rect()
	var center := Vector2(
		randf_range(spawn_rect.position.x, spawn_rect.position.x + spawn_rect.size.x),
		randf_range(spawn_rect.position.y, spawn_rect.position.y + spawn_rect.size.y)
	)
	var node := WordNode.new(text, center)

	var meanings: Array = dictionary.get_meanings(text)

	if meanings.is_empty():
		# Fallback: create a single neutral cloud if no dictionary entry
		node.add_cloud(
			text,
			0.5,
			0.8,
			center + Vector2(randf_range(-30, 30), randf_range(-30, 30)),
			"neutral"
		)
	else:
		for entry in meanings:
			var offset := Vector2(randf_range(-80, 80), randf_range(-80, 80))
			node.add_cloud(
				entry["label"],
				entry["weight"],
				entry["entropy"],
				center + offset,
				entry.get("type", "neutral")
			)

	words.append(node)
	word_added.emit(node)
	return node


func remove_word(text: String) -> void:
	words = words.filter(func(w: WordNode): return w.text != text)
	word_removed.emit(text)


func get_word(text: String) -> WordNode:
	for w in words:
		if w.text == text:
			return w
	return null


func step(ctx: ContextField) -> void:
	for word in words:
		for cloud in word.meaning_clusters:
			_apply_context_force(cloud, ctx)
			_update_weight_and_entropy(cloud, ctx)
			_update_position(cloud)
		_detect_precipitation(word)


func _apply_context_force(cloud: MeaningCloud, ctx: ContextField) -> void:
	var force := ctx.force_for_cloud(cloud)
	cloud.apply_force(force)


func _update_weight_and_entropy(cloud: MeaningCloud, ctx: ContextField) -> void:
	for keyword in ctx.bias_keywords:
		if keyword.to_lower() in cloud.label.to_lower():
			cloud.weight = minf(cloud.weight + ctx.strength * WEIGHT_GROWTH, 1.0)
			cloud.entropy = maxf(cloud.entropy - ctx.strength * 0.005, 0.05)
			return

	# Decay for unmatched clouds
	cloud.weight = maxf(cloud.weight * WEIGHT_DECAY, 0.01)
	cloud.entropy = minf(cloud.entropy + 0.001, 0.99)


func _update_position(_cloud: MeaningCloud) -> void:
	# Position is updated inside apply_force → apply_force.
	# Additional drift logic can be added here (e.g. attraction to word center).
	pass


func _detect_precipitation(word: WordNode) -> void:
	var dom := word.dominant_cloud()
	if dom == null:
		return

	if dom.weight > WEIGHT_THRESHOLD and dom.entropy < ENTROPY_THRESHOLD:
		print(
			"[Precipitation] %-10s → \"%s\" (weight=%.2f entropy=%.2f)" % [
				word.text,
				dom.label,
				dom.weight,
				dom.entropy
			]
		)


func render() -> void:
	# Rendering is driven by individual scene nodes (WordNode.tscn, MeaningCloud.tscn).
	# This method is a hook for global debug overlays / system metrics.
	pass


func system_metrics() -> Dictionary:
	if words.is_empty():
		return {}

	var total_entropy := 0.0
	var total_clouds := 0

	for word in words:
		total_entropy += word.system_entropy()
		total_clouds += word.meaning_clusters.size()

	return {
		"word_count": words.size(),
		"cloud_count": total_clouds,
		"system_entropy": total_entropy / float(words.size()),
	}

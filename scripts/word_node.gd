## WordNode — ядро слова в семантическом пространстве.
## Каждое слово порождает набор MeaningCloud'ов, которые дрейфуют
## под воздействием контекстного поля.
class_name WordNode
extends RefCounted

var text: String
var position: Vector2
var mass: float
var uncertainty: float
var meaning_clusters: Array[MeaningCloud] = []


func _init(word_text: String, pos: Vector2) -> void:
	text = word_text
	position = pos
	mass = 1.0
	uncertainty = 0.5
	meaning_clusters = []


func dominant_cloud() -> MeaningCloud:
	if meaning_clusters.is_empty():
		return null

	var best: MeaningCloud = meaning_clusters[0]
	var best_score: float = 0.0

	for cloud in meaning_clusters:
		var score := cloud.weight * (1.0 - cloud.entropy)
		if score > best_score:
			best_score = score
			best = cloud

	return best


func system_entropy() -> float:
	if meaning_clusters.is_empty():
		return 0.0

	var total := 0.0
	for cloud in meaning_clusters:
		total += cloud.entropy
	return total / float(meaning_clusters.size())


func add_cloud(label: String, weight: float, entropy: float, pos: Vector2, meaning_type: String = "neutral") -> void:
	var cloud := MeaningCloud.new(label, weight, entropy, pos, meaning_type)
	meaning_clusters.append(cloud)
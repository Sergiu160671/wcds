extends Node

## SOS Semantic Cloud MVP — Main entry point.
## Orchestrates the simulation loop: reads input, updates context,
## advances word clouds, detects dominant meanings, and drives rendering.

@onready var simulation := Simulation
@onready var dictionary := SemanticDictionary
@onready var context := ContextField

var word_scene := preload("res://scenes/WordNode.tscn")
var word_views: Dictionary = {}


func _ready() -> void:
	simulation.setup(dictionary)
	simulation.word_added.connect(_on_word_added)
	simulation.word_removed.connect(_on_word_removed)
	simulation.start()
	print("[SOS] Semantic Cloud MVP v0.1 started.")


func _on_word_added(word: WordNode) -> void:
	var view := word_scene.instantiate()
	add_child(view)
	view.setup(word)
	word_views[word.text] = view


func _on_word_removed(text: String) -> void:
	if word_views.has(text):
		word_views[text].queue_free()
		word_views.erase(text)


func _process(_delta: float) -> void:
	context.update()
	simulation.step(context)
	simulation.render()

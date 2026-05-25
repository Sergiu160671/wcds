extends Node

## SOS Semantic Cloud MVP — Main entry point.
## Orchestrates the simulation loop: reads input, updates context,
## advances word clouds, detects dominant meanings, and drives rendering.

@onready var simulation := Simulation
@onready var dictionary := SemanticDictionary
@onready var context := ContextField

var running: bool = true


func _ready() -> void:
	simulation.setup(dictionary)
	simulation.start()
	print("[SOS] Semantic Cloud MVP v0.1 started.")


func _process(_delta: float) -> void:
	if not running:
		return

	context.update()
	simulation.step(context)
	simulation.render()
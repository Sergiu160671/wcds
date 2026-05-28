extends Node2D

var model: WordNode
var cloud_scene := preload("res://scenes/MeaningCloud.tscn")
var cloud_views: Dictionary = {}

@onready var label: Label = $Label

func setup(m: WordNode) -> void:
	model = m
	label.text = model.text
	for cloud in model.meaning_clusters:
		_add_cloud_view(cloud)

func _add_cloud_view(cloud_model: MeaningCloud) -> void:
	var view := cloud_scene.instantiate()
	add_child(view)
	view.setup(cloud_model)
	cloud_views[cloud_model] = view

func _process(_delta: float) -> void:
	if model:
		# Sync position if needed, though clouds have their own positions
		pass

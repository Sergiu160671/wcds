extends Node2D

var model: MeaningCloud

@onready var sprite: Sprite2D = $Sprite2D

func setup(m: MeaningCloud) -> void:
	model = m
	global_position = model.position
	_update_visuals()

func _process(_delta: float) -> void:
	if model:
		global_position = model.position
		_update_visuals()

func _update_visuals() -> void:
	if not sprite: return
	var mat := sprite.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("weight", model.weight)
		mat.set_shader_parameter("entropy", model.entropy)
		var color := Color.WHITE
		match model.cloud_type:
			MeaningCloud.CloudType.ABSTRACT: color = Color.CORNFLOWER_BLUE
			MeaningCloud.CloudType.PRACTICAL: color = Color.FOREST_GREEN
			MeaningCloud.CloudType.CONFLICT: color = Color.INDIAN_RED
			MeaningCloud.CloudType.METAPHOR: color = Color.MEDIUM_PURPLE
			MeaningCloud.CloudType.TECHNICAL: color = Color.GOLDENROD
		mat.set_shader_parameter("cloud_color", color)

extends Camera3D
## ¾ follow camera — behind / above the player.

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0.0, 8.0, 10.0)
@export var look_offset: Vector3 = Vector3(0.0, 1.0, 0.0)
@export var follow_speed: float = 6.0

var _target: Node3D

func _ready() -> void:
	if target_path:
		_target = get_node_or_null(target_path)

func _process(delta: float) -> void:
	if _target == null:
		return
	var desired := _target.global_position + offset
	global_position = global_position.lerp(desired, clampf(follow_speed * delta, 0.0, 1.0))
	look_at(_target.global_position + look_offset, Vector3.UP)

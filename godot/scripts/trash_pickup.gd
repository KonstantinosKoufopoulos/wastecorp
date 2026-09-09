extends Area3D
## Placeholder trash pickup. Swap MeshInstance3D for Alex 3D .glb later.
## Groups: trash
## trash_type: "plastic" | "metal" | "paper"

@export_enum("plastic", "metal", "paper") var trash_type: String = "plastic"
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	add_to_group("trash")
	monitoring = true
	monitorable = true
	_apply_color()

func _apply_color() -> void:
	if mesh == null:
		return
	var mat := StandardMaterial3D.new()
	match trash_type:
		"plastic":
			mat.albedo_color = Color(0.25, 0.5, 1.0)
		"metal":
			mat.albedo_color = Color(0.65, 0.65, 0.7)
		"paper":
			mat.albedo_color = Color(0.6, 0.4, 0.2)
	mesh.material_override = mat

func pick_up() -> String:
	var t := trash_type
	queue_free()
	return t

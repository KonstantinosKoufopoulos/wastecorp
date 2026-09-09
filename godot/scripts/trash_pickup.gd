extends Area3D
## Trash pickup. Visual: Alex 3D trash_item.glb (Area3D collision kept for gameplay).
## Groups: trash
## trash_type: "plastic" | "metal" | "paper"

@export_enum("plastic", "metal", "paper") var trash_type: String = "plastic"
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var trash_model: Node3D = get_node_or_null("TrashModel")

func _ready() -> void:
	add_to_group("trash")
	monitoring = true
	monitorable = true
	if mesh:
		mesh.visible = false
	_apply_color()

func _apply_color() -> void:
	var mat := StandardMaterial3D.new()
	match trash_type:
		"plastic":
			mat.albedo_color = Color(0.25, 0.5, 1.0)
		"metal":
			mat.albedo_color = Color(0.65, 0.65, 0.7)
		"paper":
			mat.albedo_color = Color(0.6, 0.4, 0.2)
		_:
			mat.albedo_color = Color.WHITE
	# Prefer tinting GLB meshes; fall back to placeholder
	var targets: Array[MeshInstance3D] = []
	if trash_model:
		for n in trash_model.find_children("*", "MeshInstance3D", true, false):
			targets.append(n as MeshInstance3D)
	elif mesh:
		targets.append(mesh)
	for mi in targets:
		mi.material_override = mat

func pick_up() -> String:
	var t := trash_type
	queue_free()
	return t

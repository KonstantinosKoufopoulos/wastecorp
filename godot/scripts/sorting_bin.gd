extends Area3D
## Sorting bin Area3D — plastic blue / metal grey / paper brown.
## Groups: bin
## Accepts matching trash_type via proximity + interact.
## Visual: Alex 3D bin_*.glb under BinModel (Area3D collision kept for gameplay).

@export_enum("plastic", "metal", "paper") var accepts: String = "plastic"
@export var unlocked: bool = true
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D
@onready var bin_model: Node3D = get_node_or_null("BinModel")

signal deposited(trash_type: String)

func _ready() -> void:
	add_to_group("bin")
	monitoring = true
	monitorable = true
	if mesh:
		mesh.visible = false
	_apply_look()
	_refresh_lock()

func _apply_look() -> void:
	# Placeholder mesh only — GLB already has correct materials
	if mesh and mesh.visible:
		var mat := StandardMaterial3D.new()
		match accepts:
			"plastic":
				mat.albedo_color = Color(0.15, 0.35, 0.9)
			"metal":
				mat.albedo_color = Color(0.5, 0.5, 0.55)
			"paper":
				mat.albedo_color = Color(0.5, 0.3, 0.15)
		mesh.material_override = mat
	if label:
		label.text = accepts.capitalize()

func set_unlocked(v: bool) -> void:
	unlocked = v
	_refresh_lock()

func _mesh_targets() -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	if mesh and mesh.visible:
		out.append(mesh)
	if bin_model:
		for n in bin_model.find_children("*", "MeshInstance3D", true, false):
			out.append(n as MeshInstance3D)
	return out

func _refresh_lock() -> void:
	visible = true
	var alpha := 0.0 if unlocked else 0.55
	for mi in _mesh_targets():
		mi.transparency = alpha
	if label and not unlocked:
		label.text = accepts.capitalize() + " (locked)"
	elif label:
		label.text = accepts.capitalize()

func try_deposit(trash_type: String) -> bool:
	if not unlocked:
		return false
	if trash_type != accepts:
		return false
	deposited.emit(trash_type)
	return true

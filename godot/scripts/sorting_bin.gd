extends Area3D
## Sorting bin Area3D — plastic blue / metal grey / paper brown.
## Groups: bin
## Accepts matching trash_type via proximity + interact.

@export_enum("plastic", "metal", "paper") var accepts: String = "plastic"
@export var unlocked: bool = true
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D

signal deposited(trash_type: String)

func _ready() -> void:
	add_to_group("bin")
	monitoring = true
	monitorable = true
	_apply_look()
	_refresh_lock()

func _apply_look() -> void:
	if mesh:
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

func _refresh_lock() -> void:
	visible = true
	if mesh:
		mesh.transparency = 0.0 if unlocked else 0.55
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

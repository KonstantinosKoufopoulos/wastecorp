extends Area3D
## Plastic press zone — process bale for cash (S3).
## Groups: press

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D
var active: bool = false

func _ready() -> void:
	add_to_group("press")
	monitoring = true
	monitorable = true
	set_active(false)
	TutorialState.press_unlocked.connect(_on_press_unlocked)

func _on_press_unlocked() -> void:
	set_active(true)

func set_active(v: bool) -> void:
	active = v
	if mesh:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.2, 0.7, 0.35) if active else Color(0.3, 0.3, 0.3)
		mesh.material_override = mat
	if label:
		label.text = "PRESS" if active else "PRESS (locked)"

func try_process() -> bool:
	if not active:
		return false
	if TutorialState.step != TutorialState.Step.S3_PRESS:
		return false
	# One-shot for tutorial
	active = false
	if label:
		label.text = "PRESS ✓"
	return true

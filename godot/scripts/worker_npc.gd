extends CharacterBody3D
## Placeholder hired worker NPC (S4). Capsule mesh until Alex 3D .glb.

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D
var hired: bool = false

func _ready() -> void:
	visible = false
	set_physics_process(false)
	TutorialState.worker_spawn_requested.connect(spawn_hired)

func spawn_hired() -> void:
	hired = true
	visible = true
	global_position = Vector3(4.0, 0.0, -2.0)
	if label:
		label.text = "Worker"
	if mesh:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.85, 0.65, 0.25)
		mesh.material_override = mat

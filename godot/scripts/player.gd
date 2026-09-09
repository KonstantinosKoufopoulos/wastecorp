extends CharacterBody3D
## Player: WASD / virtual-stick placeholders, pick, carry, deposit.
## Interact: E / Space / HUD tap.
## Visual: Alex 3D player.glb (in-place locomotion — move this CharacterBody3D in code).

signal carried_changed(trash_type: String)

const SPEED := 5.5
const JUMP_VELOCITY := 0.0  # grounded yard — no jump needed

@export var camera_path: NodePath
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var carry_anchor: Node3D = $CarryAnchor
@onready var interact_area: Area3D = $InteractArea
@onready var player_model: Node3D = $PlayerModel
@onready var anim: AnimationPlayer = (
	$PlayerModel/AnimationPlayer if has_node("PlayerModel/AnimationPlayer") else $AnimationPlayer
)

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var carried_type: String = ""  # "", "plastic", "metal", "paper"
var _nearby_trash: Array[Node] = []
var _nearby_bin: Node = null
var _nearby_press: Node = null
var _virtual_stick: Vector2 = Vector2.ZERO  # HUD / touch placeholder

func _ready() -> void:
	if mesh:
		mesh.visible = false
	interact_area.body_entered.connect(_on_interact_body_entered)
	interact_area.body_exited.connect(_on_interact_body_exited)
	interact_area.area_entered.connect(_on_interact_area_entered)
	interact_area.area_exited.connect(_on_interact_area_exited)
	_ensure_idle_anim()
	_play_anim("idle")

func _ensure_idle_anim() -> void:
	## Prefer real GLB clips (idle/walk/carry_idle/deposit). Fallback fake library if missing.
	if anim == null:
		return
	if anim.has_animation("idle") and anim.has_animation("walk"):
		return
	if anim.has_animation("player/idle") and anim.has_animation("player/walk"):
		return
	var lib := AnimationLibrary.new()
	var idle := Animation.new()
	idle.length = 1.0
	lib.add_animation("idle", idle)
	var walk := Animation.new()
	walk.length = 0.6
	lib.add_animation("walk", walk)
	var carry_idle := Animation.new()
	carry_idle.length = 1.0
	lib.add_animation("carry_idle", carry_idle)
	var deposit := Animation.new()
	deposit.length = 0.8
	lib.add_animation("deposit", deposit)
	if anim.has_animation_library("player"):
		anim.remove_animation_library("player")
	anim.add_animation_library("player", lib)

func _resolve_anim_name(clip: String) -> String:
	if anim == null:
		return ""
	if anim.has_animation(clip):
		return clip
	var prefixed := "player/" + clip
	if anim.has_animation(prefixed):
		return prefixed
	return ""

func set_virtual_stick(v: Vector2) -> void:
	_virtual_stick = v.limit_length(1.0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = 0.0

	if not TutorialState.can_player_move() and TutorialState.step == TutorialState.Step.S0_START:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if _virtual_stick.length() > 0.1:
		input_dir = _virtual_stick

	var direction := Vector3(input_dir.x, 0.0, input_dir.y).normalized()
	if direction.length() > 0.01:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# Face move direction
		var look_at_pos := global_position + direction
		look_at_pos.y = global_position.y
		if look_at_pos.distance_to(global_position) > 0.01:
			look_at(look_at_pos, Vector3.UP)
		_play_anim("walk")
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)
		if carried_type != "":
			_play_anim("carry_idle")
		else:
			_play_anim("idle")

	move_and_slide()

func _play_anim(clip: String) -> void:
	if anim == null:
		return
	var resolved := _resolve_anim_name(clip)
	if resolved == "":
		return
	if anim.current_animation == resolved:
		return
	# Don't interrupt a one-shot deposit mid-play
	if anim.current_animation == _resolve_anim_name("deposit") and anim.is_playing():
		return
	anim.play(resolved)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()

func try_interact() -> void:
	if not TutorialState.can_interact():
		return
	# Deposit if carrying and near matching bin
	if carried_type != "" and _nearby_bin != null:
		if _nearby_bin.has_method("try_deposit"):
			var t := carried_type
			if _nearby_bin.try_deposit(t):
				_play_anim("deposit")
				_clear_carry()
				TutorialState.on_trash_deposited(t)
				return
	# Press zone
	if _nearby_press != null and _nearby_press.has_method("try_process"):
		if _nearby_press.try_process():
			TutorialState.on_press_processed()
			return
	# Pick nearest trash
	if carried_type == "" and not _nearby_trash.is_empty():
		var trash: Node = _nearby_trash[0]
		if trash and is_instance_valid(trash) and trash.has_method("pick_up"):
			carried_type = trash.pick_up()
			_attach_carry_mesh(carried_type)
			carried_changed.emit(carried_type)
			TutorialState.on_trash_picked()
			_play_anim("carry_idle")

func _attach_carry_mesh(trash_type: String) -> void:
	for c in carry_anchor.get_children():
		c.queue_free()
	var packed: PackedScene = load("res://assets/models/trash_item.glb") as PackedScene
	if packed:
		var inst: Node = packed.instantiate()
		carry_anchor.add_child(inst)
		# Tint mesh instances by trash type for readability
		for mi in inst.find_children("*", "MeshInstance3D", true, false):
			var mat := StandardMaterial3D.new()
			mat.albedo_color = _color_for(trash_type)
			mi.material_override = mat
		return
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.35, 0.35, 0.35)
	mi.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _color_for(trash_type)
	mi.material_override = mat
	carry_anchor.add_child(mi)

func _clear_carry() -> void:
	carried_type = ""
	for c in carry_anchor.get_children():
		c.queue_free()
	carried_changed.emit("")

func _color_for(t: String) -> Color:
	match t:
		"plastic":
			return Color(0.2, 0.45, 0.95)
		"metal":
			return Color(0.55, 0.55, 0.6)
		"paper":
			return Color(0.55, 0.35, 0.18)
		_:
			return Color.WHITE

func _on_interact_area_entered(area: Area3D) -> void:
	if area.is_in_group("trash"):
		_nearby_trash.append(area)
	elif area.is_in_group("bin"):
		_nearby_bin = area
	elif area.is_in_group("press"):
		_nearby_press = area

func _on_interact_area_exited(area: Area3D) -> void:
	if area.is_in_group("trash"):
		_nearby_trash.erase(area)
	elif area.is_in_group("bin") and _nearby_bin == area:
		_nearby_bin = null
	elif area.is_in_group("press") and _nearby_press == area:
		_nearby_press = null

func _on_interact_body_entered(_body: Node3D) -> void:
	pass

func _on_interact_body_exited(_body: Node3D) -> void:
	pass

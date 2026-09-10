extends Control
## On-screen virtual stick for mobile / no-WASD play.

@export var player_path: NodePath
@export var max_radius: float = 56.0

var _player: Node
var _dragging := false
var _origin := Vector2.ZERO
@onready var _knob: Control = $Knob

func _ready() -> void:
	if player_path:
		_player = get_node_or_null(player_path)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_recenter_knob()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_dragging = true
			_origin = size * 0.5
			_update_stick(st.position)
		else:
			_release()
	elif event is InputEventScreenDrag and _dragging:
		_update_stick((event as InputEventScreenDrag).position)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_dragging = true
				_origin = size * 0.5
				_update_stick(mb.position)
			else:
				_release()
	elif event is InputEventMouseMotion and _dragging:
		_update_stick((event as InputEventMouseMotion).position)

func _update_stick(pos: Vector2) -> void:
	var delta := pos - _origin
	if delta.length() > max_radius:
		delta = delta.limit_length(max_radius)
	_knob.position = _origin + delta - _knob.size * 0.5
	var v := delta / max_radius
	# Godot input vector: x right, y forward (negative screen-y is forward)
	var stick := Vector2(v.x, -v.y)
	if _player and _player.has_method("set_virtual_stick"):
		_player.set_virtual_stick(stick)

func _release() -> void:
	_dragging = false
	_recenter_knob()
	if _player and _player.has_method("set_virtual_stick"):
		_player.set_virtual_stick(Vector2.ZERO)

func _recenter_knob() -> void:
	_origin = size * 0.5
	_knob.position = _origin - _knob.size * 0.5

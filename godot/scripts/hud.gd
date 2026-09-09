extends Control
## Control HUD: cash, step hint, Start / Accept / Hire / Upgrade buttons.
## Virtual stick placeholders (touch) wired to player.

@onready var cash_label: Label = $TopBar/CashLabel
@onready var hint_label: Label = $HintPanel/HintLabel
@onready var start_btn: Button = $CenterButtons/StartButton
@onready var accept_btn: Button = $CenterButtons/AcceptButton
@onready var hire_btn: Button = $CenterButtons/HireButton
@onready var upgrade_row: HBoxContainer = $UpgradeRow
@onready var truck_btn: Button = $UpgradeRow/TruckButton
@onready var yard_btn: Button = $UpgradeRow/YardButton
@onready var interact_btn: Button = $TouchControls/InteractButton

@export var player_path: NodePath
var _player: Node

func _ready() -> void:
	if player_path:
		_player = get_node_or_null(player_path)
	start_btn.pressed.connect(_on_start)
	accept_btn.pressed.connect(_on_accept)
	hire_btn.pressed.connect(_on_hire)
	truck_btn.pressed.connect(_on_truck)
	yard_btn.pressed.connect(_on_yard)
	interact_btn.pressed.connect(_on_interact)

	TutorialState.hint_changed.connect(_on_hint)
	TutorialState.cash_changed.connect(_on_cash)
	TutorialState.show_start.connect(_on_show_start)
	TutorialState.show_accept.connect(_on_show_accept)
	TutorialState.show_upgrade_choice.connect(_on_show_upgrade)
	TutorialState.step_changed.connect(_on_step)

	_on_hint(TutorialState.get_hint())
	_on_cash(SaveService.cash)
	_on_show_start(TutorialState.step == TutorialState.Step.S0_START)
	_on_show_accept(false)
	_on_show_upgrade(false)
	hire_btn.visible = false

func _on_hint(text: String) -> void:
	hint_label.text = text

func _on_cash(amount: int) -> void:
	cash_label.text = "$%d" % amount

func _on_show_start(v: bool) -> void:
	start_btn.visible = v

func _on_show_accept(v: bool) -> void:
	accept_btn.visible = v

func _on_show_upgrade(v: bool) -> void:
	upgrade_row.visible = v

func _on_step(step: int) -> void:
	hire_btn.visible = (step == TutorialState.Step.S4_HIRE)

func _on_start() -> void:
	TutorialState.on_start_pressed()

func _on_accept() -> void:
	TutorialState.on_accept_contract()

func _on_hire() -> void:
	TutorialState.on_hire_pressed()

func _on_truck() -> void:
	TutorialState.on_upgrade_chosen("truck")

func _on_yard() -> void:
	TutorialState.on_upgrade_chosen("yard")

func _on_interact() -> void:
	if _player and _player.has_method("try_interact"):
		_player.try_interact()

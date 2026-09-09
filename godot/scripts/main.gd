extends Node3D
## Main yard scene controller — wires bins unlock on S5.

@onready var bin_plastic: Area3D = $Yard/Bins/BinPlastic
@onready var bin_metal: Area3D = $Yard/Bins/BinMetal
@onready var bin_paper: Area3D = $Yard/Bins/BinPaper
@onready var truck: MeshInstance3D = $Yard/ContractTruck

func _ready() -> void:
	TutorialState.lines_unlocked.connect(_on_lines_unlocked)
	TutorialState.contract_started.connect(_on_contract)
	# Initial lock state for metal/paper
	if bin_metal and bin_metal.has_method("set_unlocked"):
		bin_metal.set_unlocked(SaveService.metal_unlocked)
	if bin_paper and bin_paper.has_method("set_unlocked"):
		bin_paper.set_unlocked(SaveService.paper_unlocked)
	if truck:
		truck.visible = false

func _on_lines_unlocked(metal: bool, paper: bool) -> void:
	if bin_metal and bin_metal.has_method("set_unlocked"):
		bin_metal.set_unlocked(metal)
	if bin_paper and bin_paper.has_method("set_unlocked"):
		bin_paper.set_unlocked(paper)

func _on_contract() -> void:
	if truck:
		truck.visible = true

extends Node
## Persistence via ConfigFile (+ JSON export helper).
## Autoload: SaveService

const SAVE_PATH := "user://waste_corp_save.cfg"
const JSON_PATH := "user://waste_corp_save.json"

var cash: int = 0
var tutorial_step: int = 0
var plastic_unlocked: bool = true
var metal_unlocked: bool = false
var paper_unlocked: bool = false
var worker_hired: bool = false
var contract_done: bool = false
var upgrade_choice: String = ""  # "truck" | "yard" | ""

func _ready() -> void:
	load_game()

func load_game() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return
	cash = int(cfg.get_value("player", "cash", 0))
	tutorial_step = int(cfg.get_value("tutorial", "step", 0))
	plastic_unlocked = bool(cfg.get_value("lines", "plastic", true))
	metal_unlocked = bool(cfg.get_value("lines", "metal", false))
	paper_unlocked = bool(cfg.get_value("lines", "paper", false))
	worker_hired = bool(cfg.get_value("yard", "worker_hired", false))
	contract_done = bool(cfg.get_value("contract", "done", false))
	upgrade_choice = str(cfg.get_value("upgrade", "choice", ""))

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("player", "cash", cash)
	cfg.set_value("tutorial", "step", tutorial_step)
	cfg.set_value("lines", "plastic", plastic_unlocked)
	cfg.set_value("lines", "metal", metal_unlocked)
	cfg.set_value("lines", "paper", paper_unlocked)
	cfg.set_value("yard", "worker_hired", worker_hired)
	cfg.set_value("contract", "done", contract_done)
	cfg.set_value("upgrade", "choice", upgrade_choice)
	cfg.save(SAVE_PATH)
	_export_json()

func _export_json() -> void:
	var data := {
		"cash": cash,
		"tutorial_step": tutorial_step,
		"plastic_unlocked": plastic_unlocked,
		"metal_unlocked": metal_unlocked,
		"paper_unlocked": paper_unlocked,
		"worker_hired": worker_hired,
		"contract_done": contract_done,
		"upgrade_choice": upgrade_choice,
	}
	var f := FileAccess.open(JSON_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()

func add_cash(amount: int) -> void:
	cash += amount
	save_game()

func reset_tutorial() -> void:
	cash = 0
	tutorial_step = 0
	plastic_unlocked = true
	metal_unlocked = false
	paper_unlocked = false
	worker_hired = false
	contract_done = false
	upgrade_choice = ""
	save_game()

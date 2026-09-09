extends Node
## Drives Christos 3D first-5-min flow S0–S6.
## Autoload: TutorialState
##
## S0 dirty yard + Start
## S1 walk + pick trash (E/tap)
## S2 deposit to 3 bins (proximity + tap)
## S3 plastic press zone
## S4 hire worker NPC
## S5 metal/paper unlock
## S6 contract truck + upgrade choice

signal step_changed(step: int)
signal hint_changed(text: String)
signal cash_changed(amount: int)
signal show_start(visible: bool)
signal show_accept(visible: bool)
signal show_upgrade_choice(visible: bool)
signal lines_unlocked(metal: bool, paper: bool)
signal worker_spawn_requested
signal press_unlocked
signal contract_started
signal tutorial_complete

enum Step {
	S0_START = 0,
	S1_PICK = 1,
	S2_DEPOSIT = 2,
	S3_PRESS = 3,
	S4_HIRE = 4,
	S5_LINES = 5,
	S6_CONTRACT = 6,
	DONE = 7,
}

const HINTS := {
	Step.S0_START: "Dirty yard. Tap Start to open the shift.",
	Step.S1_PICK: "Walk to trash and press E (or tap) to pick it up.",
	Step.S2_DEPOSIT: "Carry trash to the matching bin — Blue plastic / Grey metal / Brown paper.",
	Step.S3_PRESS: "Walk to the plastic press zone and process a bale (E).",
	Step.S4_HIRE: "Hire your first worker — almost all your cash.",
	Step.S5_LINES: "Metal and paper lines are opening. Keep sorting.",
	Step.S6_CONTRACT: "Accept the district contract, then choose Truck or Yard upgrade.",
	Step.DONE: "Tutorial complete. Build the company.",
}

var step: int = Step.S0_START
var picks_done: int = 0
var deposits_done: int = 0
var press_done: bool = false
const PICKS_NEEDED := 1
const DEPOSITS_NEEDED := 1
const HIRE_COST := 40
const PRESS_PAY := 50
const CONTRACT_PAY := 80

func _ready() -> void:
	step = SaveService.tutorial_step
	call_deferred("_emit_initial")

func _emit_initial() -> void:
	step_changed.emit(step)
	hint_changed.emit(HINTS.get(step, ""))
	cash_changed.emit(SaveService.cash)
	show_start.emit(step == Step.S0_START)
	show_accept.emit(step == Step.S6_CONTRACT and not SaveService.contract_done)
	show_upgrade_choice.emit(step == Step.S6_CONTRACT and SaveService.contract_done and SaveService.upgrade_choice.is_empty())
	if step >= Step.S5_LINES:
		lines_unlocked.emit(true, true)

func get_hint() -> String:
	return HINTS.get(step, "")

func advance_to(new_step: int) -> void:
	step = new_step
	SaveService.tutorial_step = step
	SaveService.save_game()
	step_changed.emit(step)
	hint_changed.emit(HINTS.get(step, ""))
	show_start.emit(step == Step.S0_START)
	show_accept.emit(false)
	show_upgrade_choice.emit(false)
	match step:
		Step.S3_PRESS:
			press_unlocked.emit()
		Step.S4_HIRE:
			pass
		Step.S5_LINES:
			SaveService.metal_unlocked = true
			SaveService.paper_unlocked = true
			SaveService.save_game()
			lines_unlocked.emit(true, true)
		Step.S6_CONTRACT:
			show_accept.emit(true)
		Step.DONE:
			tutorial_complete.emit()

func on_start_pressed() -> void:
	if step != Step.S0_START:
		return
	advance_to(Step.S1_PICK)

func on_trash_picked() -> void:
	if step != Step.S1_PICK:
		return
	picks_done += 1
	if picks_done >= PICKS_NEEDED:
		advance_to(Step.S2_DEPOSIT)

func on_trash_deposited(trash_type: String) -> void:
	if step != Step.S2_DEPOSIT:
		return
	deposits_done += 1
	# Small cash for correct deposit
	SaveService.add_cash(10)
	cash_changed.emit(SaveService.cash)
	if deposits_done >= DEPOSITS_NEEDED:
		advance_to(Step.S3_PRESS)

func on_press_processed() -> void:
	if step != Step.S3_PRESS:
		return
	press_done = true
	SaveService.add_cash(PRESS_PAY)
	cash_changed.emit(SaveService.cash)
	advance_to(Step.S4_HIRE)

func on_hire_pressed() -> void:
	if step != Step.S4_HIRE:
		return
	if SaveService.cash < HIRE_COST:
		hint_changed.emit("Need $%d to hire. Process more plastic." % HIRE_COST)
		return
	SaveService.add_cash(-HIRE_COST)
	SaveService.worker_hired = true
	SaveService.save_game()
	cash_changed.emit(SaveService.cash)
	worker_spawn_requested.emit()
	advance_to(Step.S5_LINES)
	# Auto-advance after a beat into contract
	await get_tree().create_timer(2.0).timeout
	if step == Step.S5_LINES:
		advance_to(Step.S6_CONTRACT)

func on_accept_contract() -> void:
	if step != Step.S6_CONTRACT:
		return
	contract_started.emit()
	SaveService.contract_done = true
	SaveService.add_cash(CONTRACT_PAY)
	SaveService.save_game()
	cash_changed.emit(SaveService.cash)
	show_accept.emit(false)
	show_upgrade_choice.emit(true)
	hint_changed.emit("Contract complete! Choose Truck or Yard upgrade.")

func on_upgrade_chosen(choice: String) -> void:
	if step != Step.S6_CONTRACT:
		return
	SaveService.upgrade_choice = choice
	SaveService.save_game()
	show_upgrade_choice.emit(false)
	advance_to(Step.DONE)

func can_player_move() -> bool:
	return step != Step.S0_START

func can_interact() -> bool:
	return step >= Step.S1_PICK and step < Step.DONE

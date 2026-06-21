extends Node
class_name Resources

@export var god_mode: bool = false

@export_group("Maximum Values")
@export var max_health: float = 100.0
@export var max_adrenaline: float = 70.0
@export var max_magic: float = 50.0
@export var max_poise: float = 70.0

var current_health: float = 100.0:
	set(value):
		current_health = clampf(value, 0.0, max_health)
		update_health.emit(current_health)

var current_adrenaline: float = 70.0:
	set(value):
		current_adrenaline = clampf(value, 0.0, max_adrenaline)
		update_adrenaline.emit(current_adrenaline)

var current_magic: float = 50.0:
	set(value):
		current_magic = clampf(value, 0.0, max_magic)
		update_magic.emit(current_magic)

var current_poise: float = 70.0:
	set(value):
		current_poise = clampf(value, 0.0, max_poise)
		update_poise.emit(current_poise)

@export_group("Regeneration Rates")
@export var health_regen_rate: float = 0.0
@export var adrenaline_regen_rate: float = 1.0
@export var magic_regen_rate: float = 0.7
@export var poise_regen_rate: float = 10.0


signal update_health(current: float)
signal update_adrenaline(current: float)
signal update_magic(current: float)
signal update_poise(current: float)

signal set_health(current: float, maximum: float)
signal set_adrenaline(current: float, maximum: float)
signal set_magic(current: float, maximum: float)
signal set_poise(current: float, maximum: float)


func emit_set_signals() -> void:
	set_health.emit(current_health, max_health)
	set_adrenaline.emit(current_adrenaline, max_adrenaline)
	set_magic.emit(current_magic, max_magic)
	set_poise.emit(current_poise, max_poise)


func update_resources(
	delta: float,
	flags: int = 0b1111,
	multipliers: Array[float] = [1.0, 1.0, 1.0, 1.0]
) -> void:
	if flags & 0b0001:
		gain_health(health_regen_rate * multipliers[0] * delta)

	if flags & 0b0010:
		gain_adrenaline(adrenaline_regen_rate * multipliers[1] * delta)

	if flags & 0b0100:
		gain_magic(magic_regen_rate * multipliers[2] * delta)

	if flags & 0b1000:
		gain_poise(poise_regen_rate * multipliers[3] * delta)


func lose_health(amount: float, guarded: bool = false) -> void:
	if god_mode:
		return

	if guarded and current_health - amount <= 0:
		current_health = 1
	else:
		current_health -= amount


func lose_adrenaline(amount: float, guarded: bool = false) -> void:
	if god_mode:
		return

	if guarded and current_adrenaline - amount <= 0:
		current_adrenaline = 1
	else:
		current_adrenaline -= amount


func lose_magic(amount: float, guarded: bool = false) -> void:
	if god_mode:
		return

	if guarded and current_magic - amount <= 0:
		current_magic = 1
	else:
		current_magic -= amount


func lose_poise(amount: float, guarded: bool = false) -> void:
	if god_mode:
		return

	if guarded and current_poise - amount <= 0:
		current_poise = 1
	else:
		current_poise -= amount


func gain_health(amount: float) -> void:
	current_health += amount


func gain_adrenaline(amount: float) -> void:
	current_adrenaline += amount


func gain_magic(amount: float) -> void:
	current_magic += amount


func gain_poise(amount: float) -> void:
	current_poise += amount


func pay_resource(type: StringName, amount: float, guarded: bool = false) -> void:
	match type:
		&"health":
			lose_health(amount, guarded)

		&"adrenaline":
			lose_adrenaline(amount, guarded)

		&"magic":
			lose_magic(amount, guarded)

		&"poise":
			lose_poise(amount, guarded)


func can_be_paid(type: StringName, amount: float) -> bool:
	match type:
		&"health":
			return current_health - amount > 0

		&"adrenaline":
			return current_adrenaline - amount >= 0

		&"magic":
			return current_magic - amount >= 0

		&"poise":
			return current_poise - amount >= 0

	return false

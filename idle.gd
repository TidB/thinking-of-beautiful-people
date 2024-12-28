extends Control

signal start_main_dialogue
const DIALOGUE_TRIGGER = 10000
var triggered = false

var current_capacity = 5
#var current_capacity = 100
var current_charging_rate = 0
#var current_charge = 100
var current_charge = 1

var charge_record = 0
var backup_active = false

var counter = 0

class Item:
	var label: String
	var unlocked_after: int
	var base_cost: int

class ChargingButton:
	extends Item
	var charge_amount: int
	var charges_per_second: float
	
	func _init(unlocked_after, base_cost, charge_amount, charges_per_second, label):
		self.label = label
		self.unlocked_after = unlocked_after
		self.charge_amount = charge_amount
		self.charges_per_second = charges_per_second  # > 30 -> continous
		self.base_cost = base_cost

class CapacityButton:
	extends Item
	var capacity: int
	
	func _init(unlocked_after, base_cost, capacity, label):
		self.label = label
		self.unlocked_after = unlocked_after
		self.capacity = capacity
		self.base_cost = base_cost
	

var charging_buttons = [
	ChargingButton.new(0, 1, 1, 0.5, "Manually insert a battery"),
	ChargingButton.new(10, 10, 5, 2, "Hire someone to turn a crank"),
	ChargingButton.new(50, 150, 15, 5, "Hire a hamster"),
	ChargingButton.new(750, 1750, 70, 12, "Tap a neighbor's wire"),
	ChargingButton.new(3500, 50000, 250, 25, "Keep a pet thunderstorm"),
	ChargingButton.new(25000, 1000000, 1200, 50, "Build a Dyson Sphere (or multiple)"),
]

var capacity_buttons = [
	CapacityButton.new(0, 2, 20, "Powerbank"),
	CapacityButton.new(10, 5, 100, "Car Battery"),
	CapacityButton.new(50, 75, 1000, "Flywheel"),
	CapacityButton.new(750, 1500, 25000, "Fuel Cell"),
	CapacityButton.new(3500, 17500, 500000, "Pumped-Storage Power Plant"),
	CapacityButton.new(25000, 120000, 10000000, "Use the Earth as a Flywheel"),
]

var bought_chargers = {} # key: index of charging_buttons, value: amount bought
var bought_capacity = {}
var last_update_for_index = {}

func exp_cost_capacity(index):
	return capacity_buttons[index].base_cost * (1.5 ** bought_capacity[index])
	
func exp_cost_charge(index):
	return charging_buttons[index].base_cost * (1.5 ** bought_chargers[index])

func charge_rate():
	var rate = 0
	for index in bought_chargers:
		rate += bought_chargers[index] * charging_buttons[index].charge_amount * charging_buttons[index].charges_per_second
	return rate

# Let's assume a consumption rate of 1 J/s
func to_time(charge):
	if charge >= 3600 * 24 * 365.25:
		return "%.2f years" % (charge / (3600 * 24 * 365.25))
	if charge >= 3600 * 24:
		return "%.2f days" % (charge / (3600 * 24))
	if charge >= 3600:
		return "%.2f hours" % (charge / 3600)
	if charge >= 60:
		return "%.2f minutes" % (charge / 60)
	else:
		return "%.2f seconds" % (charge)

func _ready() -> void:
	for i in charging_buttons.size():
		bought_chargers[i] = 0
		last_update_for_index[i] = 0
	for i in capacity_buttons.size():
		bought_capacity[i] = 0
		
	generate_buttons()


func _physics_process(delta: float) -> void:
	for i in last_update_for_index.size():
		var button_data = charging_buttons[i]
		if button_data.charges_per_second > 30:
			current_charge += bought_chargers[i] * button_data.charge_amount * button_data.charges_per_second * delta
		elif last_update_for_index[i] > (1 / button_data.charges_per_second):
			last_update_for_index[i] = 0
			current_charge += button_data.charge_amount * bought_chargers[i]
		else:
			last_update_for_index[i] += delta
		
	if current_charge >= current_capacity:
		$HBoxContainer/MarginContainer3/VBoxContainer/CapacityExceeded.visible = true
	else:
		$HBoxContainer/MarginContainer3/VBoxContainer/CapacityExceeded.visible = false
	
	if backup_active:
		current_charge = max(0, current_charge - (20 * delta))
	current_charge = min(current_capacity, current_charge)
	$HBoxContainer/MarginContainer3/VBoxContainer/StoredCounter.text = "Stored Energy:\n%.2f J\nLasts for:\n%s" % [current_charge, to_time(current_charge)]
	charge_record = max(charge_record, current_charge)
	# TODO: If the record changes a lot, generate buttons again!
	
	if counter > 1:
		counter = 0
		generate_buttons()
	else:
		counter += delta
	
	if current_charge > DIALOGUE_TRIGGER and not triggered:
		triggered = true
		start_main_dialogue.emit()

func generate_buttons():
	for parent in [$HBoxContainer/MarginContainer/Charging, $HBoxContainer/MarginContainer2/Capacity]:
		for child in parent.get_children():
			if child is Label:
				continue
			
			parent.remove_child(child)
			child.queue_free()
	
	$HBoxContainer/MarginContainer/Charging/ChargingRate.text = "Charging Rate:\n" + str(charge_rate()) + " J/s"
	var i = 0
	for b in charging_buttons:
		if charge_record * 2 < b.unlocked_after:
			continue
		var button = Button.new()
		button.text = b.label + "\n(" + str(bought_chargers[i]) + "× " + str(b.charge_amount * b.charges_per_second) + " J/s; Cost: %.2f J)" % exp_cost_charge(i)
		button.pressed.connect(func(): self.buy_charger(i))
		$HBoxContainer/MarginContainer/Charging.add_child(button)
		i += 1

	i = 0
	for b in capacity_buttons:
		if charge_record * 2 < b.unlocked_after:
			continue
		var button = Button.new()
		button.text = b.label + "\n(" + str(bought_capacity[i]) + "× " + str(b.capacity) + " J; Cost: %.2f J)" % exp_cost_capacity(i)
		button.pressed.connect(func(): self.buy_capacity(i))
		$HBoxContainer/MarginContainer2/Capacity.add_child(button)
		i += 1

func buy_charger(index):
	if current_charge < exp_cost_charge(index):
		generate_buttons()
		return
	
	if index not in bought_chargers:
		bought_chargers[index] = 0
	current_charge -= exp_cost_charge(index)
	bought_chargers[index] += 1
	generate_buttons()

func buy_capacity(index):
	if current_charge < exp_cost_capacity(index):
		generate_buttons()
		return
		
	if index not in bought_capacity:
		bought_capacity[index] = 0
	current_charge -= exp_cost_capacity(index)
	bought_capacity[index] += 1
	
	current_capacity += capacity_buttons[index].capacity
	$HBoxContainer/MarginContainer2/Capacity/CapacityCounter.text = "Maximum Capacity:\n" + str(current_capacity) + " J"
	generate_buttons()

func backup_mode(active):
	if active:
		backup_active = true
		$HBoxContainer/MarginContainer3/VBoxContainer/BackupNotice.visible = true
		$Panel.add_theme_stylebox_override("panel", load("res://idle_bg_backup.tres"))
	else:
		backup_active = false
		$HBoxContainer/MarginContainer3/VBoxContainer/BackupNotice.visible = false
		$Panel.add_theme_stylebox_override("panel", load("res://idle_bg.tres"))

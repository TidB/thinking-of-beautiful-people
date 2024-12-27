extends Control

signal start_main_dialogue
const DIALOGUE_TRIGGER = 100
var triggered = false

var current_capacity = 5
var current_charging_rate = 0
var current_charge = 0

class Item:
	var label: String
	var unlocked_after: int
	var base_cost: int

class ChargingButton:
	extends Item
	var charge_amount: int
	var charges_per_second: int
	
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
	ChargingButton.new(0, 1, 1, 1, "Manually insert a battery"),
	ChargingButton.new(10, 5, 2, 3, "Hire someone to turn a crank"),
	ChargingButton.new(50, 25, 4, 6, "Hire a hamster"),
]

var capacity_buttons = [
	CapacityButton.new(0, 1, 1, "Add a powerbank"),
	CapacityButton.new(10, 5, 10, "Add a car battery"),
	CapacityButton.new(50, 25, 25, "Add a flywheel"),
]

var bought_chargers = {} # key: index of charging_buttons, value: amount bought
var bought_capacity = {}
var last_update_for_index = {}

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
		elif last_update_for_index[i] > (1 / button_data.charges_per_second):  # TODO: This assumes that we can only miss /one/ update here, so actions faster than the physics framerate wouldn't work
			last_update_for_index[i] = 0
			current_charge += button_data.charge_amount * bought_chargers[i]
		else:
			last_update_for_index[i] += delta
		
	if current_charge >= current_capacity:
		$HBoxContainer/MarginContainer3/CapacityExceeded.visible = true
	else:
		$HBoxContainer/MarginContainer3/CapacityExceeded.visible = false
	current_charge = min(current_capacity, current_charge)
	$HBoxContainer/MarginContainer3/StoredCounter.text = "%d" % (current_charge)
	
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
	
	var i = 0
	for b in charging_buttons:
		var button = Button.new()
		button.text = b.label + " (" + str(bought_chargers[i]) + " owned)\n(" + str(b.charge_amount * b.charges_per_second) + " per second)"
		button.pressed.connect(func(): self.buy_charger(i))
		$HBoxContainer/MarginContainer/Charging.add_child(button)
		i += 1

	i = 0
	for b in capacity_buttons:
		var button = Button.new()
		button.text = b.label + " (" + str(bought_capacity[i]) + " owned)"
		button.pressed.connect(func(): self.buy_capacity(i))
		$HBoxContainer/MarginContainer2/Capacity.add_child(button)
		i += 1

func buy_charger(index):
	if index not in bought_chargers:
		bought_chargers[index] = 0
	bought_chargers[index] += 1
	
	generate_buttons()

func buy_capacity(index):
	if index not in bought_capacity:
		bought_capacity[index] = 0
	bought_capacity[index] += 1
	
	current_capacity += capacity_buttons[index].capacity

# TODO: 

extends Control

var current_capacity = 1
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
	
	func _init(label, unlocked_after, base_cost, charge_amount, charges_per_second):
		self.label = label
		self.unlocked_after = unlocked_after
		self.charge_amount = charge_amount
		self.charges_per_second = charges_per_second  # -1 = continous
		self.base_cost = base_cost

class CapacityButton:
	extends Item
	var capacity: int
	
	func _init(label, unlocked_after, base_cost, capacity):
		self.label = label
		self.unlocked_after = unlocked_after
		self.capacity = capacity
		self.base_cost = base_cost
	

var charging_buttons = [
	ChargingButton.new("Hire a hamster", 0, 1, 1, 1),
	ChargingButton.new("Hire someone to turn a crank", 10, 5, 2, 10),
]

var capacity_buttons = [
	CapacityButton.new("Add a powerbank", 0, 1, 1),
	CapacityButton.new("Add a car battery", 10, 5, 10),
]

var bought_items = {} # key: index of charging_buttons, value: amount bought


func _ready() -> void:
	for i in charging_buttons.size():
		bought_items[i] = 0
		
	generate_buttons()

func _physics_process(delta: float) -> void:
	pass

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
		button.text = b.label + " (" + str(bought_items[i]) + " owned)\n(" + str(b.charge_amount) + " every " + str(b.charges_per_second) + " seconds)"
		button.pressed.connect(func(): self.buy_charger(i))
		$HBoxContainer/MarginContainer/Charging.add_child(button)
		i += 1

	for b in capacity_buttons:
		var button = Button.new()
		button.text = b.label
		button.pressed.connect(self.buy_capacity)
		$HBoxContainer/MarginContainer2/Capacity.add_child(button)

func buy_charger(index):
	if index not in bought_items:
		bought_items[index] = 0
	bought_items[index] += 1
	
	generate_buttons()

func buy_capacity():
	pass

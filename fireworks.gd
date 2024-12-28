extends Node3D

var stopped = false
var timers = []
var blink_timers = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	for i in range(4):
		var timer = Timer.new()
		timer.wait_time = randf() / 2
		timer.one_shot = true # don't loop, run once
		timer.connect("timeout", func(): self.on(timer, i))
		add_child(timer)
		timers.append(timer)
		
		var bt = Timer.new()
		bt.wait_time = randf() / 5
		bt.one_shot = true # don't loop, run once
		bt.connect("timeout", func(): self.blink(timer, i))
		add_child(bt)
		blink_timers.append(bt)

func start():
	for timer in timers:
		timer.start()
		
func on(timer, i):
	self.get_children()[i].visible = true
	timer.wait_time = randf() / 2
	blink_timers[i].start()
	
func blink(timer, i):
	self.get_children()[i].visible = false
	if not stopped:
		timer.wait_time = randf() * 1.5
		timers[i].start()
	
func stop():
	stopped = true

extends Node3D

const MINIMUM_WAIT = 700
	
enum Action {
	ALEX,
	MITCHELL,
	SARAH
}

signal advance
signal finished

var played_intro = false
var last_line = Time.get_ticks_msec()
var timer

func index_to_node(index, intro):
	if intro:
		if index == 0:
			return $IntroBubbles/Alex
		elif index == 1:
			return $IntroBubbles/Mitchell
		elif index == 2:
			return $IntroBubbles/Sarah
	else:
		if index == 0:
			return $Alex
		elif index == 1:
			return $Sprite3D/Mitchell
		elif index == 2:
			return $Sarah

func set_text(text, index, intro):
	for i in range(3):
		if i == index: 
			index_to_node(i, intro).text = text
		else:
			index_to_node(i, intro).text = ''

func _ready():
	add_to_group("dialogue")
	timer = Timer.new()
	add_child(timer)
	#blink_timer = Timer.new()
	#blink_timer.connect("timeout", self, "_on_blink_timer_timeout")
	#add_child(blink_timer)
	$activator.body_entered.connect(_on_body_entered_dialogue)

func start():
	var dialogue = parse_dialogue("dialogue")
	play(dialogue, false)
	
func start_intro():
	var dialogue = parse_dialogue("dialogue_intro")
	play(dialogue, true)
		
func parse_dialogue(filename):
	var file = FileAccess.open("res://" + filename + ".txt", FileAccess.READ)
	var content = file.get_as_text()
	file = null
	
	var dialogue = {}
	
	var current_time = str(0)
	dialogue[current_time] = []
	var last_cond = null
	var condition = []
	for line in content.strip_edges().split("\n"):
		line = line.strip_edges()
		if line.is_empty():
			condition = []
			last_cond = null
		elif line.begins_with("#"):
			continue
			#current_time = line.split(" ")[1]
		elif line.begins_with("/"):
			var action = line.split(" ")[1]
#			if action == "FADE":
#				dialogue[current_time].append([Action.FADE])
		elif line.begins_with("="):
			if not last_cond == null:
				condition = [last_cond, 1]
			else:
				var args = line.split(" ")
				condition = [args[1], 0]
				last_cond = args[1]
		else:
			var person_line = line.split(" ", true, 1)
			if len(person_line) < 2:
				printerr("invalid dialogue line: ", line)
			
			var action
			if person_line[0] == 'a':
				action = Action.ALEX
			elif person_line[0] == 'm':
				action = Action.MITCHELL
			elif person_line[0] == 's':
				action = Action.SARAH
			else:
				printerr("invalid dialogue person in line: ", person_line)
			dialogue[current_time].append([action, person_line[1], condition])
	
	return dialogue

func play(dialogue, intro):
	var time = 0
	for line in dialogue[str(time)]:
		if line[0] in [Action.ALEX, Action.MITCHELL, Action.SARAH]:
			var condition = line[2]
			if condition:
				if condition[0] in Global.choices:
					if Global.choices[condition[0]] != condition[1]:
						continue
				else:
					print("Choice '", condition[0], "' not defined!")
					continue
				
			last_line = Time.get_ticks_msec()
			set_text(line[1], line[0], intro)
			#if line[0] == Action.SARAH:
				#set_text(line[1], line[0], intro)
			#elif line[0] == Action.MITCHELL:
				#if intro:
					#$IntroBubbles/Sarah.text = line[1]
			#elif line[0] == Action.ALEX:
				#if intro:
					#$IntroBubbles/Sarah.text = line[1]
			#emit_signal("show", line[1])
#
#			last_line = Time.get_ticks_msec()
#
			# TODO: Min wait time
			var word_count = len(line[1].split(" "))
			var reading_time = max(1.5, word_count / 225.0 * 60) / Global.TEXT_SPEED

			print(word_count, " words, equals ", reading_time, " seconds")
			timer.start(reading_time) 
			await timer.timeout
			
	set_text('', -1, intro)

#		elif line[0] == Action.FADE:
#			$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#			$TweenFade.start()
#
#			await $TweenFade.tween_completed
#
#			$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#			$TweenFade.start()
#
#			timer.start(1)
#			await timer.timeout
	
#	$TweenFade.interpolate_property($Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$TweenFade.start()
#
#	await $TweenFade.tween_completed
	
	#timer.start(1)
	#await timer.timeout

func _on_body_entered_dialogue(body):
	if not played_intro:
		played_intro = true
		self.start_intro()

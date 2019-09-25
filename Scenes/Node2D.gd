extends Node2D
#
var time_elapsed = 0
var button_presses = 0
var bpm = 0

var first_press = true

var counter = 0

var blacklist = []

func _ready():
	pass 
	
func _process(delta):
	time_elapsed += delta
	counter += delta
	
	while counter >= 0.005 and false:
		counter -= 0.005
#		$AudioStreamPlayer.play()
	
	check_thresholds()
	
func check_thresholds():
	if counter > 5 and not(5 in blacklist):
		blacklist.append(5)
		print("HI:D")
	
func _on_Button_pressed():
	
	$first_press_timer.start()
	
	if first_press:
		button_presses = 0
		time_elapsed = 0
		first_press = false
		$bpm.text = "BPM: 0"
		
	button_presses += 1
	if button_presses > 3:
		bpm = 60*button_presses/time_elapsed
		get_node("Sprite/AnimationPlayer").playback_speed = (bpm/120)
		$bpm.text = "BPM: " + str(bpm)

func _on_first_press_timer_timeout():
	first_press = true
	print("RESET!")

func _on_sound_event_timer_timeout():
#	
	$sound_event_timer.wait_time = float(bpm)/(60*60)

func play_sound():
	$AudioStreamPlayer.play()
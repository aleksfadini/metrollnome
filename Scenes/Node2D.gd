extends Node2D

var time_elapsed = 0
var button_presses = 0
var bpm = 0

var first_press = true

var counter = 0

var blacklist = []

#Loops
var Loop_4_4

func _ready():
	Loop_4_4 = $LoopsAt60BPM/FourFour
	Loop_4_4.play() 
	
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
		morph_audiostream_to_given_bpm(Loop_4_4,bpm)

func _on_first_press_timer_timeout():
	first_press = true
	print("RESET!")

#func _on_sound_event_timer_timeout():
#	$sound_event_timer.wait_time = float(bpm)/(60*60)

#func play_sound():
#	$AudioStreamPlayer.play()
	
#### Requires a recorded stream set at 60bpm
func morph_audiostream_to_given_bpm(audiostreamNode,target_bpm):
	# calculate pitch shift required (warp)
	var warp_required = 1
	var stretch_relative_to_60_bpm = float(target_bpm)/60
	warp_required = stretch_relative_to_60_bpm
	# shift pitch (warp)
	audiostreamNode.pitch_scale = warp_required
	# calculate compensation in octaves
	var pitch_compensation = 1
	# Hopefully the same? If speed doubles, octaves lowers
	# sadly pitch shift goes from 0 (-1 oct) to 16 (+16 oct)
	pitch_compensation = float(1)/warp_required
	# define compensation bus
	var compensation_bus = AudioServer.get_bus_index("PComp")
	# add audioNode to the bus
	audiostreamNode.bus="PComp"
	# compensate with pitch shift effect on the bus
#	AudioServer.set_pitch_scale(compensation_bus, pitch_compensation)
	var pitch_effect = AudioServer.get_bus_effect(1, 0)
#	effect.pan = 0.63
	pitch_effect.pitch_scale=pitch_compensation
	pass
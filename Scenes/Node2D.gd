extends Node2D

# debug mode
var debug_mode = true
# Tap Tempo System
var time_elapsed = 0
var button_presses = 0
var bpm = 350
var first_press = true
var counter = 0
var beat_in_ms = 0
# Bar and beat counters
var bar_counter = 1 # the first bar is called "1"
var beat_counter = 0
var beats_per_bar = 4
#Loops	
var FirstBeat
var OtherBeat
# Events
var blacklist = []
# Latency System
var max_latency_buffer = 1000 # in ms (should be added before each sound)
var look_ahead = 40 # in ms
var beat_already_played = false
# this is a temp var that keeps track of when 
# the last beat was detected, used as a flag to avoid repeating
# the same beat
var last_beat_buffer_delay = 0

func _ready():
	# initialize starting bpm
	$bpm.text = str(bpm)
	beat_in_ms = bpm_to_beat_in_ms(bpm)
#	set_physics_process_internal(true)
#	Loop_4_4 = $LopsAt60BPM/FourFour
	FirstBeat = $FirstBeat
	OtherBeat = $OtherBeat
	# initialize buffer system
	last_beat_buffer_delay = look_ahead
	
func _process(delta):
	# These two are needed to detect BPM
	time_elapsed += delta
	counter += delta
#	while counter >= 0.005 and false:
#		counter -= 0.005
#		$AudioStreamPlayer.play()
	check_timeline()
	# this is a way to add random events
	check_thresholds()

func check_timeline():
	# find how close this frame is to the next beat
#	var ms_from_beat = beat_in_ms-(OS.get_ticks_msec()% beat_in_ms)
	var ms_from_beat = beat_in_ms-(OS.get_ticks_msec()% beat_in_ms)
	## Try to add audiostrea latency with 
	# AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
#	print("GT: ",ms_from_beat)
	# check if beat has already been played
	if ms_from_beat <= last_beat_buffer_delay:
#		beat_already_played = true
		pass
	else:
		beat_already_played = false
		last_beat_buffer_delay = look_ahead
	# if closer than look_ahead and not already played, play with delay
	if ms_from_beat < look_ahead and not beat_already_played:
		play_with_delay(ms_from_beat)
		beat_already_played = true
		#set the buffer delayed to use as reference
		last_beat_buffer_delay = ms_from_beat
		print("last_beat_buffer_delay: ", last_beat_buffer_delay)
	
# detect bpm on button pressed
func _on_Button_pressed():
	$first_press_timer.start()
	if first_press:
		button_presses = 0
		time_elapsed = 0
		first_press = false
		$bpm.text = "BPM: 0"
	button_presses += 1
	if button_presses > 3:
		bpm = int(60*button_presses/time_elapsed)
		get_node("Sprite/AnimationPlayer").playback_speed = (bpm/120)
		$bpm.text = "BPM: " + str(bpm)
		# find beat in ms (should be moved to where the bpm is updated)
	beat_in_ms = bpm_to_beat_in_ms(bpm)
		# morph beat 1
#		morph_beat_loop_to_given_bpm(FirstBeat,bpm)
		# morph beat 2
#		morph_beat_loop_to_given_bpm(OtherBeat,bpm)
#		FirstBeat.play()
		
#		Loop_4_4.play() 
		

func _on_first_press_timer_timeout():
	first_press = true
	print("RESET!")

# This function keeps triggering one beat after 
# the other.
func play_with_delay(delay):
	# note: this division introduces an error. check float/integers
	var delay_in_secs=float(delay)/1000
	beat_counter+=1
	# testing: removing delay
#	delay_in_secs = 0
	print ("playing with delay: ", delay_in_secs)
	reset_beat_counter_each_bar()
	if beat_counter == 0:
		#play beat 1
#		FirstBeat.play(1-delay_in_secs)
		PlayBeat("first",1-delay_in_secs)
	else:
		#play beat non-1 (different sound)
		PlayBeat("other",1-delay_in_secs)
#		OtherBeat.play(1-delay_in_secs)

		
func reset_beat_counter_each_bar():
	print("Bar/Beat: ", bar_counter, " / ", beat_counter)
#	print("beat: ", beat_counter)
	if beat_counter < beats_per_bar:
		return
	else:
		beat_counter = 0
		bar_counter += 1



## found this online
#func _notification(what):
#    match what:
#        NOTIFICATION_INTERNAL_PHYSICS_PROCESS:
#            # update code here
#			pass

# calculates the length of a beat in ms
# given a certain bpm
func bpm_to_beat_in_ms(any_bpm):
	var beat_in_ms = float(60000)/any_bpm
	print ("calc - bpm: ", any_bpm, "to ms: ", int(beat_in_ms))
	return int(beat_in_ms)
	
## temptative workaround
func PlayBeat(type_of_beat="first", delay_time="0"):
	var player = AudioStreamPlayer.new()
	$BeatsPlaying.add_child(player)
	var audio_sample 
	if type_of_beat == "first":
		if not debug_mode:
			audio_sample =load("res://Sound/PFirstBeat.ogg")
			audio_sample.set_loop(false)
		# if in debug mode, make all beats sound the same
		else:
			audio_sample =load("res://Sound/POtherBeat.ogg")		
			audio_sample.set_loop(false)
		player.stream = audio_sample
	if type_of_beat == "other":
		audio_sample =load("res://Sound/POtherBeat.ogg")		
		audio_sample.set_loop(false)
		player.stream = audio_sample
#	player.set_max_db(-60 + (volume * 60.0))
	player.connect("finished", player, "queue_free")
	player.play(delay_time)

#################################################33333
############### EFFECTS SECTION
###################################

# Insert random events here
func check_thresholds():
	if counter > 5 and not(5 in blacklist):
		blacklist.append(5)
		print("HI:D")
	
#### Requires a recorded stream set at 60bpm
func morph_beat_loop_to_given_bpm(audiostreamNode,target_bpm):
	# calculate pitch shift required (warp)
	var warp_required = 1
	var stretch_relative_to_120_bpm = float(target_bpm)/120
	warp_required = stretch_relative_to_120_bpm
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
#	#AudioServer.set_pitch_scale(compensation_bus, pitch_compensation)
	var pitch_effect = AudioServer.get_bus_effect(1, 0)
	pitch_effect.pitch_scale=pitch_compensation
	pass
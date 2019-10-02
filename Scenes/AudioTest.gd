extends Node

var time_begin
var time_delay

func _ready():
	time_begin = OS.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	$Player.play()

func _process(delta):
    # Obtain from ticks.
	var time = (OS.get_ticks_usec() - time_begin) / 1000000.0
    # Compensate for latency.
	time -= time_delay
    # May be below 0 (did not being yet).
	time = max(0, time)
	print("Time is: ", time)
	
	
##################
#Second Example 
#########################
#
#Using the sound hardware clock to sync
#
#Using AudioStreamPlayer.get_playback_position() to obtain the current position for the song sounds ideal, but it’s not that useful as-is. This value will increment in chunks (every time the audio callback mixed a block of sound), so many calls can return the same value. Added to this, the value will be out of sync with the speakers too because of the previously mentioned reasons.
#
#To compensate for the “chunked” output, there is a function that can help: AudioServer.get_time_since_last_mix().
#
#Adding the return value from this function to get_playback_position() increases precision:
#
#var time = $Player.get_playback_position() + AudioServer.get_time_since_last_mix()
#
#To increase precision, substract the latency information (how much it takes for the audio to be heard after it was mixed):
#
#var time = $Player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
#
#The result may be a bit jittery due how multiple threads work. Just check that the value is not less than in the previous frame (discard it if so). This is also a less precise approach than the one before, but it will work for songs of any length, or synchronizing anything (sound effects, as an example) to music.
#
#Here is the same code as before using this approach:
#
#func _ready()
#    $Player.play()
#
#func _process(delta):
#    var time = $Player.get_playback_position() + AudioServer.get_time_since_last_mix()
#    # Compensate for output latency.
#    time -= AudioServer.get_output_latency()
#    print("Time is: ", time)
#

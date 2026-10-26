// Set in the instance's creation code once the recording exists: track = snd_narration_hall;
track = -1;
voice = -1;
// Picks up the playing narration on the first step, once creation code has set track.
attached = false;

// The narration playing, kept across rooms: going to the canvas and back carries on with it,
// and a room with a different track stops it.
if(!variable_global_exists("narration")) global.narration = { track: -1, voice: -1, room: -1 };
image_speed = 0;
// Click area, until the object has a sprite.
size = 64;

paused = function(){
	return voice != -1 && audio_is_paused(voice);
}

formatTime = function(seconds){
	seconds = floor(seconds);
	return string("{0}:{1}", seconds div 60, string_replace_all(string_format(seconds mod 60, 2, 0), " ", "0"));
}

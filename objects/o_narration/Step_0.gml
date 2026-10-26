if(!attached){
	attached = true;
	var n = global.narration;
	if(n.voice != -1 && n.track == track && (audio_is_playing(n.voice) || audio_is_paused(n.voice))){
		voice = n.voice;
	} else if(n.voice != -1){
		audio_stop_sound(n.voice);
		n.voice = -1;
	}
}

// Played to the end.
if(voice != -1 && !audio_is_playing(voice) && !audio_is_paused(voice)) voice = -1;

// With a sprite, frame 0 is stopped or paused and frame 1 is playing, if there is one.
if(sprite_index != -1) image_index = min(voice != -1 && !paused(), image_number - 1);

var over = sprite_index != -1
	? position_meeting(mouse_x, mouse_y, id)
	: point_in_box(mouse_x, mouse_y, x, y, x + size, y + size);

if(over && mouse_check_button_pressed(mb_left) && audio_exists(track)){
	if(voice == -1){
		voice = audio_play_sound(track, 10, false);
		global.narration.voice = voice;
		global.narration.track = track;
		global.narration.room = room;
	} else if(paused()){
		audio_resume_sound(voice);
	} else {
		audio_pause_sound(voice);
	}
}

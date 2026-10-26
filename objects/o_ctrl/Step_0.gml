// Narration can finish in a room with no speaker, like the canvas, so its end is noticed here.
if(variable_global_exists("narration")){
	var n = global.narration;
	if(n.voice != -1 && !audio_is_playing(n.voice) && !audio_is_paused(n.voice)){
		n.voice = -1;
		if((n[$ "room"] ?? -1) == rm_memories) jam60_achievement_complete("memories");
	}
}

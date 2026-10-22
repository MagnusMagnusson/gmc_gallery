if(speech_is_talking()){
	alarm[4] = 30;
	exit;
}

var p = sb_player();
if (is_undefined(p)){
	if(secondary_bubble){
		secondary_bubble.dismiss()
	}
	secondary_bubble = speech_say(@"Please, tell me who you are.");
	exit;
}
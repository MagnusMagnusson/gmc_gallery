if(speech_is_talking()){
	alarm[4] = 60;
	exit;
}

var p = sb_player();
if (is_undefined(p)){
	if(secondary_bubble){
		secondary_bubble.dismiss()
	}
	secondary_bubble = speech_say(@"Please, tell me who you are.", 2);
	instance_create_layer(36, 277, layer_get_id("Instances"), o_signup_sheet);
	exit;
}
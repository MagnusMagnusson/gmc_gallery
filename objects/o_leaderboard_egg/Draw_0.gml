draw_set_font(fnt_speech);
draw_set_color(c_black);
if(array_length(scores) == 0){
	if(!error){
		draw_text(16, 96, "Loading scores...");
	} else if(error){
		draw_text(16, 96, "Failed to load scores.");
	}	
	exit;
}

for(var i = 0; i < array_length(scores); i++){
	var _score = scores[i];
	var text = string_copy(string("{0}. {2}/{1} eggs {3}", _score.rank, _score.score, formatTime(_score.secondary_score), _score.player_name),1,32);
	draw_text(16, 96 + i * string_height("string!"), text);
}
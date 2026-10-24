t += 1/40;

if(keyboard_lastchar != ""){
	var c = string_lower(keyboard_lastchar);
	keyboard_lastchar = "";
	if(c == string_lower(string_char_at(word, index + 1))){
		index++;
		if(index == string_length(word)){
			index = 0;
			correct++;
			with(o_small_egg) hit();
			with(o_big_egg) hit();
			getNextWord();
		}
	}
}

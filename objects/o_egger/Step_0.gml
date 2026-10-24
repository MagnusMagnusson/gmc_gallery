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

			// Punctuation for the next word. 5, 9 and 2 are coprime, so "?" comes every 90th word.
			var n = correct + 1;
			var dot = n % 5 == 0;
			var ex = n % 9 == 0;
			var quest = dot && ex && n % 2 == 0;
			word = "EGG" + (quest ? "?" : (dot ? "." : (ex ? "!" : "")));
		}
	} else {
		// A wrong key that matches the first letter starts the word over.
		index = c == string_lower(string_char_at(word, 1)) ? 1 : 0;
	}
}

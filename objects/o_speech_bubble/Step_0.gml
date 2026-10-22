if (closing) {
	appear -= 1 / SPEECH_POP_STEPS;
	if (appear <= 0) instance_destroy();
	exit;
}
appear = min(1, appear + 1 / SPEECH_POP_STEPS);

if (shown < length) {
	if (pause > 0) {
		pause--;
		exit;
	}
	var _from = floor(shown);
	shown = min(length, shown + SPEECH_CHARS_PER_STEP);
	for (var i = _from + 1; i <= floor(shown); i++) {
		var _char = string_char_at(lines, i);
		if (string_pos(_char, ".,!?;:") > 0) {
			// Catch a breath, and start the next bit with a blip.
			shown = i;
			pause = SPEECH_PUNCT_PAUSE;
			letters_since_blip = SPEECH_BLIP_EVERY - 1;
			break;
		}
		if (_char != " " && _char != "\n" && ++letters_since_blip >= SPEECH_BLIP_EVERY) {
			letters_since_blip = 0;
			blip();
		}
	}
} else if (hold_steps >= 0 && hold_steps-- == 0) {
	dismiss();
}

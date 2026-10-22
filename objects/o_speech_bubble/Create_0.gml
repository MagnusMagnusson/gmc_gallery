var _layout = global.speech_slots[slot];

draw_set_font(SPEECH_FONT);
lines = __speech_wrap(text, SPEECH_MAX_WIDTH / SPEECH_TEXT_SCALE);
length = string_length(lines);

var _w = string_width(lines) * SPEECH_TEXT_SCALE + SPEECH_PADDING * 2;
var _h = string_height(lines) * SPEECH_TEXT_SCALE + SPEECH_PADDING * 2;
x2 = _layout.x;
x1 = x2 - _w;
if (_layout.grow_up) {
	y2 = _layout.y;
	y1 = y2 - _h;
} else {
	y1 = _layout.y;
	y2 = y1 + _h;
}
tail_x = _layout.tail_x;
tail_y = _layout.tail_y;

shown = 0;
pause = 0;
// So the very first letter blips.
letters_since_blip = SPEECH_BLIP_EVERY - 1;
hold_steps = (hold < 0) ? -1 : ceil(hold * game_get_speed(gamespeed_fps));
voice = -1;

appear = 0;
closing = false;


dismiss = function() {
	if (closing) return;
	closing = true;
	// Free the spot straight away, so a new bubble can take it while this one pops out.
	var _layout = global.speech_slots[slot];
	if (_layout.bubble == id) _layout.bubble = noone;
};

blip = function() {
	var _voices = global.speech_voices;
	if (array_length(_voices) == 0) return;
	// Cut the last blip short; overlapping ones turn to mush.
	if (audio_is_playing(voice)) audio_stop_sound(voice);
	var _sound = _voices[irandom(array_length(_voices) - 1)];
	voice = audio_play_sound(_sound, 1, false, 1, 0, random_range(SPEECH_PITCH_MIN, SPEECH_PITCH_MAX));
};

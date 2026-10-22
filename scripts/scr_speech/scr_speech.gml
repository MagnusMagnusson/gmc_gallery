#macro SPEECH_FONT fnt_speech
#macro SPEECH_TEXT_SCALE 1
#macro SPEECH_MAX_WIDTH 360
#macro SPEECH_PADDING 22
#macro SPEECH_CORNER_RADIUS 36
#macro SPEECH_OUTLINE 4
#macro SPEECH_TAIL_WIDTH 36
#macro SPEECH_POP_STEPS 12
#macro SPEECH_CHARS_PER_STEP 0.6
#macro SPEECH_BLIP_EVERY 2
#macro SPEECH_PUNCT_PAUSE 10
#macro SPEECH_PITCH_MIN 0.9
#macro SPEECH_PITCH_MAX 1.25

global.speech_voices = [
	babble_a,
	babble_e,
	babble_i,
	babble_u
];

// Hand coding this is a bad way, but this only needs to survive for like, two weeks. 
global.speech_slots = [
	{ x: 870, y: 215, grow_up: true,  tail_x: 925, tail_y: 265, bubble: noone }, // top left
	{ x: 870, y: 365, grow_up: false, tail_x: 925, tail_y: 315, bubble: noone }, // bottom left
];

global.speech_count = 0;
function speech_say(_text, _hold = -1) {
	var _slots = global.speech_slots;
	var _slot = -1;
	for (var i = 0; i < array_length(_slots); i++) {
		if (!instance_exists(_slots[i].bubble)) {
			_slot = i;
			break;
		}
	}
	if (_slot == -1) {
		_slot = 0;
		for (var i = 1; i < array_length(_slots); i++) {
			if (_slots[i].bubble.born < _slots[_slot].bubble.born) _slot = i;
		}
		instance_destroy(_slots[_slot].bubble);
	}

	var _bubble = instance_create_depth(0, 0, -1000, o_speech_bubble, {
		text: _text,
		slot: _slot,
		hold: _hold,
		born: global.speech_count++,
	});
	_slots[_slot].bubble = _bubble;
	return _bubble;
}

function speech_dismiss_all() {
	with (o_speech_bubble) dismiss();
}

function speech_is_talking() {
	with (o_speech_bubble) {
		if (!closing && shown < length) return true;
	}
	return false;
}


/// @ignore
function __speech_wrap(_text, _width) {
	var _out = "";
	var _paragraphs = string_split(_text, "\n");
	for (var p = 0; p < array_length(_paragraphs); p++) {
		var _words = string_split(_paragraphs[p], " ");
		var _line = "";
		for (var w = 0; w < array_length(_words); w++) {
			var _try = (_line == "") ? _words[w] : _line + " " + _words[w];
			if (_line != "" && string_width(_try) > _width) {
				_out += _line + "\n";
				_line = _words[w];
			} else {
				_line = _try;
			}
		}
		_out += _line;
		if (p < array_length(_paragraphs) - 1) _out += "\n";
	}
	return _out;
}

if !o_paint.can_edit exit;
var _paint = global.paint;
var _click = mouse_check_button_pressed(mb_left);

// Colour picker popup
if (_paint.picker_open) {
	if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_enter)) {
		_paint.picker_open = false;
		exit;
	}
	if (_click) {
		if (point_distance(mouse_x, mouse_y, wheel_x, wheel_y) <= wheel_r) {
			drag = "wheel";
			// Picking a hue from black would stay black, so bring the brightness up
			if (val == 0) val = 255;
		} else if (point_in_box(mouse_x, mouse_y, bar_x1 - 6, bar_y1 - 4, bar_x2 + 6, bar_y2 + 4)) {
			drag = "value";
		} else if (point_in_box(mouse_x, mouse_y, done_x1, done_y1, done_x2, done_y2)
		|| !point_in_box(mouse_x, mouse_y, picker_x, picker_y, picker_x + picker_w, picker_y + picker_h)) {
			// Closing click must not also reach the canvas or other UI this frame
			_paint.picker_open = false;
			mouse_clear(mb_left);
			exit;
		}
	}
	if (drag != "" && mouse_check_button(mb_left)) {
		if (drag == "wheel") {
			hue = point_direction(wheel_x, wheel_y, mouse_x, mouse_y) / 360 * 255;
			sat = min(point_distance(wheel_x, wheel_y, mouse_x, mouse_y), wheel_r) / wheel_r * 255;
		} else {
			val = clamp((mouse_x - bar_x1) / (bar_x2 - bar_x1), 0, 1) * 255;
		}
		set_colour(make_colour_hsv(hue, sat, val));
	} else {
		drag = "";
	}
	exit;
}

// Hex field: type RRGGBB, applied as soon as it is complete. Enter or click away to finish, Escape to revert.
if (editing) {
	var _raw = string_upper(keyboard_string);
	var _clean = "";
	for (var _i = 1; _i <= string_length(_raw) && string_length(_clean) < 6; _i++) {
		var _ch = string_char_at(_raw, _i);
		if (string_pos(_ch, HEX_DIGITS) > 0) _clean += _ch;
	}
	hex_text = _clean;
	keyboard_string = _clean;

	var _parsed = hex_to_colour(hex_text);
	if (string_length(hex_text) == 6) set_colour(_parsed);

	if (keyboard_check_pressed(vk_escape)) {
		_paint.colour = edit_start_colour;
		colours[selected] = edit_start_swatch;
		editing = false;
	} else if (keyboard_check_pressed(vk_enter)
	|| (_click && !point_in_box(mouse_x, mouse_y, x, field_y, x + field_w, field_y + field_h))) {
		if (!is_undefined(_parsed)) set_colour(_parsed);
		editing = false;
	}
} else if (_click && point_in_box(mouse_x, mouse_y, x, field_y, x + field_w, field_y + field_h)) {
	editing = true;
	edit_start_colour = _paint.colour;
	edit_start_swatch = colours[selected];
	hex_text = colour_to_hex(_paint.colour);
	keyboard_string = hex_text;
}
_paint.typing = editing;

// Colour wheel button opens the picker on the current colour
if (_click && point_in_box(mouse_x, mouse_y, button_x, field_y, button_x + field_h, field_y + field_h)) {
	hue = colour_get_hue(_paint.colour);
	sat = colour_get_saturation(_paint.colour);
	val = colour_get_value(_paint.colour);
	drag = "";
	_paint.picker_open = true;
	exit;
}

if (_click) {
	var _swatch = swatch_at(mouse_x, mouse_y);
	if (_swatch >= 0) {
		selected = _swatch;
		_paint.colour = colours[_swatch];
	}
}

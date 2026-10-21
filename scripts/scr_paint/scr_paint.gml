enum Tool {
	Pencil,
	Brush,
	Spray,
	Eraser,
	Fill,
	Picker,
}

#macro PAINT_SIZE_MIN 1
#macro PAINT_SIZE_MAX 64

// Shared paint state: the palette and toolbox write it, the canvas reads it.
global.paint = {
	colour: c_black,
	tool: Tool.Brush,
	size: 8,
	picker_open: false, // Colour picker popup is modal: other UI and the canvas ignore the mouse
	typing: false,      // Hex field has focus: tool shortcut keys are ignored
};

#macro HEX_DIGITS "0123456789ABCDEF"

// Returns a colour encoded the way buffer_get_surface stores pixels, whatever the platform's byte order.
function colour_to_pixel(_colour) {
	var _surf = surface_create(1, 1);
	surface_set_target(_surf);
	draw_clear_alpha(_colour, 1);
	surface_reset_target();
	var _buf = buffer_create(4, buffer_fixed, 1);
	buffer_get_surface(_buf, _surf, 0);
	var _pixel = buffer_peek(_buf, 0, buffer_u32);
	buffer_delete(_buf);
	surface_free(_surf);
	return _pixel;
}

// "RRGGBB" for a colour
function colour_to_hex(_colour) {
	var _parts = [colour_get_red(_colour), colour_get_green(_colour), colour_get_blue(_colour)];
	var _out = "";
	for (var _i = 0; _i < 3; _i++) {
		_out += string_char_at(HEX_DIGITS, (_parts[_i] div 16) + 1) + string_char_at(HEX_DIGITS, (_parts[_i] mod 16) + 1);
	}
	return _out;
}

// Parses "RRGGBB" or "RGB", with or without "#"; returns undefined if invalid.
function hex_to_colour(_hex) {
	_hex = string_upper(string_replace_all(_hex, "#", ""));
	if (string_length(_hex) == 3) {
		var _r = string_char_at(_hex, 1), _g = string_char_at(_hex, 2), _b = string_char_at(_hex, 3);
		_hex = _r + _r + _g + _g + _b + _b;
	}
	if (string_length(_hex) != 6) return undefined;

	var _value = 0;
	for (var _i = 1; _i <= 6; _i++) {
		var _digit = string_pos(string_char_at(_hex, _i), HEX_DIGITS) - 1;
		if (_digit < 0) return undefined;
		_value = _value * 16 + _digit;
	}
	return make_colour_rgb((_value >> 16) & 255, (_value >> 8) & 255, _value & 255);
}

// Hue around the rim (angle as in lengthdir/point_direction), saturation from centre to rim, full value.
function draw_hue_wheel(_cx, _cy, _r, _segments = 48) {
	draw_primitive_begin(pr_trianglelist);
	for (var _i = 0; _i < _segments; _i++) {
		var _a1 = _i / _segments * 360;
		var _a2 = (_i + 1) / _segments * 360;
		draw_vertex_colour(_cx, _cy, c_white, 1);
		draw_vertex_colour(_cx + lengthdir_x(_r, _a1), _cy + lengthdir_y(_r, _a1), make_colour_hsv(_a1 / 360 * 255, 255, 255), 1);
		draw_vertex_colour(_cx + lengthdir_x(_r, _a2), _cy + lengthdir_y(_r, _a2), make_colour_hsv(_a2 / 360 * 255, 255, 255), 1);
	}
	draw_primitive_end();
}

function point_in_box(_px, _py, _x1, _y1, _x2, _y2) {
	return _px >= _x1 && _py >= _y1 && _px < _x2 && _py < _y2;
}

function ui_button(_x1, _y1, _x2, _y2, _label, _active) {
	draw_set_font(fnt_paint_ui_label);
	var _hover = point_in_box(mouse_x, mouse_y, _x1, _y1, _x2, _y2);
	draw_set_colour(_active ? make_colour_rgb(70, 110, 200) : (_hover ? make_colour_rgb(225, 225, 230) : c_white));
	draw_rectangle(_x1, _y1, _x2 - 1, _y2 - 1, false);
	draw_set_colour(c_dkgray);
	draw_rectangle(_x1, _y1, _x2 - 1, _y2 - 1, true);
	draw_set_colour(_active ? c_white : c_black);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text((_x1 + _x2) / 2, (_y1 + _y2) / 2, _label);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

function draw_colour_picker(){

	// Panel
	draw_set_colour(c_black);
	draw_set_alpha(0.25);
	draw_rectangle(picker_x + 5, picker_y + 5, picker_x + picker_w + 4, picker_y + picker_h + 4, false);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	draw_rectangle(picker_x, picker_y, picker_x + picker_w - 1, picker_y + picker_h - 1, false);
	draw_set_colour(c_dkgray);
	draw_rectangle(picker_x, picker_y, picker_x + picker_w - 1, picker_y + picker_h - 1, true);
	draw_set_colour(c_black);
	draw_text(picker_x + 10, picker_y + 8, "Colour picker");

	// Hue / saturation wheel with a marker on the current pick
	draw_hue_wheel(wheel_x, wheel_y, wheel_r, 72);
	var _mx = wheel_x + lengthdir_x(sat / 255 * wheel_r, hue / 255 * 360);
	var _my = wheel_y + lengthdir_y(sat / 255 * wheel_r, hue / 255 * 360);
	draw_set_colour(c_black);
	draw_circle(_mx, _my, 6, true);
	draw_set_colour(c_white);
	draw_circle(_mx, _my, 5, true);

	// Brightness bar from black to the full-brightness pick
	var _full = make_colour_hsv(hue, sat, 255);
	draw_rectangle_colour(bar_x1, bar_y1, bar_x2, bar_y2, c_black, _full, _full, c_black, false);
	draw_set_colour(c_dkgray);
	draw_rectangle(bar_x1, bar_y1, bar_x2, bar_y2, true);
	var _kx = lerp(bar_x1, bar_x2, val / 255);
	draw_set_colour(c_black);
	draw_rectangle(_kx - 3, bar_y1 - 4, _kx + 3, bar_y2 + 4, true);
	draw_set_colour(c_white);
	draw_rectangle(_kx - 2, bar_y1 - 3, _kx + 2, bar_y2 + 3, true);

	// Result preview and close button
	draw_set_colour(global.paint.colour);
	draw_rectangle(bar_x1, done_y1, bar_x1 + 60, done_y2 - 1, false);
	draw_set_colour(c_dkgray);
	draw_rectangle(bar_x1, done_y1, bar_x1 + 60, done_y2 - 1, true);
	ui_button(done_x1, done_y1, done_x2, done_y2, "Done", false);

	draw_set_colour(c_white);

}
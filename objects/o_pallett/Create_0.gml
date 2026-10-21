colours = [
	c_black,                         c_dkgray,                        c_gray,                          c_white,
	make_colour_rgb(128, 0, 0),      make_colour_rgb(220, 40, 40),    make_colour_rgb(255, 140, 140),  make_colour_rgb(255, 128, 0),
	make_colour_rgb(255, 220, 0),    make_colour_rgb(255, 245, 160),  make_colour_rgb(120, 80, 30),    make_colour_rgb(200, 160, 110),
	make_colour_rgb(0, 100, 0),      make_colour_rgb(40, 180, 60),    make_colour_rgb(170, 230, 130),  make_colour_rgb(0, 150, 150),
	make_colour_rgb(0, 40, 140),     make_colour_rgb(40, 110, 230),   make_colour_rgb(140, 200, 255),  make_colour_rgb(80, 30, 140),
	make_colour_rgb(160, 70, 200),   make_colour_rgb(255, 100, 200),  make_colour_rgb(250, 220, 190),  c_silver,
];

columns = 4;
cell = 40;
gap = 6;
width = columns * (cell + gap) - gap;
preview_h = 40;
// Top of the swatch grid, below the title and the current colour preview
grid_y = y + 20 + preview_h + 12;

// Hex field and colour wheel button, below the swatches
field_h = 28;
field_y = grid_y + ceil(array_length(colours) / columns) * (cell + gap) + 6;
field_w = width - field_h - gap;
button_x = x + field_w + gap;
editing = false;
edit_start_colour = c_black;
hex_text = "";

// Colour picker popup, drawn in Draw GUI over the canvas. GUI space matches room space.
display_set_gui_size(room_width, room_height);
picker_x = 290;
picker_y = 250;
picker_w = 220;
picker_h = 296;
wheel_r = 90;
wheel_x = picker_x + picker_w / 2;
wheel_y = picker_y + 30 + wheel_r;
bar_x1 = picker_x + 20;
bar_x2 = picker_x + picker_w - 20;
bar_y1 = wheel_y + wheel_r + 12;
bar_y2 = bar_y1 + 20;
done_x1 = picker_x + picker_w - 100;
done_y1 = bar_y2 + 12;
done_x2 = picker_x + picker_w - 20;
done_y2 = done_y1 + 28;
// Picker colour as hue, saturation and value, each 0-255
hue = 0;
sat = 0;
val = 0;
drag = "";

// The selected swatch; hex and colour wheel edits are written into it
selected = 0;
edit_start_swatch = colours[selected];
global.paint.colour = colours[selected];

set_colour = function(_colour) {
	global.paint.colour = _colour;
	colours[selected] = _colour;
}

// Index of the swatch under (_px, _py), or -1
swatch_at = function(_px, _py) {
	var _col = floor((_px - x) / (cell + gap));
	var _row = floor((_py - grid_y) / (cell + gap));
	if (_col < 0 || _col >= columns || _row < 0) return -1;
	var _i = _row * columns + _col;
	if (_i >= array_length(colours)) return -1;
	var _sx = x + _col * (cell + gap);
	var _sy = grid_y + _row * (cell + gap);
	return point_in_box(_px, _py, _sx, _sy, _sx + cell, _sy + cell) ? _i : -1;
}

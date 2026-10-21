if !o_paint.can_edit exit;
var _current = global.paint.colour;
var _accent = make_colour_rgb(70, 110, 200);

draw_set_colour(c_black);
draw_text(x, y, "Palette");

draw_set_colour(_current);
draw_rectangle(x, y + 20, x + width - 1, y + 20 + preview_h - 1, false);
draw_set_colour(c_dkgray);
draw_rectangle(x, y + 20, x + width - 1, y + 20 + preview_h - 1, true);

for (var _i = 0; _i < array_length(colours); _i++) {
	var _sx = x + (_i mod columns) * (cell + gap);
	var _sy = grid_y + (_i div columns) * (cell + gap);
	draw_set_colour(colours[_i]);
	draw_rectangle(_sx, _sy, _sx + cell - 1, _sy + cell - 1, false);
	draw_set_colour(c_dkgray);
	draw_rectangle(_sx, _sy, _sx + cell - 1, _sy + cell - 1, true);
	if (_i == selected) {
		draw_set_colour(_accent);
		draw_rectangle(_sx - 3, _sy - 3, _sx + cell + 2, _sy + cell + 2, true);
		draw_rectangle(_sx - 2, _sy - 2, _sx + cell + 1, _sy + cell + 1, true);
	}
}

// Hex field
draw_set_colour(c_white);
draw_rectangle(x, field_y, x + field_w - 1, field_y + field_h - 1, false);
draw_set_colour(editing ? _accent : c_dkgray);
draw_rectangle(x, field_y, x + field_w - 1, field_y + field_h - 1, true);
if (editing) draw_rectangle(x + 1, field_y + 1, x + field_w - 2, field_y + field_h - 2, true);
var _text = "#" + (editing ? hex_text : colour_to_hex(_current));
if (editing && (current_time div 500) mod 2 == 0) _text += "_";
draw_set_colour(c_black);
draw_set_valign(fa_middle);
draw_text(x + 8, field_y + field_h / 2, _text);
draw_set_valign(fa_top);

// Colour wheel button
ui_button(button_x, field_y, button_x + field_h, field_y + field_h, "", global.paint.picker_open);
draw_hue_wheel(button_x + field_h / 2, field_y + field_h / 2, field_h / 2 - 5, 24);

draw_set_colour(c_white);

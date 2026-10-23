if(viewing){
	draw_set_font(fnt_speech);
	draw_set_colour(c_black);
	draw_text_ext(x, y, shown.title, -1, width);
	draw_set_font(fnt_paint_ui_label);
	draw_set_colour(c_dkgray);
	draw_text(x, y + title_h + 6, "by " + shown.author);
	ui_button(x, leave_y, x + width, leave_y + button_h, "Leave", false);
	draw_set_colour(c_white);
	exit;
}

if (instance_exists(o_paint) && !o_paint.can_edit) exit;
var _accent = make_colour_rgb(70, 110, 200);

draw_set_font(fnt_paint_ui_label);
draw_set_colour(c_black);
draw_text(x, y, "Title");

// Title field
draw_set_colour(c_white);
draw_rectangle(x, field_y, x + width - 1, field_y + field_h - 1, false);
draw_set_colour(editing ? _accent : c_dkgray);
draw_rectangle(x, field_y, x + width - 1, field_y + field_h - 1, true);
if (editing) draw_rectangle(x + 1, field_y + 1, x + width - 2, field_y + field_h - 2, true);

var _text = title;
// Long titles show their end, where the typing is.
while (string_width(_text) > width - 24) _text = string_delete(_text, 1, 1);
if (editing && (current_time div 500) mod 2 == 0) _text += "_";
draw_set_valign(fa_middle);
if (title == "" && !editing) {
	draw_set_colour(c_gray);
	draw_text(x + 8, field_y + field_h / 2, "Name your painting");
} else {
	draw_set_colour(c_black);
	draw_text(x + 8, field_y + field_h / 2, _text);
}
draw_set_valign(fa_top);

ui_button(x, save_y, x + width, save_y + button_h, saving ? "Saving..." : "Save", false);
ui_button(x, leave_y, x + width, leave_y + button_h, leave_confirm ? "Leave anyway" : "Leave", false);
if (!is_undefined(saved_path) || deleting) {
	ui_button(x, delete_y, x + width, delete_y + button_h, deleting ? "Deleting..." : (delete_confirm ? "Really delete" : "Delete painting"), delete_confirm);
}

draw_set_colour(c_black);
draw_text_ext(x, status_y, status, -1, width);

draw_set_colour(c_white);

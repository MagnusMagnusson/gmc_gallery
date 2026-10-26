var cx, ty;
if(sprite_index != -1){
	draw_self();
	cx = (bbox_left + bbox_right) / 2;
	ty = bbox_bottom + 4;
} else {
	// Placeholder speaker until the sprite exists.
	draw_set_colour(c_white);
	draw_roundrect(x, y, x + size, y + size, false);
	draw_set_colour(c_black);
	draw_roundrect(x, y, x + size, y + size, true);
	draw_rectangle(x + 14, y + 24, x + 26, y + 40, false);
	draw_triangle(x + 26, y + 24, x + 42, y + 12, x + 42, y + 52, false);
	draw_triangle(x + 26, y + 40, x + 26, y + 24, x + 42, y + 52, false);
	if(voice != -1 && !paused()){
		draw_line_width(x + 48, y + 24, x + 48, y + 40, 3);
		draw_line_width(x + 54, y + 18, x + 54, y + 46, 3);
	}
	cx = x + size / 2;
	ty = y + size + 4;
}

var text = "--:--";
if(audio_exists(track)){
	var pos = voice != -1 ? audio_sound_get_track_position(voice) : 0;
	text = formatTime(pos) + " / " + formatTime(audio_sound_length(track));
}
draw_set_font(fnt_paint_ui_label);
draw_set_halign(fa_center);
draw_set_colour(c_black);
draw_text(cx, ty, text);
draw_set_halign(fa_left);
draw_set_colour(c_white);

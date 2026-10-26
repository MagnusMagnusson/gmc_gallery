if(can_paint) draw_self();
if(hallway_count > 1){
	draw_set_font(fnt_speech);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_colour(c_black);
	draw_text(room_width / 2, 690, string("{0} {1} of {2}", title, index + 1, hallway_count));
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);
}

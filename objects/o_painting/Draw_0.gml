draw_self();
if(mouse_x > x && mouse_y > y && mouse_x < x + 150 && mouse_y < y + 150){
	draw_set_color(c_purple);
	var margin = 8;
	var str_w = string_width(label);
	var str_h = string_height(label);
	draw_roundrect(mouse_x - str_w/2 - margin, mouse_y + 32-margin, mouse_x + str_w/2+margin, mouse_y + 32 + str_h+margin, false);
	draw_set_color(c_white);
	draw_text(mouse_x - str_w / 2, mouse_y + 32, label);
}
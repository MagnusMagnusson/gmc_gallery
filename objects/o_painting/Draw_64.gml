// In Draw GUI so the label sits above every painting, not just the ones drawn before this one.
if(mouse_x > x && mouse_y > y && mouse_x < x + 150 && mouse_y < y + 150){
	var mx = device_mouse_x_to_gui(0);
	var my = device_mouse_y_to_gui(0);
	draw_set_color(c_purple);
	var margin = 8;
	var str_w = string_width(label);
	var str_h = string_height(label);
	draw_roundrect(mx - str_w/2 - margin, my + 32-margin, mx + str_w/2+margin, my + 32 + str_h+margin, false);
	draw_set_color(c_white);
	draw_text(mx - str_w / 2, my + 32, label);
}
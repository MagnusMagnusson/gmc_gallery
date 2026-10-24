if(!finished()){
	image_index = min(floor(hits/life * image_number), image_number - 1);
	hover = false;
	exit;
}

draw_set_font(fnt_EGG);
var w = string_width("reset")/2;
var cx = x + sprite_width/2;
var ty = y + sprite_height;
hover = point_in_box(mouse_x, mouse_y, cx - w, ty, cx + w, ty + string_height("reset"));
if(hover && mouse_check_button_pressed(mb_left)){
	restart();
}

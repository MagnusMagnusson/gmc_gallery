image_alpha += alpha_rate;

if(mouse_check_button_pressed(mb_left) && mouse_x > x && mouse_y > y && mouse_x < x + 150 && mouse_y < y + 150){
	global.viewing_painting = painting;
	global.painting_return_room = room;
	room_goto(rm_canvas);
}
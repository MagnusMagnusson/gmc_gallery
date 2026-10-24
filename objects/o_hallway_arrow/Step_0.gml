hover = point_in_box(mouse_x, mouse_y, x - 50, y - 36, x + 50, y + 36);
if(hover && mouse_check_button_pressed(mb_left)){
	global.hallway_index += dir;
	room_restart();
}

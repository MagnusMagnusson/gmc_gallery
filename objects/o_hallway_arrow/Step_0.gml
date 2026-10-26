hover = point_in_box(mouse_x, mouse_y, x - 50, y - 36, x + 50, y + 36);
if(hover && mouse_check_button_pressed(mb_left)){
	hallway_index_set(folder, hallway_index_get(folder) + dir);
	room_restart();
}

if(y < ystart){
	if(bounce >= 2){
		vspeed = 0;
		y = ystart;
		gravity = 0;
	} else {
		y = ystart + 1;
		vspeed = abs(vspeed) * 0.5;
		bounce++;
	}
}

if(mouse_check_button_pressed(mb_left)){
	selected_slot = -1;
	for(var i = 0; i < array_length(zones); i++){
		var zone = zones[i];
		if(mouse_x > x + zone.x0 && mouse_x < x + zone.x1 && mouse_y > y + zone.y0 && mouse_y < y + zone.y1){
			selected_slot = i;
		}
	}
	if(selected_slot == 0){
		keyboard_string = username;
	} else if (selected_slot == 1){
		keyboard_string = password;
	}
}

if(selected_slot == 0){
	username = keyboard_string;
} else if (selected_slot == 1){
	password = keyboard_string;
}
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
	selected_slot = SIGNUP_SLOTS.NONE;
	for(var i = 0; i < array_length(zones); i++){
		var zone = zones[i];
		if(mouse_x > x + zone.x0 && mouse_x < x + zone.x1 && mouse_y > y + zone.y0 && mouse_y < y + zone.y1){
			selected_slot = zone.slot;
		}
	}
	if(selected_slot == SIGNUP_SLOTS.USERNAME){
		keyboard_string = username;
	} else if (selected_slot == SIGNUP_SLOTS.PASSWORD){
		keyboard_string = password;
	} else if (selected_slot == SIGNUP_SLOTS.REGISTER){
	} else if (selected_slot == SIGNUP_SLOTS.LOGIN){
	}
}

if(selected_slot == SIGNUP_SLOTS.USERNAME){
	if(username != keyboard_string){
		username = sanitize(keyboard_string);
		keyboard_string = username;
	}
} else if (selected_slot == SIGNUP_SLOTS.PASSWORD){
	if(password != keyboard_string){
		password = sanitize(keyboard_string);
		keyboard_string = password;
	}
} else if (selected_slot == SIGNUP_SLOTS.LOGIN){
	selected_slot = SIGNUP_SLOTS.NONE;
	onSignupPressed(sb_player_login, onLogin, onLoginFailed);
} else if (selected_slot == SIGNUP_SLOTS.REGISTER){	
	selected_slot = SIGNUP_SLOTS.NONE;
	onSignupPressed(sb_player_register, onRegister, onRegisterFailed);
}
enum SIGNUP_SLOTS {
	NONE,
	USERNAME,
	PASSWORD,
	REGISTER,
	LOGIN
}

y = sprite_height + room_height;
gravity = 0.8;
gravity_direction = 90;
bounce = 0;

username = "";
password = "";

defaultUsername = "Your GMC username here, please";
defaultPassword = "Your password here, please";
selected_slot = SIGNUP_SLOTS.NONE;
keyboard_string = "";
max_length = string_length(defaultUsername);

zones = [
	{
		slot : SIGNUP_SLOTS.USERNAME,
		x0 : 25,
		y0 : 50,
		x1 : 365,
		y1 : 95
	},
	{
		slot : SIGNUP_SLOTS.PASSWORD,
		x0 : 25,
		y0 : 146,
		x1 : 365,
		y1 : 200
	},
	{
		slot : SIGNUP_SLOTS.REGISTER,
		x0 : 240,
		y0 : 210,
		x1 : 360,
		y1 : 240
	},
	{
		slot : SIGNUP_SLOTS.LOGIN,
		x0 : 60,
		y0 : 210,
		x1 : 180,
		y1 : 240
	}
]

loading = false;

sanitize = function(word){
	var valid = "1234567890ö-qwertyuiopðasdfghjklæzxcvbnm .-";
	word = string_copy(word, 0, max_length);
	return word;
}

valid_signup = function(val){
	return string_length(string_trim(val)) >= 3;
}

onLogin = method(self, function(e){
	speech_dismiss_all();
	speech_say("Welcome back, and enjoy your visit", 0, 10);
	instance_create_layer(0,0,  layer_get_id("Instances"), o_logged_in);
	instance_destroy(self);
});

onLoginFailed =  method(self, function(e){
	speech_say("I'm afraid that name and password is incorrect", 1, 10);
});

onRegister =  method(self, function(e){
	speech_dismiss_all();
	speech_say("Your ticket is ready. Enjoy your visit!",  0, 10);
	instance_create_layer(0,0,  layer_get_id("Instances"), o_logged_in);
	instance_destroy(self);
});

onRegisterFailed =  method(self, function(e){
	show_debug_message(e);
	speech_say(e.message, 1, 10);
});
clicks = 2;

onSignupPressed = method(self, function(func, success, fail){	
	selected_slot = SIGNUP_SLOTS.NONE;
	if(alarm[0]){
		clicks--;
		if(clicks == 0){
			speech_say("Clicking just once is enough.", 2, 10);
		}
		return;
	};
	
	if(!valid_signup(username)){
		speech_say(@"That's not a valid name.", 1, 10);
		return;
	}
	if(!valid_signup(password)){
		speech_say("That's not a valid password", 1, 10);
		return;
	}
	alarm[0] = 150;
	display_name = string_trim(username);
	username = string_replace(string_trim(username)," ", "_");
	password = string_trim(password);
	func(username, password, {display_name:display_name}).success(success).fail(fail);
});
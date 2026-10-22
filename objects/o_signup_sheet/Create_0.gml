y = sprite_height + room_height;
gravity = 0.8;
gravity_direction = 90;
bounce = 0;

username = "";
password = "";

defaultUsername = "Your GMC username here, please";
defaultPassword = "Your password here, please";
selected_slot = -1;
keyboard_string = "";
max_length = string_length(defaultUsername);

zones = [
	{
		x0 : 25,
		y0 : 50,
		x1 : 365,
		y1 : 95
	},
	{
		x0 : 25,
		y0 : 146,
		x1 : 365,
		y1 : 200
	}
]

sanitize = function(word){
	var valid = "1234567890ö-qwertyuiopðasdfghjklæzxcvbnm .-";
	word = string_trim(word);
	return word;
}
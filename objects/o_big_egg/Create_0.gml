#macro BIG_EGG_LIFE 100000
#macro BIG_EGG_SAVE "egg.ini"

// Kept locally for now. remaining becomes a scoreBOAT datastore shared by everyone,
// and my_hits a leaderboard entry. Once remaining reaches 0 the egg stays broken.
ini_open(BIG_EGG_SAVE);
remaining = ini_read_real("big_egg", "remaining", BIG_EGG_LIFE);
my_hits = ini_read_real("big_egg", "my_hits", 0);
ini_close();
image_speed = 0;

hit = function(){
	my_hits++;
	if(remaining > 0){
		remaining--;
		if(remaining == 0){
			instance_create_depth(x + sprite_width/2, y + sprite_height/2, depth - 1, o_yolk);
		}
	}
	ini_open(BIG_EGG_SAVE);
	ini_write_real("big_egg", "remaining", remaining);
	ini_write_real("big_egg", "my_hits", my_hits);
	ini_close();
}

// 100000 -> "100.000"
label = function(){
	var n = remaining, s = "";
	while(n >= 1000){
		s = "." + string_replace_all(string_format(n mod 1000, 3, 0), " ", "0") + s;
		n = n div 1000;
	}
	return string(n) + s;
}

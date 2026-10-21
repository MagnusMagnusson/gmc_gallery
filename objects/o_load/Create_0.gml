onSuccess = method(self, function(){
	text = "Connected. Welcome to the gallery";
	room_goto_next();
});

onFail = method(self, function(){
	text = "Unable to connect. Try again later";
});

text = "Connecting to the gallery...";
var gi = string_decrypt(scoreboat_game_id, __mkscr(31, 32));
var pf = string_decrypt(scoreboat_prefix, __mkscr(41, 32));
var sc = string_decrypt(scoreboat_secret, __mkscr(52, 32));
sb_init(gi, pf, sc, onSuccess, onFail);
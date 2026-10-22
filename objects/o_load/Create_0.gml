failed = false;

onPlayerResumeFinish = method(self, function(e){
	alarm[4] = 30;
});

onInitSuccess = method(self, function(){
	text = "Connected. Welcome to the gallery";
	sb_player_resume(onPlayerResumeFinish, onPlayerResumeFinish);
});

onInitFail = method(self, function(){
	text = "Unable to connect. Try again later";
	failed = true;
	alarm[3] = speech_is_talking() ? 90 : 30;
	alarm[0] = -1;
	alarm[1] = -1;
});

text = "Connecting...";
primary_bubble = noone;
secondary_bubble = noone;
var gi = scoreboat_game_id;
var pf = scoreboat_prefix;
var sc = scoreboat_secret;

sb_init(gi, pf, sc, onInitSuccess, onInitFail);

alarm[0] = 30;
scores = [];
loaded = false;
error = false;

onLoaded = method(self, function(data){
	scores = data.scores;
	loaded = true;
});

onFail = method(self, function(error){
	error = true;
	loaded = false;
})

loadScores = method(self, function(){
	loaded = false;
	error = false;
	sb_leaderboard_scores(scoreboat_leaderboard_small_egg, {}, onLoaded, onFail);
});

string_format_ext = function(v, t, d, s){
	return string_replace(string_format(v, t, d)," ",s);
}

formatTime = function(time){
	var s = (time div 1000) % 60;
	var m = (time div (1000 * 60));
	var ms = time % 1000;
	return string("{0}:{1}.{2}",string_format_ext(m, 2, 0, "0"), string_format_ext(s, 2, 0, "0"), ms);
}

loadScores();
var ONE_MINUTE = 60 * 60 * 1;
alarm[0] = ONE_MINUTE;
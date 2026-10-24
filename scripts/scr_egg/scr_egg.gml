#macro BIG_EGG_LIFE 100000
#macro BIG_EGG_KEY "egg"
#macro BIG_EGG_FLUSH 120
#macro BIG_EGG_REFRESH 600

function egg_submit_small(eggs, ms){
	sb_leaderboard_submit(scoreboat_leaderboard_small_egg, "", eggs, { secondary_score: ms }, function(e){
		o_leaderboard_egg.loadScores();
	}, function(e){
		show_debug_message("small egg submit failed: {0}", e.message);
	});
}

global.egg_hits = { base: undefined, added: 0, loading: false };
global.egg_hits.submit = method(global.egg_hits, function(){
	sb_leaderboard_submit(scoreboat_leaderboard_big_egg, "", base + added);
});
global.egg_hits.onLoaded = method(global.egg_hits, function(page){
	loading = false;
	var scores = page[$ "scores"] ?? [];
	base = array_length(scores) > 0 ? scores[0].score : 0;
	if(added > 0) submit();
});
global.egg_hits.onLoadFailed = method(global.egg_hits, function(e){
	loading = false;
});

// Counts hits the big egg took from this player, once Scoreboat has them.
function egg_hits_add(amount){
	var h = global.egg_hits;
	h.added += amount;
	if(!is_undefined(h.base)){
		h.submit();
	} else if(!h.loading){
		h.loading = true;
		sb_leaderboard_scores(scoreboat_leaderboard_big_egg, { player: sb_player().id, limit: 1 }, h.onLoaded, h.onLoadFailed);
	}
}

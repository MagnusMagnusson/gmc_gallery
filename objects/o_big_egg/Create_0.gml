image_speed = 0;
known = false;
offline = false;
life = BIG_EGG_LIFE;
hits = 0;
pending = 0;
sending = 0;
remaining = life;
broken = false;
flush_timer = 0;
refresh_timer = 0;
shaking = 0;

recount = function(){
	remaining = max(0, life - hits - pending - sending);
	if(remaining == 0 && !broken){
		broken = true;
		instance_create_depth(x + sprite_width/2, y + sprite_height/2, depth - 1, o_yolk);
	}
}

applyRecord = function(record){
	var data = record[$ "data"] ?? {};
	life = data[$ "life"] ?? BIG_EGG_LIFE;
	hits = data[$ "hits"] ?? 0;
	if(!known && life - hits <= 0){
		// Broken before we got here: no yolk, and nothing to send.
		broken = true;
		pending = 0;
	}
	known = true;
	recount();
}

hit = function(){
	if(broken) return;
	pending++;
	shaking = 30;
	recount();
}

// The callbacks can come back after the egg has left the room.
net = { owner: id };
net.onRecord = method(net, function(record){
	if(instance_exists(owner)) owner.applyRecord(record);
});
net.onFailed = method(net, function(e){
	if(instance_exists(owner)) owner.offline = true;
});
net.load = method(net, function(){
	sb_datastore_get(scoreboat_datastore_egg, BIG_EGG_KEY, onRecord, onFailed);
});

send = function(){
	flush_timer = 0;
	sending = pending;
	pending = 0;
	var job = { owner: id, amount: sending };
	job.onSent = method(job, function(record){
		egg_hits_add(amount);
		if(!instance_exists(owner)) return;
		owner.sending = 0;
		owner.applyRecord(record);
	});
	job.onFailed = method(job, function(e){
		if(!instance_exists(owner)) return;
		owner.pending += owner.sending;
		owner.sending = 0;
	});
	sb_datastore_incr(scoreboat_datastore_egg, BIG_EGG_KEY, "hits", sending, job.onSent, job.onFailed);
}

net.load();

// 100000 -> "100.000"
label = function(){
	if(!known) return offline ? "offline" : "...";
	var n = remaining, s = "";
	while(n >= 1000){
		s = "." + string_replace_all(string_format(n mod 1000, 3, 0), " ", "0") + s;
		n = n div 1000;
	}
	return string(n) + s;
}

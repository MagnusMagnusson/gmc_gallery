// Hits each egg in the chain takes. The timer starts when the first one breaks.
egg_lives = [1, 3, 10, 100];
image_speed = 0;
hover = false;

restart = function(){
	stage = 0;
	hits = 0;
	life = egg_lives[0];
	start_time = undefined;
}
restart();

finished = function(){
	return stage >= array_length(egg_lives);
}

elapsed = function(){
	return is_undefined(start_time) ? 0 : current_time - start_time;
}

hit = function(){
	if(finished()) return;
	hits++;
	if(hits < life) return;

	instance_create_depth(x + sprite_width/2, y + sprite_height/2, depth - 1, o_yolk);
	if(stage == 0){
		start_time = current_time;
	} else {
		egg_submit_small(stage, elapsed());
	}
	stage++;
	hits = 0;
	if(!finished()) life = egg_lives[stage];
}

// The timer, or "reset" once the last egg is broken. Text hangs below the egg.
label = function(){
	if(finished()) return "reset";
	var ms = elapsed();
	return string("{0}:{1}.{2}",
		ms div 60000,
		string_replace_all(string_format((ms div 1000) mod 60, 2, 0), " ", "0"),
		string_replace_all(string_format((ms div 10) mod 100, 2, 0), " ", "0")
	);
}

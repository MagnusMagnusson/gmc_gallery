var onPaintingLoad = method(self, function(painting){
	var xx = 0;
	var yy = 0;
	var i = 100;
	var bad = [o_painting, o_hallway];
	while(
			instance_position(xx, yy, bad) ||
			instance_position(xx + 150, yy, bad) ||
			instance_position(xx, yy + 150, bad) ||
			instance_position(xx + 150, yy + 150, bad) ||
			instance_position(xx + 75, yy + 75, bad)
		){
		xx = irandom(room_width);
		yy = irandom(room_height);
		i--;
		if(i < 0){
			break;
		}
	}
	instance_create_depth(xx , yy, layer_get_id("Instances"), o_painting, {
		painting: painting,
	})
});

paintings_fetch(onPaintingLoad);
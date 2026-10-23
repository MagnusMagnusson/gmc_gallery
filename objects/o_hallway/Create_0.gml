var onPaintingLoad = method(self, function(painting, cached){
	var w = 155;
	var h = 135 
	var wl = (room_width - w) / w;
	var hl = 450 / h;
	var xx = irandom(wl) * w;
	var yy = irandom(hl) * h;
	var i = 100;
	var bad = [o_painting, o_hallway];
	while(
			instance_position(xx, yy, bad) ||
			instance_position(xx + w, yy, bad) ||
			instance_position(xx, yy + h, bad) ||
			instance_position(xx + w, yy + h, bad) ||
			instance_position(xx + w/2, yy + h/2, bad)
		){
		xx = irandom(wl) * w;
		yy = irandom(hl) * h;
		i--;
		if(i < 0){
			break;
		}
	}
	instance_create_layer(xx, yy, "Instances", o_painting, {
		painting: painting,
		cached: cached,
	})
});

paintings_fetch(onPaintingLoad);
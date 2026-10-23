sprite_index = painting.sprite;
var ratio = 150 / sprite_get_width(sprite_index);
image_xscale = ratio;
image_yscale = ratio;
image_alpha = random_range(-1, 0);
alpha_rate = random_range(1/30, 1/90);
/*
{ 
	file : 
		{ id : "bdThpjOjHht2", 
		created : "2026-10-22T22:19:44.125945+00:00", 
		size : 139057, 
		creator : "RqwzSBtTjxPf", 
		sha256 : undefined, 
		updated : "2026-10-22T22:19:44.125959+00:00", 
		path : "/paintings/RqwzSBtTjxPf_1792707581_5441.painting",
		name : "RqwzSBtTjxPf_1792707581_5441.painting", 
		content_type : "application/x-gmc-painting" 
		}, 
	author_id : "RqwzSBtTjxPf", 
	width : 736, 
	height : 640, 
	author : "Mr_Magnus", 
	sprite : ref sprite __newsprite4, 
	title : "SUN!" 
}
*/
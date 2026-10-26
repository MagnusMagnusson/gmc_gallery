sprite_index = painting.sprite;
var xratio = 150 / sprite_get_width(sprite_index);
var yratio = 131 / sprite_get_height(sprite_index);
image_xscale = xratio;
image_yscale = yratio;
image_alpha = cached ? 1 : random_range(-1, 0);
alpha_rate = random_range(1/30, 1/90);
title = painting.title;
author = painting.author;
label = string(@"'{0}'
by {1}", title, author);
x += 64;
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
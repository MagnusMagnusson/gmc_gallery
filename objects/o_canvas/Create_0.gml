// The surface matches the stretched sprite, so one surface pixel is one screen pixel
w = sprite_width;
h = sprite_height;
canvas = new Canvas(w, h);

var shown = global.viewing_painting;
if(!is_undefined(shown)){
	surface_set_target(canvas.get_surface());
	draw_sprite_stretched(shown.sprite, 0, 0, 0, w, h);
	surface_reset_target();
	canvas.save();
}

painting = false;
last_x = 0;
last_y = 0;

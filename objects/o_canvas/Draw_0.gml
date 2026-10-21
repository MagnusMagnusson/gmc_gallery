// Drop shadow, for cool canvas points.
draw_set_colour(c_black);
draw_set_alpha(0.25);
draw_rectangle(x + 6, y + 6, x + w + 5, y + h + 5, false);
draw_set_alpha(1);

draw_surface(canvas.get_surface(), x, y);

if !o_paint.can_edit exit;
// Brush outline under the cursor
var _paint = global.paint;
if (point_in_box(mouse_x, mouse_y, x, y, x + w, y + h)) {
	switch (_paint.tool) {
		case Tool.Brush:
		case Tool.Eraser:
			draw_set_colour(c_gray);
			draw_circle(mouse_x, mouse_y, _paint.size / 2, true);
			break;
		case Tool.Spray:
			draw_set_colour(c_gray);
			draw_circle(mouse_x, mouse_y, _paint.size, true);
			break;
	}
}
draw_set_colour(c_white);

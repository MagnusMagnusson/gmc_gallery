if !o_paint.can_edit exit;
var _paint = global.paint;
if (_paint.picker_open) exit;

var _mx = mouse_x - x;
var _my = mouse_y - y;
var _over = point_in_box(_mx, _my, 0, 0, w, h);

// Mouse wheel over the canvas changes the brush size
if (_over) {
	if (mouse_wheel_up()) _paint.size++;
	if (mouse_wheel_down()) _paint.size--;
	_paint.size = clamp(_paint.size, PAINT_SIZE_MIN, PAINT_SIZE_MAX);
}

if (_over && mouse_check_button_pressed(mb_left)) {
	switch (_paint.tool) {
		case Tool.Fill:
			canvas.fill(_mx, _my, _paint.colour);
			break;
		case Tool.Picker:
			_paint.colour = canvas.pick(_mx, _my);
			break;
		default:
			painting = true;
			last_x = _mx;
			last_y = _my;
			break;
	}
}

if (painting) {
	canvas.stroke(_paint.tool, last_x, last_y, _mx, _my, _paint.colour, _paint.size);
	last_x = _mx;
	last_y = _my;
	if (!mouse_check_button(mb_left)) {
		painting = false;
		canvas.save();
	}
}

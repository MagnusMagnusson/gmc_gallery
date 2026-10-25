
if !can_edit exit;
var _paint = global.paint;
if (_paint.picker_open) exit;

var _click = mouse_check_button_pressed(mb_left);

for (var _i = 0; _i < array_length(tools); _i++) {
	var _bx = x + (_i % columns) * (button_w + gap);
	var _by = tools_y + (_i div columns) * (button_h + gap);
	if ((!_paint.typing && !_paint.naming && keyboard_check_pressed(tools[_i].key))
	|| (_click && point_in_box(mouse_x, mouse_y, _bx, _by, _bx + button_w, _by + button_h))) {
		_paint.tool = tools[_i].tool;
	}
}

// Size slider
if (_click && point_in_box(mouse_x, mouse_y, x - 6, slider_y, x + width + 6, slider_y + slider_h)) dragging_size = true;
if (dragging_size) {
	if (mouse_check_button(mb_left)) {
		var _t = clamp((mouse_x - x) / width, 0, 1);
		_paint.size = round(lerp(PAINT_SIZE_MIN, PAINT_SIZE_MAX, _t));
	} else {
		dragging_size = false;
	}
}

if (_click && point_in_box(mouse_x, mouse_y, paper_button_x, paper_y, x + width, paper_y + button_h)) {
	with (o_canvas) canvas.paper = _paint.colour;
}

// Z undoes, Y or Shift+Z redoes, so Ctrl+Z and Ctrl+Y work too. Not in the middle of a stroke.
var _keys = !_paint.typing && !_paint.naming;
var _z = _keys && keyboard_check_pressed(ord("Z"));
var _undo = (_z && !keyboard_check(vk_shift))
	|| (_click && point_in_box(mouse_x, mouse_y, x, clear_y, x + third_w, clear_y + button_h));
var _redo = (_z && keyboard_check(vk_shift)) || (_keys && keyboard_check_pressed(ord("Y")))
	|| (_click && point_in_box(mouse_x, mouse_y, x + third_w + gap, clear_y, x + third_w * 2 + gap, clear_y + button_h));
with (o_canvas) {
	if (painting) break;
	if (_undo) canvas.undo();
	if (_redo) canvas.redo();
}

if (_click && point_in_box(mouse_x, mouse_y, x + width - third_w, clear_y, x + width, clear_y + button_h)) {
	with (o_canvas) canvas.clear();
}

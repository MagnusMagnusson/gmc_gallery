if(viewing){
	if(mouse_check_button_pressed(mb_left) && point_in_box(mouse_x, mouse_y, x, leave_y, x + width, leave_y + button_h)){
		room_goto(leave_to);
	}
	exit;
}

if (instance_exists(o_paint) && !o_paint.can_edit) exit;
var _paint = global.paint;
about.active = !_paint.picker_open;
if (_paint.picker_open) exit;

var _click = mouse_check_button_pressed(mb_left);
var _in_field = point_in_box(mouse_x, mouse_y, x, field_y, x + width, field_y + field_h);

// Title field. A click elsewhere is checked first, before keyboard_string is read, as the
// hex field may have just claimed it.
if (editing) {
	if (keyboard_check_pressed(vk_enter) || (_click && !_in_field)) {
		editing = false;
	} else if (focus_frame) {
		keyboard_string = title;
		focus_frame = false;
	} else {
		title = string_copy(keyboard_string, 1, PAINTING_TITLE_MAX);
		keyboard_string = title;
	}
} else if (_click && _in_field) {
	editing = true;
	focus_frame = true;
	keyboard_string = title;
}
_paint.naming = editing || about.focused;

if (_click && !saving && !deleting && point_in_box(mouse_x, mouse_y, x, save_y, x + width, save_y + button_h)) {
	save();
}

var _can_delete = !is_undefined(saved_path) && !saving && !deleting;
if (_click && _can_delete && point_in_box(mouse_x, mouse_y, x, delete_y, x + width, delete_y + button_h)) {
	deleteClicked();
}

if (_click && point_in_box(mouse_x, mouse_y, x, leave_y, x + width, leave_y + button_h)) {
	delete_confirm = false;
	if (unsaved() && !leave_confirm) {
		leave_confirm = true;
		status = "This painting has unsaved changes. Click again to leave anyway.";
	} else {
		_paint.naming = false;
		room_goto(leave_to);
	}
}

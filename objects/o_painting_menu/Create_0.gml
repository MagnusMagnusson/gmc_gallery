// Title field, save and leave, to the right of the canvas.
width = 230;
field_h = 28;
button_h = 32;
field_y = y + 20;
save_y = field_y + field_h + 12;
leave_y = save_y + button_h + 6;
delete_y = leave_y + button_h + 6;
status_y = delete_y + button_h + 12;

// Where Leave goes. The gallery hallway, once there is one.
leave_to = rm_hallway;

title = "";
editing = false;
// The first step of editing claims keyboard_string back from the hex field, which may have
// rewritten it on the same step.
focus_frame = false;

saving = false;
status = "";
leave_confirm = false;
deleting = false;
delete_confirm = false;
// Set by the first save; later saves overwrite the same painting.
saved_path = undefined;
saved_edits = instance_exists(o_canvas) ? o_canvas.canvas.edits : 0;

unsaved = function() {
	return instance_exists(o_canvas) && o_canvas.canvas.edits != saved_edits;
};

save = function() {
	var _title = string_trim(title);
	if (_title == "") {
		status = "Give your painting a name first.";
		return;
	}
	if (!sb_player_signed_in()) {
		status = "You need to be signed in to save.";
		return;
	}
	saving = true;
	leave_confirm = false;
	delete_confirm = false;
	status = "Saving...";

	var _canvas = o_canvas.canvas;
	// The callbacks can arrive after this instance has left the room.
	var _job = { owner: id, edits: _canvas.edits, path: saved_path ?? painting_new_path() };
	_job.on_success = method(_job, function(_file) {
		if (!instance_exists(owner)) return;
		owner.saving = false;
		owner.saved_path = path;
		owner.saved_edits = edits;
		owner.status = "Saved! It will hang in the gallery.";
	});
	_job.on_fail = method(_job, function(_error) {
		if (!instance_exists(owner)) return;
		owner.saving = false;
		owner.status = "Couldn't save: " + string(_error.message);
	});
	painting_upload(_canvas.get_surface(), _title, _job.path, _job.on_success, _job.on_fail);
};

remove = function() {
	if (is_undefined(saved_path)) return;
	deleting = true;
	delete_confirm = false;
	leave_confirm = false;
	status = "Taking it down...";

	var _job = { owner: id, path: saved_path };
	_job.on_success = method(_job, function(_result) {
		if (!instance_exists(owner)) return;
		owner.deleting = false;
		if (owner.saved_path == path) owner.saved_path = undefined;
		// What's on the canvas is no longer saved anywhere.
		owner.saved_edits = -1;
		owner.status = "Deleted. It's off the gallery walls.";
	});
	_job.on_fail = method(_job, function(_error) {
		if (!instance_exists(owner)) return;
		owner.deleting = false;
		owner.status = "Couldn't delete: " + string(_error.message);
	});
	painting_delete(_job.path, _job.on_success, _job.on_fail);
};

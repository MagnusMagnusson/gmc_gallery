
function Canvas(_w, _h, _paper = c_white) constructor {
	w = _w;
	h = _h;
	paper = _paper;
	// Goes up with every change, so others can tell whether the painting changed since they last looked.
	edits = 0;
	surface = surface_create(w, h);
	//In case the surface is lost. 
	backup = buffer_create(w * h * 4, buffer_fixed, 1);

	function get_surface() {
		if (!surface_exists(surface)) {
			surface = surface_create(w, h);
			buffer_set_surface(backup, surface, 0);
		}
		return surface;
	}

	function save() {
		buffer_get_surface(backup, get_surface(), 0);
		edits++;
	}

	function clear(_colour = paper) {
		surface_set_target(get_surface());
		draw_clear_alpha(_colour, 1);
		surface_reset_target();
		save();
	}

	function free() {
		if (surface_exists(surface)) surface_free(surface);
		buffer_delete(backup);
	}

	function fromImage(image) {
		buffer_set_surface(image.buffer, get_surface(), image.offset);
		save();
	}

	function toImage(image) {
		buffer_get_surface(image.buffer, get_surface(), image.offset);
	}

	function pick(_x, _y) {
		return surface_getpixel(get_surface(), floor(_x), floor(_y));
	}

	// Paints one segment of a stroke from (_x1, _y1) to (_x2, _y2) with a brush-type tool.
	function stroke(_tool, _x1, _y1, _x2, _y2, _colour, _size) {
		_x1 = floor(_x1); _y1 = floor(_y1);
		_x2 = floor(_x2); _y2 = floor(_y2);
		var _old = draw_get_colour();
		surface_set_target(get_surface());
		draw_set_colour(_tool == Tool.Eraser ? paper : _colour);
		switch (_tool) {
			case Tool.Pencil:
				draw_line(_x1, _y1, _x2, _y2);
				draw_point(_x2, _y2);
				break;
			case Tool.Brush:
			case Tool.Eraser:
				// Thick line plus round caps so segments join smoothly
				var _r = _size / 2;
				draw_line_width(_x1, _y1, _x2, _y2, _size);
				draw_circle(_x1, _y1, _r, false);
				draw_circle(_x2, _y2, _r, false);
				break;
			case Tool.Spray:
				repeat (max(4, _size)) {
					var _d = random(_size);
					var _a = random(360);
					draw_point(_x2 + lengthdir_x(_d, _a), _y2 + lengthdir_y(_d, _a));
				}
				break;
		}
		surface_reset_target();
		draw_set_colour(_old);
	}

	// Scanline flood fill of the region connected to (_x, _y) that matches its colour exactly.
	function fill(_x, _y, _colour) {
		_x = floor(_x);
		_y = floor(_y);
		if (_x < 0 || _y < 0 || _x >= w || _y >= h) return;

		var _buf = backup;
		buffer_get_surface(_buf, get_surface(), 0);
		var _target = buffer_peek(_buf, (_y * w + _x) * 4, buffer_u32);
		var _fill = colour_to_pixel(_colour);
		if (_target == _fill) return;

		var _stack = [_x, _y];
		while (array_length(_stack) > 0) {
			var _sy = array_pop(_stack);
			var _sx = array_pop(_stack);
			var _row = _sy * w;
			if (buffer_peek(_buf, (_row + _sx) * 4, buffer_u32) != _target) continue;
			var _lx = _sx;
			while (_lx > 0 && buffer_peek(_buf, (_row + _lx - 1) * 4, buffer_u32) == _target) _lx--;
			
			var _up = false;
			var _down = false;
			for (var _px = _lx; _px < w && buffer_peek(_buf, (_row + _px) * 4, buffer_u32) == _target; _px++) {
				buffer_poke(_buf, (_row + _px) * 4, buffer_u32, _fill);
				if (_sy > 0) {
					var _hit_up = buffer_peek(_buf, (_row - w + _px) * 4, buffer_u32) == _target;
					if (_hit_up && !_up) array_push(_stack, _px, _sy - 1);
					_up = _hit_up;
				}
				if (_sy < h - 1) {
					var _hit_down = buffer_peek(_buf, (_row + w + _px) * 4, buffer_u32) == _target;
					if (_hit_down && !_down) array_push(_stack, _px, _sy + 1);
					_down = _hit_down;
				}
			}
		}

		buffer_set_surface(_buf, surface, 0);
		edits++;
	}

	clear();
}

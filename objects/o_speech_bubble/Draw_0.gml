// Pop out of the speaker's mouth: overshoot a little on the way in, shrink
// straight back on the way out.
var _t = appear;
var _scale = closing ? _t * _t : 1 + 2.70158 * power(_t - 1, 3) + 1.70158 * power(_t - 1, 2);
matrix_set(matrix_world, matrix_multiply(
	matrix_build(-tail_x, -tail_y, 0, 0, 0, 0, 1, 1, 1),
	matrix_build(tail_x, tail_y, 0, 0, 0, 0, _scale, _scale, 1)
));

var _prev_colour = draw_get_colour();
var _prev_font = draw_get_font();
var _prev_halign = draw_get_halign();
var _prev_valign = draw_get_valign();
draw_set_circle_precision(48);

var _o = SPEECH_OUTLINE;
var _r = min(SPEECH_CORNER_RADIUS, (y2 - y1) / 2, (x2 - x1) / 2);

// The tail's base sits inside the body, where the body hides the seam.
var _cx = clamp(tail_x, x1 + _r, x2 - _r);
var _cy = clamp(tail_y, y1 + _r, y2 - _r);
var _dir = point_direction(_cx, _cy, tail_x, tail_y);
var _hw = min(SPEECH_TAIL_WIDTH / 2, _r);
var _ax = _cx + lengthdir_x(_hw, _dir + 90);
var _ay = _cy + lengthdir_y(_hw, _dir + 90);
var _bx = _cx + lengthdir_x(_hw, _dir - 90);
var _by = _cy + lengthdir_y(_hw, _dir - 90);

// Outline: the same shapes in black, fattened by the outline width.
draw_set_colour(c_black);
draw_triangle(_ax, _ay, _bx, _by, tail_x, tail_y, false);
draw_line_width(_ax, _ay, tail_x, tail_y, _o * 2);
draw_line_width(_bx, _by, tail_x, tail_y, _o * 2);
draw_circle(tail_x, tail_y, _o, false);
draw_roundrect_ext(x1 - _o, y1 - _o, x2 + _o, y2 + _o, _r + _o, _r + _o, false);

draw_set_colour(c_white);
draw_triangle(_ax, _ay, _bx, _by, tail_x, tail_y, false);
draw_roundrect_ext(x1, y1, x2, y2, _r, _r, false);

draw_set_colour(c_black);
draw_set_font(SPEECH_FONT);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text_transformed(x1 + SPEECH_PADDING, y1 + SPEECH_PADDING, string_copy(lines, 1, floor(shown)), SPEECH_TEXT_SCALE, SPEECH_TEXT_SCALE, 0);

draw_set_colour(_prev_colour);
draw_set_font(_prev_font);
draw_set_halign(_prev_halign);
draw_set_valign(_prev_valign);
matrix_set(matrix_world, matrix_build_identity());

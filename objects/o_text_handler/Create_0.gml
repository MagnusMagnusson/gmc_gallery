// A text field that wraps onto several lines. Click it to type; click elsewhere, Enter or
// Escape to stop. Whoever creates it sets width, height, max_length and placeholder, and
// set_text() for a starting text.
text = "";
insert_position = 0;
keyboard_string = ""; // clean up the keyboard_string from earlier
max_length = 30;
width = 230;
height = 28;
padding = 8;
placeholder = "";

focused = false;
// While false the field ignores input and lets go of focus, e.g. under the colour picker.
active = true;
// The step after focusing clears keyboard_string again, as another field may have rewritten
// it on the same step.
focus_frame = false;

// The wrapped text: { start, text } per line, start being how many characters come before it.
lines = [];
// First line shown, when there are more lines than fit.
top_line = 0;

// still in Create event
repeatable_keys = [vk_left, vk_right, vk_up, vk_down, vk_backspace, vk_delete];
repeatable_count = array_length(repeatable_keys);

repeat_key = undefined;
repeat_time = 0;
repeat_delay = 15; // the number of frames after which repetition should be detected
repeat_period = 3; // the number of frames between subsequent input repetitions

// updates the state of the repeated inputs
check_repeats = function() {
    // if any new repeated input key is pressed
    // it becaomes the new repetition target
    for (var i = 0; i < repeatable_count; i++) {
        if (keyboard_check_pressed(repeatable_keys[i])) {
            repeat_key = repeatable_keys[i];
            repeat_time = 0;
            return;
        }
    }

    if (is_undefined(repeat_key))
        return;

    if (keyboard_check(repeat_key)) {
        // keep increasing the repeat timer while holding down the key
        repeat_time++;
    } else {
        // while the key is no longer held down, stop the repetition
        repeat_key = undefined;
        repeat_time = 0;
    }
}

// checks whether an input repetition is made for the given key
// in the current frame
is_repeated = function(_key) {
    if (repeat_key != _key)
        return false; // the key isn't a target of repetition
    else if (repeat_time == 0)
        return true; // the key has just been pressed
    else if (repeat_time < repeat_delay)
        return false; // waiting for start of repetition
    else
        return (repeat_time - repeat_delay) mod repeat_period == 0; // performing repetition every X frames
}

// handling the cursor "blinking" at the current input position
blink = 0;
blink_max = 40;

focus = function() {
    focused = true;
    focus_frame = true;
    keyboard_string = "";
    blink = 0;
}

unfocus = function() {
    focused = false;
    repeat_key = undefined;
    top_line = 0;
}

set_text = function(_text) {
    text = string_copy(_text, 1, max_length);
    insert_position = string_length(text);
    layout();
}

// Breaks the text into lines that fit the field, after a space where there is one.
layout = function() {
    draw_set_font(fnt_paint_ui_label);
    var _w = width - padding * 2;
    var _len = string_length(text);
    var _start = 0;
    lines = [];
    do {
        var _n = 0;
        var _space = 0;
        while (_start + _n < _len && string_width(string_copy(text, _start + 1, _n + 1)) <= _w) {
            _n++;
            if (string_char_at(text, _start + _n) == " ") _space = _n;
        }
        if (_start + _n < _len && _space > 0) _n = _space;
        if (_n == 0 && _start < _len) _n = 1; // a single character wider than the field
        array_push(lines, { start: _start, text: string_copy(text, _start + 1, _n) });
        _start += _n;
    } until (_start >= _len);
}

line_height = function() {
    draw_set_font(fnt_paint_ui_label);
    return string_height("M");
}

visible_lines = function() {
    return max(1, (height - padding * 2) div line_height());
}

// The line the cursor is on. At a wrap it belongs to the start of the next line.
line_of = function(_position) {
    for (var i = array_length(lines) - 1; i > 0; i--) {
        if (lines[i].start <= _position) return i;
    }
    return 0;
}

// The position on a line closest to an x offset from the left of the text.
position_at = function(_line, _x) {
    draw_set_font(fnt_paint_ui_label);
    var _l = lines[_line];
    var _last = string_length(_l.text);
    // Except on the last line, the end of a line is the start of the next one.
    if (_line < array_length(lines) - 1 && _last > 0) _last--;
    var _best = 0;
    for (var k = 1; k <= _last; k++) {
        if (abs(string_width(string_copy(_l.text, 1, k)) - _x) < abs(string_width(string_copy(_l.text, 1, _best)) - _x)) _best = k;
    }
    return _l.start + _best;
}

cursor_x = function() {
    draw_set_font(fnt_paint_ui_label);
    var _l = lines[line_of(insert_position)];
    return string_width(string_copy(_l.text, 1, insert_position - _l.start));
}

// Puts the cursor under the mouse.
place_cursor = function() {
    var _line = clamp(top_line + floor((mouse_y - y - padding) / line_height()), 0, array_length(lines) - 1);
    insert_position = position_at(_line, mouse_x - x - padding);
}

layout();

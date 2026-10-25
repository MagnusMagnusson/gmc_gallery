if (!active) {
    if (focused) unfocus();
    exit;
}

var _click = mouse_check_button_pressed(mb_left);
var _inside = point_in_box(mouse_x, mouse_y, x, y, x + width, y + height);

// Focus. A click elsewhere is checked before keyboard_string is read, as another field may
// have just claimed it.
if (!focused) {
    if (_click && _inside) {
        focus();
        place_cursor();
    }
    exit;
}
if ((_click && !_inside) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
    unfocus();
    exit;
}
if (focus_frame) {
    keyboard_string = "";
    focus_frame = false;
    exit;
}
if (_click) place_cursor();

var _changed = false;

// handling newly added characters with keyboard_string
if (keyboard_string != "") {

    // going through each accumulated character and adding it to the input text
    string_foreach(keyboard_string, function(_character) {
        // printable ASCII only
        if (ord(_character) < 32 || ord(_character) >= 128)
            return;

        // don't add any new characters if the input string is already long enough
        if (string_length(text) >= max_length)
            return;

        // append the character to the text
        if (insert_position < string_length(text))
            text = string_insert(_character, text, insert_position + 1);
        else
            text += _character;

        insert_position++;
    });

    // with all new characters handled, clear the accumulated text
    keyboard_string = "";
    _changed = true;
}

// updating the state of repeatable keys
check_repeats();

// deleting characters via backspace and delete
if (is_repeated(vk_backspace) && insert_position > 0) {
    text = string_delete(text, insert_position, 1);
    insert_position--;
    _changed = true;
}

if (is_repeated(vk_delete) && insert_position < string_length(text)) {
    text = string_delete(text, insert_position + 1, 1);
    _changed = true;
}

if (_changed) layout();

// moving the cursor
if (is_repeated(vk_left))
    insert_position--;
else if (is_repeated(vk_right))
    insert_position++;

insert_position = clamp(insert_position, 0, string_length(text));

var _line = line_of(insert_position);
if (is_repeated(vk_up) && _line > 0) {
    insert_position = position_at(_line - 1, cursor_x());
} else if (is_repeated(vk_down) && _line < array_length(lines) - 1) {
    insert_position = position_at(_line + 1, cursor_x());
}
if (keyboard_check_pressed(vk_home)) insert_position = lines[line_of(insert_position)].start;
if (keyboard_check_pressed(vk_end)) insert_position = position_at(line_of(insert_position), width);

// keeping the cursor's line in view
_line = line_of(insert_position);
top_line = clamp(top_line, _line - visible_lines() + 1, _line);

// increasing the blink cursor timer, and showing it straight away while moving
blink++;
blink = blink mod blink_max;
if (_changed || !is_undefined(repeat_key)) blink = 0;

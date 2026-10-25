var _accent = make_colour_rgb(70, 110, 200);

draw_set_alpha(1);
draw_set_font(fnt_paint_ui_label);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Background, with a thicker accent border while typing, like the title field
draw_set_colour(c_white);
draw_rectangle(x, y, x + width - 1, y + height - 1, false);
draw_set_colour(focused ? _accent : c_dkgray);
draw_rectangle(x, y, x + width - 1, y + height - 1, true);
if (focused) draw_rectangle(x + 1, y + 1, x + width - 2, y + height - 2, true);

var _lh = line_height();
if (text == "" && !focused) {
    draw_set_colour(c_gray);
    draw_text_ext(x + padding, y + padding, placeholder, _lh, width - padding * 2);
} else {
    draw_set_colour(c_black);
    var _last = min(array_length(lines), top_line + visible_lines());
    for (var i = top_line; i < _last; i++) {
        draw_text(x + padding, y + padding + (i - top_line) * _lh, lines[i].text);
    }

    // showing the input cursor
    if (focused && blink < blink_max div 2) {
        var _cx = x + padding + cursor_x();
        var _cy = y + padding + (line_of(insert_position) - top_line) * _lh;
        draw_line_width(_cx, _cy, _cx, _cy + _lh, 2);
    }
}

draw_set_colour(c_white);

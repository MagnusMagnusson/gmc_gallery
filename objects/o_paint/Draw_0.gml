if !can_edit exit;
draw_toolbox();
draw_size_slider();
draw_canvas_color();
draw_canvas_color();
ui_button(x, clear_y, x + third_w, clear_y + button_h, "Undo", false);
ui_button(x + third_w + gap, clear_y, x + third_w * 2 + gap, clear_y + button_h, "Redo", false);
ui_button(x + width - third_w, clear_y, x + width, clear_y + button_h, "Clear", false);
draw_set_colour(c_white);

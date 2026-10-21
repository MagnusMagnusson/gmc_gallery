if !can_edit exit;
draw_toolbox();
draw_size_slider();
draw_canvas_color();
draw_canvas_color();
//Clear. 
ui_button(x, clear_y, x + width, clear_y + button_h, "Clear", false);
draw_set_colour(c_white);

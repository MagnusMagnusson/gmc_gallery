var status = global.admin.status;
if(status == "") exit;

draw_set_font(fnt_paint_ui_label);
var w = string_width(status) + 16;
var h = string_height(status) + 16;
draw_set_colour(c_black);
draw_set_alpha(0.75);
draw_rectangle(0, 0, w, h, false);
draw_set_alpha(1);
draw_set_colour(c_white);
draw_text(8, 8, status);

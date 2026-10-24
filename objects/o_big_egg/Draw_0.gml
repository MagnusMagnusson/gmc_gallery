if(remaining > 0) draw_self();

draw_set_font(fnt_EGG);
draw_set_halign(fa_center);
draw_set_colour(c_ltgray);
draw_text(x + sprite_width/2, y + sprite_height, label());
draw_set_halign(fa_left);

draw_self();
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var dname = "";
var dpass = "";
if(username == "" && selected_slot != 0){
	draw_set_color(c_gray);
	dname = defaultUsername;
} else {
	draw_set_color(c_black);
	dname = username;
}
draw_text(x + sprite_width / 2, y + 72, dname);
if(password == "" && selected_slot != 1){
	draw_set_color(c_gray);
	dpass = defaultPassword;
} else {
	draw_set_color(c_black);
	dpass = string_repeat("?", string_length(password));
}
draw_text(x + sprite_width / 2, y + 172, dpass);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(c_red);
for(var i = 0; i < array_length(zones); i++){
	var zone = zones[i];
	draw_rectangle(x + zone.x0, y + zone.y0, x + zone.x1, y + zone.y1, true);
}
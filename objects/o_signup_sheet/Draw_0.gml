if alarm[0] > 0 draw_set_alpha(0.5);

draw_self();
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var dname = "";
var dpass = "";
if(username == "" && selected_slot != SIGNUP_SLOTS.USERNAME){
	draw_set_color(c_gray);
	dname = defaultUsername;
} else {
	draw_set_color(c_black);
	dname = username;
}
draw_text(x + sprite_width / 2, y + 72, dname);
if(password == "" && selected_slot != SIGNUP_SLOTS.PASSWORD){
	draw_set_color(c_gray);
	dpass = defaultPassword;
} else {
	draw_set_color(c_black);
	dpass = string_repeat("?", string_length(password));
}
draw_text(x + sprite_width / 2, y + 172, dpass);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(c_purple);
var registerZone = zones[2];
draw_rectangle(x+registerZone.x0, y+registerZone.y0, x+registerZone.x1, y+registerZone.y1, false);
var loginZone = zones[3];
draw_rectangle(x+loginZone.x0, y+loginZone.y0, x+loginZone.x1, y+loginZone.y1, false);

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text(x+(registerZone.x0 + registerZone.x1) / 2, y+(registerZone.y0 + registerZone.y1) / 2, "Register");
draw_text(x+(loginZone.x0 + loginZone.x1) / 2, y+(loginZone.y0 + loginZone.y1) / 2, "Login");

draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_alpha(1);
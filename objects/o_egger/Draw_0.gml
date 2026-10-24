draw_set_font(fnt_EGG);
for(var i = 0; i < string_length(word); i++){
	var l = string_char_at(word, 1+i);
	if(i < index){
		draw_set_colour(c_red);
	} else {
		draw_set_color(c_ltgray);
	}
	var d = 8 + 20*(sin(t/3 + i) + cos(t/5 + i))
	draw_text(
		x + sin((i+1) + t) * d + i*2*string_width("E"),
		y + cos((i+1) + t) * d,
		l
	);
}
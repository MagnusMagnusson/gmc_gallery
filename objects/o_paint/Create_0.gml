can_edit = is_undefined(global.viewing_painting) || painting_is_mine(global.viewing_painting);

// Toolbox: tool buttons, brush size slider and clear. Keys select tools too.
tools = [
	{ tool: Tool.Pencil, name: "Pencil (P)", key: ord("P") },
	{ tool: Tool.Brush,  name: "Brush (B)",  key: ord("B") },
	{ tool: Tool.Spray,  name: "Spray (S)",  key: ord("S") },
	{ tool: Tool.Eraser, name: "Eraser (E)", key: ord("E") },
	{ tool: Tool.Fill,   name: "Fill (F)",   key: ord("F") },
	{ tool: Tool.Picker, name: "Picker (I)", key: ord("I") },
];

columns = 2;
button_w = 86;
button_h = 32;
gap = 6;
width = columns * (button_w + gap) - gap;

tools_y = y + 20;
size_y = tools_y + ceil(array_length(tools) / columns) * (button_h + gap) + 8;
slider_y = size_y + 20;
slider_h = 20;
// Paper row: swatch of the canvas base colour, and a button to set it to the current colour
paper_y = slider_y + slider_h + 14;
paper_button_x = x + button_h + gap;
// Undo, redo and clear share the last row.
clear_y = paper_y + button_h + gap;
third_w = (width - gap * 2) / 3;
dragging_size = false;

function draw_toolbox(){
	var _paint = global.paint;
	var _accent = make_colour_rgb(70, 110, 200);

	draw_set_colour(c_black);
	draw_text(x, y, "Tools");

	for (var _i = 0; _i < array_length(tools); _i++) {
		var _bx = x + (_i mod columns) * (button_w + gap);
		var _by = tools_y + (_i div columns) * (button_h + gap);
		ui_button(_bx, _by, _bx + button_w, _by + button_h, tools[_i].name, _paint.tool == tools[_i].tool);
	}
}

function draw_size_slider(){
	var _paint = global.paint;
	var _accent = make_colour_rgb(70, 110, 200);
	draw_set_colour(c_black);
	draw_text(x, size_y, "Size: " + string(_paint.size));
	var _cy = slider_y + slider_h / 2;
	var _kx = lerp(x, x + width, (_paint.size - PAINT_SIZE_MIN) / (PAINT_SIZE_MAX - PAINT_SIZE_MIN));
	draw_set_colour(c_silver);
	draw_rectangle(x, _cy - 2, x + width, _cy + 2, false);
	draw_set_colour(_accent);
	draw_rectangle(x, _cy - 2, _kx, _cy + 2, false);
	draw_set_colour(dragging_size ? _accent : c_white);
	draw_circle(_kx, _cy, 8, false);
	draw_set_colour(c_dkgray);
	draw_circle(_kx, _cy, 8, true);
}

function draw_canvas_color(){
	var _paint = global.paint;
	var _accent = make_colour_rgb(70, 110, 200);
	if (instance_exists(o_canvas)) {
		draw_set_colour(o_canvas.canvas.paper);
		draw_rectangle(x, paper_y, x + button_h - 1, paper_y + button_h - 1, false);
		draw_set_colour(c_dkgray);
		draw_rectangle(x, paper_y, x + button_h - 1, paper_y + button_h - 1, true);
	}
	ui_button(paper_button_x, paper_y, x + width, paper_y + button_h, "Set paper colour", false);
}
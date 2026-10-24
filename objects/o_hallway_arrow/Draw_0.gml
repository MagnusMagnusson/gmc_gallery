// Drawn pointing right around (0, 0), then flipped for dir and grown a little on hover.
var s = hover ? 1.15 : 1;
image_xscale = dir * s;
image_yscale = s;
draw_self();

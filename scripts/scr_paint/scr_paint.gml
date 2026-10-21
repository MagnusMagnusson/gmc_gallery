function Image(_buffer, _author = undefined, _title = undefined){
	buffer = _buffer;
	author = _author;
	title = _title;
	offset = 0;
}

function Canvas(_w, _h) constructor {
	w = _w;
	h = _h;
	surface = surface_create(w, h);
	
	function fromImage(image){
		buffer_set_surface(image.buffer, surface, image.offset);
	}
	
	function toImage(image){
		buffer_get_surface(image.buffer, surface, image.offset);
	}
}
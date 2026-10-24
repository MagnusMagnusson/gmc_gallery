// Paintings hang oldest first: the first hallway fills up, and the rest overflow into the
// next one, and the next.

#macro HALLWAY_CELL_W 155
#macro HALLWAY_CELL_H 135
#macro HALLWAY_WALL_H 450

// Which hallway is being visited, from 0. Kept while away painting.
global.hallway_index = 0;

// The top left corner of every spot on the wall a painting can hang.
function hallway_slots(){
	var cols = floor((room_width - HALLWAY_CELL_W) / HALLWAY_CELL_W);
	var rows = floor(HALLWAY_WALL_H / HALLWAY_CELL_H);
	var slots = [];
	for(var c = 0; c <= cols; c++){
		for(var r = 0; r <= rows; r++){
			array_push(slots, { x: c * HALLWAY_CELL_W, y: r * HALLWAY_CELL_H });
		}
	}
	return slots;
}

// Which hallway the painting at this place in the listing hangs in.
function hallway_of(index, capacity){
	return index div capacity;
}

// Where each painting hangs this run, by file id: { hallway, slot }, slot being an index into
// hallway_slots(). Kept so leaving and coming back doesn't rehang everything.
global.hallway_spots = {};

// Gives every painting in files a spot in the hallway. Paintings that already hang there keep
// theirs; the rest get a random free one.
function hallway_place(files, hallway, capacity){
	var taken = array_create(capacity, false);
	var unplaced = [];
	for(var i = 0; i < array_length(files); i++){
		var spot = global.hallway_spots[$ files[i].id];
		if(!is_undefined(spot) && spot.hallway == hallway && !taken[spot.slot]){
			taken[spot.slot] = true;
		} else {
			array_push(unplaced, files[i]);
		}
	}

	var free = [];
	for(var s = 0; s < capacity; s++){
		if(!taken[s]) array_push(free, s);
	}
	free = array_shuffle(free);
	for(var i = 0; i < array_length(unplaced); i++){
		global.hallway_spots[$ unplaced[i].id] = { hallway: hallway, slot: array_pop(free) };
	}
}

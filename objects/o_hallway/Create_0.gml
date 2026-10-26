if(!variable_instance_exists(id, "folder")) folder = PAINTING_FOLDER;
if(!variable_instance_exists(id, "ordered")) ordered = false;
if(!variable_instance_exists(id, "title")) title = "Hallway";
if(!variable_instance_exists(id, "can_paint")) can_paint = true;

slots = hallway_slots();
capacity = array_length(slots);
hallway_count = 1;
index = 0;

placePainting = method(self, function(painting, cached){
	var spot = global.hallway_spots[$ painting.file.id];
	if(is_undefined(spot)) return;
	var slot = slots[spot.slot];
	instance_create_layer(slot.x, slot.y, "Instances", o_painting, {
		painting: painting,
		cached: cached,
	});
});

hang = method(self, function(files){
	hallway_count = max(1, hallway_of(array_length(files) - 1, capacity) + 1);
	index = clamp(hallway_index_get(folder), 0, hallway_count - 1);
	hallway_index_set(folder, index);
	var here = [];
	for(var i = 0; i < array_length(files); i++){
		if(hallway_of(i, capacity) == index) array_push(here, files[i]);
	}
	// Spots are handed out before anything loads, so a painting that arrives first can't take
	// the spot of one that hung there last time.
	hallway_place(here, index, capacity, ordered);
	for(var i = 0; i < array_length(here); i++){
		painting_get(here[i], loader.onPaintingLoad);
	}
	if(index > 0){
		instance_create_layer(250, 690, "Instances", o_hallway_arrow, { dir: -1, folder: folder });
	}
	if(index < hallway_count-1){
		instance_create_layer(room_width - 80, 690, "Instances", o_hallway_arrow, { dir: 1, folder: folder });
	}
});

// Listings and downloads can come back after this hallway is gone, when someone has already
// walked on or gone to look at a painting. These go through a struct rather than the
// instance, so they can check before touching it.
loader = { owner: id };
loader.onPaintingLoad = method(loader, function(painting, cached){
	if(!instance_exists(owner)) return;
	owner.placePainting(painting, cached);
});
loader.onListed = method(loader, function(files){
	if(!instance_exists(owner)) return;
	owner.hang(files);
});

paintings_list(loader.onListed, undefined, folder);

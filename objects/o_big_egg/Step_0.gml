image_index = min(floor((life - remaining)/life * image_number), image_number - 1);
if(shaking){
	shaking--;
	x = xstart + shaking * (shaking%2 == 0 ? -1 : 1);
}
if(!known) exit;
if(sending == 0){
	if(pending > 0 && ++flush_timer >= BIG_EGG_FLUSH){
		send();
	} else if(++refresh_timer >= BIG_EGG_REFRESH){
		refresh_timer = 0;
		sb_datastore_get(scoreboat_datastore_egg, BIG_EGG_KEY, net.onRecord);
	}
}

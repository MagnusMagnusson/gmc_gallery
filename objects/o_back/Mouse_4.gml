if(room != rm_main_hall){
	room_goto(rm_main_hall);
} else {
	if( show_question("Are you sure you want to leave the gallery?") ) {
		game_end();
	}
}
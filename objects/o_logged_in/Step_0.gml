t += 1 / fadeout_time;
if(t > 1 && fadeout_time > 0){
	room_goto_next();
}
if(t < 0 && fadeout_time < 0){
	instance_destroy(self);
}
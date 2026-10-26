folder = MEMORIES_FOLDER;
ordered = true;
title = "Memory room";
var player = sb_player();
can_paint = !is_undefined(player) && string_lower(player.username ?? "") == MEMORIES_CURATOR;
event_inherited();

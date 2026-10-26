// One-off: moves every painting but the two oldest from PAINTING_FOLDER to MEMORIES_FOLDER.
// Only works when run from the IDE. F9 lists what would move; F9 again within 10 seconds moves it.
// Each painting is copied first and only deleted once the copy is up, one at a time.

#macro MEMORIES_FOLDER "/memories"
#macro ADMIN_KEEP 2

global.admin = { files: [], armed_until: 0, busy: false, status: "", index: 0, moved: 0, failed: [] };

global.admin.onListed = method(global.admin, function(listing){
	busy = false;
	var n = max(0, array_length(listing) - ADMIN_KEEP);
	files = array_create(n);
	array_copy(files, 0, listing, ADMIN_KEEP, n);
	show_debug_message("Admin: keeping {0} oldest, moving {1}:", min(ADMIN_KEEP, array_length(listing)), n);
	for(var i = 0; i < n; i++){
		show_debug_message("  {0}  {1}", files[i][$ "created"], files[i].path);
	}
	if(n == 0){
		status = "Nothing to move.";
		return;
	}
	status = string("{0} paintings would move to {1}. Press F9 again within 10 seconds to move them.", n, MEMORIES_FOLDER);
	armed_until = current_time + 10000;
});

global.admin.onListFailed = method(global.admin, function(e){
	busy = false;
	status = "Listing failed: " + string(e.message);
});

global.admin.next = method(global.admin, function(){
	if(index >= array_length(files)){
		busy = false;
		painting_listing_forget();
		status = string("Moved {0} of {1}.", moved, array_length(files));
		for(var i = 0; i < array_length(failed); i++){
			status += string("\n{0}: {1} failed, {2}", failed[i].name, failed[i].stage, failed[i].message);
		}
		show_debug_message("Admin: " + status);
		return;
	}
	var file = files[index];
	status = string("Moving {0} of {1}: {2}", index + 1, array_length(files), file.name);
	sb_file_download(scoreboat_bucket_painting, file.path, onDownloaded, onCopyFailed);
});

global.admin.onDownloaded = method(global.admin, function(result){
	var file = files[index];
	var type = file[$ "content_type"] ?? "application/x-gmc-painting";
	sb_file_upload(scoreboat_bucket_painting, MEMORIES_FOLDER + "/" + file.name, result.buffer, { content_type: type }, onCopied, onCopyFailed);
	buffer_delete(result.buffer);
});

global.admin.onCopied = method(global.admin, function(copy){
	sb_file_delete(scoreboat_bucket_painting, files[index].path, onDeleted, onDeleteFailed);
});

global.admin.onDeleted = method(global.admin, function(result){
	moved++;
	index++;
	next();
});

// The original is still in place.
global.admin.onCopyFailed = method(global.admin, function(e){
	array_push(failed, { name: files[index].name, stage: "copy", message: string(e.message) });
	index++;
	next();
});

// The copy is in MEMORIES_FOLDER, but the original is still in PAINTING_FOLDER too.
global.admin.onDeleteFailed = method(global.admin, function(e){
	array_push(failed, { name: files[index].name, stage: "delete", message: string(e.message) });
	index++;
	next();
});

function admin_memories_key(){
	if(GM_build_type != "run") return;
	var a = global.admin;
	if(a.busy) return;

	if(current_time < a.armed_until){
		a.armed_until = 0;
		a.busy = true;
		a.index = 0;
		a.moved = 0;
		a.failed = [];
		// Fails with 409 once the folder exists, which is just as good.
		sb_folder_create(scoreboat_bucket_painting, MEMORIES_FOLDER, a.next, a.next);
		return;
	}

	a.busy = true;
	a.status = "Listing paintings...";
	painting_listing_forget();
	paintings_list(a.onListed, a.onListFailed);
}

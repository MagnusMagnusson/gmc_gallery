// A painting file is a JSON header as a buffer_string, followed by the picture as a PNG.
// PNG rather than raw surface bytes, so a painting saved on a Mac reads the same on Windows.

#macro PAINTING_FOLDER "/paintings"
#macro PAINTING_EXT ".painting"
#macro PAINTING_TITLE_MAX 40

// Downloaded paintings are kept on disk by file id, with an index of the updated time and
// size each was downloaded at. They are only downloaded again when the listing says otherwise.
#macro PAINTING_CACHE_DIR "painting_cache/"
#macro PAINTING_CACHE_INDEX "painting_cache/index.json"
// How long a folder listing is trusted, in milliseconds.
#macro PAINTING_LIST_TTL 60000

global.painting_folder_ready = false;
global.painting_listing = undefined;
global.painting_listing_time = 0;
global.painting_cache = undefined;
// Paintings decoded this run, by file id. Their sprites belong here: don't sprite_delete them.
global.painting_loaded = {};

function painting_encode(surface, title) {
	var tmp = "painting_save.png";
	surface_save(surface, tmp);
	var png = buffer_load(tmp);
	file_delete(tmp);

	var player = sb_player();
	var header = json_stringify({
		title: title,
		author: player.display_name,
		author_id: player.id,
		width: surface_get_width(surface),
		height: surface_get_height(surface),
	});

	var png_size = buffer_get_size(png);
	var buf = buffer_create(string_byte_length(header) + 1 + png_size, buffer_fixed, 1);
	buffer_write(buf, buffer_string, header);
	buffer_copy(png, 0, png_size, buf, buffer_tell(buf));
	buffer_seek(buf, buffer_seek_relative, png_size);
	buffer_delete(png);
	return buf;
}

// Returns { title, author, author_id, width, height, sprite, file }, or undefined if the
// buffer isn't a painting.
function painting_decode(buf, file = undefined) {
	buffer_seek(buf, buffer_seek_start, 0);
	var painting;
	try {
		painting = json_parse(buffer_read(buf, buffer_string));
	} catch (e) {
		return undefined;
	}
	if (!is_struct(painting)) return undefined;

	var start = buffer_tell(buf);
	var png_size = buffer_get_size(buf) - start;
	if (png_size <= 0) return undefined;
	var png = buffer_create(png_size, buffer_fixed, 1);
	buffer_copy(buf, start, png_size, png, 0);
	var tmp = "painting_load.png";
	buffer_save(png, tmp);
	buffer_delete(png);
	painting.sprite = sprite_add(tmp, 1, false, false, 0, 0);
	file_delete(tmp);
	if (painting.sprite == -1) return undefined;

	painting.file = file;
	return painting;
}

// A name for a new painting's file. Saving again overwrites it.
function painting_new_path() {
	var now = floor((date_current_datetime() - date_create_datetime(1970, 1, 1, 0, 0, 0)) * 86400);
	return PAINTING_FOLDER + "/" + string(sb_player().id) + "_" + string(now) + "_" + string(irandom(9999)) + PAINTING_EXT;
}

// Whether the signed-in player made this painting. Who may actually delete is up to the
// bucket's rules; this is for deciding whether to offer it.
function painting_is_mine(painting) {
	if (!sb_player_signed_in()) return false;
	var creator = is_struct(painting.file) ? painting.file[$ "creator"] : undefined;
	return (creator ?? painting.author_id) == sb_player().id;
}

// So the next fetch lists the folder again, and sees what was just saved or deleted.
function painting_listing_forget() {
	global.painting_listing = undefined;
}

// onSuccess(result) and onFail(error) as for sb_file_delete.
function painting_delete(path, onSuccess = undefined, onFail = undefined) {
	sb_file_delete(scoreboat_bucket_painting, path, onSuccess, onFail).success(painting_listing_forget);
}

// Uploads the surface as a painting. onSuccess(file) and onFail(error) as for sb_file_upload.
function painting_upload(surface, title, path, onSuccess, onFail) {
	var job = {
		buffer: painting_encode(surface, title),
		path: path,
		onSuccess: onSuccess,
		onFail: onFail,
	};
	job.upload = method(job, function() {
		global.painting_folder_ready = true;
		sb_file_upload(scoreboat_bucket_painting, path, buffer, { content_type: "application/x-gmc-painting" }, onSuccess, onFail).success(painting_listing_forget);
		buffer_delete(buffer);
	});

	if (global.painting_folder_ready) {
		job.upload();
	} else {
		// Fails with 409 once the folder exists, which is just as good.
		sb_folder_create(scoreboat_bucket_painting, PAINTING_FOLDER, job.upload, job.upload);
	}
}

// Every painting file in the folder, across all pages. onDone(files) gets the files as
// sb_file_list describes them. Uses the last listing if it's less than a minute old.
function paintings_list(onDone, onFail = undefined) {
	if (!is_undefined(global.painting_listing) && current_time - global.painting_listing_time < PAINTING_LIST_TTL) {
		onDone(global.painting_listing);
		return;
	}

	var job = { files: [], offset: 0, onDone: onDone, onFail: onFail };
	job.nextPage = method(job, function() {
		sb_file_list(scoreboat_bucket_painting, PAINTING_FOLDER, { limit: 200, offset: offset }, onListed, onFail);
	});
	job.onListed = method(job, function(listing) {
		var page = listing[$ "files"] ?? [];
		for (var i = 0; i < array_length(page); i++) {
			if (string_ends_with(page[i].name, PAINTING_EXT)) array_push(files, page[i]);
		}
		offset += array_length(page);
		if (array_length(page) > 0 && offset < (listing[$ "file_count"] ?? 0)) {
			nextPage();
			return;
		}
		global.painting_listing = files;
		global.painting_listing_time = current_time;
		painting_cache_prune(files);
		onDone(files);
	});
	job.nextPage();
}

// Gets every painting, from memory, disk or Scoreboat, whichever is the first to have the
// current version. onPainting(painting, cached) is called for each one as it arrives, with what
// painting_decode returns and whether it came from memory or disk rather than a download; onDone() once the whole folder has been asked for; onFail(error)
// if listing the folder fails.
function paintings_fetch(onPainting, onDone = undefined, onFail = undefined) {
	var job = { onPainting: onPainting, onDone: onDone };
	job.onListed = method(job, function(files) {
		for (var i = 0; i < array_length(files); i++) {
			painting_get(files[i], onPainting);
		}
		if (is_callable(onDone)) onDone();
	});
	paintings_list(job.onListed, onFail);
}

function painting_get(file, onPainting) {
	var loaded = global.painting_loaded[$ file.id];
	if (!is_undefined(loaded) && painting_cache_current(loaded.file, file)) {
		onPainting(loaded, true);
		return;
	}

	var buf = painting_cache_read(file);
	if (!is_undefined(buf)) {
		var painting = painting_decode(buf, file);
		buffer_delete(buf);
		if (!is_undefined(painting)) {
			painting_remember(painting);
			onPainting(painting, true);
			return;
		}
		painting_cache_forget(file.id);
	}

	var job = { file: file, onPainting: onPainting };
	job.onDownloaded = method(job, function(result) {
		painting_cache_write(file, result.buffer);
		var painting = painting_decode(result.buffer, file);
		buffer_delete(result.buffer);
		if (is_undefined(painting)) return;
		painting_remember(painting);
		onPainting(painting, false);
	});
	sb_file_download(scoreboat_bucket_painting, file.path, job.onDownloaded);
}

/// @ignore
function painting_remember(painting) {
	var old = global.painting_loaded[$ painting.file.id];
	if (!is_undefined(old) && old.sprite != painting.sprite) sprite_delete(old.sprite);
	global.painting_loaded[$ painting.file.id] = painting;
}

/// @ignore
function painting_cache_current(cached, file) {
	return is_struct(cached) && cached.updated == file.updated && cached.size == file.size;
}

/// @ignore
function painting_cache_path(file_id) {
	return PAINTING_CACHE_DIR + string(file_id) + PAINTING_EXT;
}

/// @ignore
function painting_cache_index() {
	if (is_undefined(global.painting_cache)) {
		global.painting_cache = {};
		if (file_exists(PAINTING_CACHE_INDEX)) {
			var buf = buffer_load(PAINTING_CACHE_INDEX);
			try {
				var index = json_parse(buffer_read(buf, buffer_text));
				if (is_struct(index)) global.painting_cache = index;
			} catch (e) {
			}
			buffer_delete(buf);
		}
	}
	return global.painting_cache;
}

/// @ignore
function painting_cache_save_index() {
	var text = json_stringify(painting_cache_index());
	var buf = buffer_create(string_byte_length(text), buffer_fixed, 1);
	buffer_write(buf, buffer_text, text);
	buffer_save(buf, PAINTING_CACHE_INDEX);
	buffer_delete(buf);
}

// The cached copy of the file, if it is the version the listing describes.
/// @ignore
function painting_cache_read(file) {
	var index = painting_cache_index();
	if (!painting_cache_current(index[$ file.id], file)) return undefined;
	var path = painting_cache_path(file.id);
	return file_exists(path) ? buffer_load(path) : undefined;
}

/// @ignore
function painting_cache_write(file, buf) {
	if (!directory_exists(PAINTING_CACHE_DIR)) directory_create(PAINTING_CACHE_DIR);
	buffer_save(buf, painting_cache_path(file.id));
	var index = painting_cache_index();
	index[$ file.id] = { updated: file.updated, size: file.size };
	painting_cache_save_index();
}

/// @ignore
function painting_cache_forget(file_id) {
	var index = painting_cache_index();
	if (file_exists(painting_cache_path(file_id))) file_delete(painting_cache_path(file_id));
	struct_remove(index, file_id);
	painting_cache_save_index();
}

// Drops whatever is no longer in the folder, from disk and memory.
/// @ignore
function painting_cache_prune(files) {
	var keep = {};
	for (var i = 0; i < array_length(files); i++) keep[$ files[i].id] = true;

	var index = painting_cache_index();
	var ids = struct_get_names(index);
	var changed = false;
	for (var i = 0; i < array_length(ids); i++) {
		if (struct_exists(keep, ids[i])) continue;
		if (file_exists(painting_cache_path(ids[i]))) file_delete(painting_cache_path(ids[i]));
		struct_remove(index, ids[i]);
		changed = true;
	}
	if (changed) painting_cache_save_index();

	var loaded = struct_get_names(global.painting_loaded);
	for (var i = 0; i < array_length(loaded); i++) {
		if (struct_exists(keep, loaded[i])) continue;
		sprite_delete(global.painting_loaded[$ loaded[i]].sprite);
		struct_remove(global.painting_loaded, loaded[i]);
	}
}

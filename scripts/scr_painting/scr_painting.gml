// A painting file is a JSON header as a buffer_string, followed by the picture as a PNG.
// PNG rather than raw surface bytes, so a painting saved on a Mac reads the same on Windows.

#macro PAINTING_FOLDER "/paintings"
#macro PAINTING_EXT ".painting"
#macro PAINTING_TITLE_MAX 40

function painting_encode(_surface, _title) {
	var _tmp = "painting_save.png";
	surface_save(_surface, _tmp);
	var _png = buffer_load(_tmp);
	file_delete(_tmp);

	var _player = sb_player();
	var _header = json_stringify({
		title: _title,
		author: _player.display_name,
		author_id: _player.id,
		width: surface_get_width(_surface),
		height: surface_get_height(_surface),
	});

	var _png_size = buffer_get_size(_png);
	var _buf = buffer_create(string_byte_length(_header) + 1 + _png_size, buffer_fixed, 1);
	buffer_write(_buf, buffer_string, _header);
	buffer_copy(_png, 0, _png_size, _buf, buffer_tell(_buf));
	buffer_seek(_buf, buffer_seek_relative, _png_size);
	buffer_delete(_png);
	return _buf;
}

// Returns { title, author, author_id, width, height, sprite, file }, or undefined if the
// buffer isn't a painting. The sprite is the caller's to sprite_delete.
function painting_decode(_buffer, _file = undefined) {
	buffer_seek(_buffer, buffer_seek_start, 0);
	var _painting;
	try {
		_painting = json_parse(buffer_read(_buffer, buffer_string));
	} catch (_e) {
		return undefined;
	}
	if (!is_struct(_painting)) return undefined;

	var _start = buffer_tell(_buffer);
	var _png_size = buffer_get_size(_buffer) - _start;
	if (_png_size <= 0) return undefined;
	var _png = buffer_create(_png_size, buffer_fixed, 1);
	buffer_copy(_buffer, _start, _png_size, _png, 0);
	var _tmp = "painting_load.png";
	buffer_save(_png, _tmp);
	buffer_delete(_png);
	_painting.sprite = sprite_add(_tmp, 1, false, false, 0, 0);
	file_delete(_tmp);
	if (_painting.sprite == -1) return undefined;

	_painting.file = _file;
	return _painting;
}

// A name for a new painting's file. Saving again overwrites it.
function painting_new_path() {
	var _now = floor((date_current_datetime() - date_create_datetime(1970, 1, 1, 0, 0, 0)) * 86400);
	return PAINTING_FOLDER + "/" + string(sb_player().id) + "_" + string(_now) + "_" + string(irandom(9999)) + PAINTING_EXT;
}

// Whether the signed-in player made this painting. Who may actually delete is up to the
// bucket's rules; this is for deciding whether to offer it.
function painting_is_mine(_painting) {
	if (!sb_player_signed_in()) return false;
	var _creator = is_struct(_painting.file) ? _painting.file[$ "creator"] : undefined;
	return (_creator ?? _painting.author_id) == sb_player().id;
}

// on_success(result) and on_fail(error) as for sb_file_delete.
function painting_delete(_path, _on_success = undefined, _on_fail = undefined) {
	sb_file_delete(scoreboat_bucket_painting, _path, _on_success, _on_fail);
}

global.painting_folder_ready = false;

// Uploads the surface as a painting. on_success(file) and on_fail(error) as for sb_file_upload.
function painting_upload(_surface, _title, _path, _on_success, _on_fail) {
	var _job = {
		buffer: painting_encode(_surface, _title),
		path: _path,
		on_success: _on_success,
		on_fail: _on_fail,
	};
	_job.upload = method(_job, function() {
		global.painting_folder_ready = true;
		sb_file_upload(scoreboat_bucket_painting, path, buffer, { content_type: "application/x-gmc-painting" }, on_success, on_fail);
		buffer_delete(buffer);
	});

	if (global.painting_folder_ready) {
		_job.upload();
	} else {
		// Fails with 409 once the folder exists, which is just as good.
		sb_folder_create(scoreboat_bucket_painting, PAINTING_FOLDER, _job.upload, _job.upload);
	}
}

// Downloads every painting. on_painting(painting) is called for each one as it arrives,
// with what painting_decode returns; on_done() once the whole folder has been asked for;
// on_fail(error) if listing the folder fails.
function paintings_fetch(_on_painting, _on_done = undefined, _on_fail = undefined) {
	var _job = { on_painting: _on_painting, on_done: _on_done, on_fail: _on_fail, offset: 0 };

	_job.next_page = method(_job, function() {
		sb_file_list(scoreboat_bucket_painting, PAINTING_FOLDER, { limit: 200, offset: offset }, on_listed, on_fail);
	});
	_job.on_listed = method(_job, function(_listing) {
		var _files = _listing[$ "files"] ?? [];
		for (var i = 0; i < array_length(_files); i++) {
			var _file = _files[i];
			if (!string_ends_with(_file.name, PAINTING_EXT)) continue;
			var _download = { file: _file, on_painting: on_painting };
			_download.on_downloaded = method(_download, function(_result) {
				var _painting = painting_decode(_result.buffer, file);
				buffer_delete(_result.buffer);
				if (!is_undefined(_painting)) on_painting(_painting);
			});
			sb_file_download(scoreboat_bucket_painting, _file.path, _download.on_downloaded);
		}
		offset += array_length(_files);
		if (array_length(_files) > 0 && offset < (_listing[$ "file_count"] ?? 0)) {
			next_page();
		} else if (is_callable(on_done)) {
			on_done();
		}
	});

	_job.next_page();
}

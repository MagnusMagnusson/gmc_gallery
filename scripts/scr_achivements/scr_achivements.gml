#macro JAM60_ACHIEVEMENTS_GAME "*insert your game title here; the title should be alphanumeric + underscores only*"

/// @desc Checks whether the given achievement is completed.
/// @arg {String} game          The title of the game the achievement is for. Should be alphanumeric + underscores only.
/// @arg {String} name          The name specifying the achievement. Should be alphanumeric + underscores only.
/// @returns {Bool}
function jam60_achievement_check(_game, _name) {
    var _path = jam60_achievement_path(_game, _name);
    try {
        return !is_undefined(_path) && file_exists(_path);
    }
    catch (_exception) {
        show_debug_message($"Error when checking achievement {_game}.{_name}:");
        show_debug_message(_exception);
        return false;
    }
}

/// @desc Records the given achievement of the current game as completed. Returns true when the achievement was recorded successfully or false when the achievement had been completed earlier or an error occurred.
/// @arg {String} name          The name specifying the achievement. Should be alphanumeric + underscores only.
/// @returns {Bool}
function jam60_achievement_complete(_name) {
    var _path = jam60_achievement_path(JAM60_ACHIEVEMENTS_GAME, _name);
    if (is_undefined(_path)) {
        show_debug_message($"COULD NOT WRITE ACHIEVEMENT {JAM60_ACHIEVEMENTS_GAME}.{_name}. For some reason, the localappdata path could not be resolved.");
        return false;
    }
    
    var _directory = filename_dir(_path);
    if (!directory_exists(_directory)) {
        directory_create(_directory);
        if (!directory_exists(_directory)) {
            show_debug_message($"COULD NOT ACCESS ACHIEVEMENTS DIRECTORY. Make sure to disable file system sandbox in Game Options >> Windows >> General.");
            return false;
        }
    }
    
    if (file_exists(_path)) {
        show_debug_message($"Achievement {JAM60_ACHIEVEMENTS_GAME}.{_name} is already written.");
        return;
    }
    
    try
    {
        var _file = file_text_open_write(_path);
        file_text_write_string(_file, "OK");
        file_text_close(_file);
        
        if (!file_exists(_path))
            show_debug_message($"COULD NOT WRITE ACHIEVEMENT {JAM60_ACHIEVEMENTS_GAME}.{_name}. For some reason, the file could not be written. Make sure to disable file system sandbox in Game Options >> Windows >> General, and that both the game and achievement name are alphanumeric + underscore only (no asterisks etc.)!");
        else
            show_debug_message($"Achievement {JAM60_ACHIEVEMENTS_GAME}.{_name} written successfully.");
    } catch (_exception) {
        show_debug_message($"COULD NOT WRITE ACHIEVEMENT {JAM60_ACHIEVEMENTS_GAME}.{_name}. Got the following error:");
        show_debug_message(_exception);
    }
}

/// @desc Retrieves the Jam 60 achievement folder.
/// @arg {String} game          The title of the game the achievement is for. Should be alphanumeric + underscores only.
/// @arg {String} name          The name specifying the achievement. Should be alphanumeric + underscores only.
/// @returns {String}
function jam60_achievement_path(_game, _name) {
    static dir_trim = ["/"];
    
    var _localappdata = string_replace_all(environment_get_variable("localappdata"), "\\", "/");
    if (is_undefined(_localappdata))
        return undefined;
    
    _localappdata = string_trim_end(_localappdata, dir_trim);
    return $"{_localappdata}/JAM60_ACHIEVEMENTS/{_game}.{_name}.dat";
}
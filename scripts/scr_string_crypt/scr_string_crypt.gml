function string_encrypt(_string, _key) {
	var _len = string_byte_length(_string);
	if (_len == 0) return "";
	var _buf = buffer_create(_len, buffer_fixed, 1);
	buffer_write(_buf, buffer_text, _string);

	var _hex = "0123456789abcdef";
	var _state = __string_crypt_seed(_key);
	var _out = "";
	for (var i = 0; i < _len; i++) {
		_state = __string_crypt_next(_state);
		var _byte = buffer_peek(_buf, i, buffer_u8) ^ (_state & 0xFF);
		_out += string_char_at(_hex, (_byte >> 4) + 1) + string_char_at(_hex, (_byte & 0xF) + 1);
	}
	buffer_delete(_buf);
	return _out;
}

function string_decrypt(_hex, _key) {
	var _len = string_length(_hex) div 2;
	if (_len == 0) return "";
	// One extra byte for the terminator buffer_string reads up to.
	var _buf = buffer_create(_len + 1, buffer_fixed, 1);

	var _state = __string_crypt_seed(_key);
	for (var i = 0; i < _len; i++) {
		_state = __string_crypt_next(_state);
		var _byte = (__string_crypt_nibble(string_char_at(_hex, i * 2 + 1)) << 4)
			| __string_crypt_nibble(string_char_at(_hex, i * 2 + 2));
		buffer_poke(_buf, i, buffer_u8, _byte ^ (_state & 0xFF));
	}
	buffer_poke(_buf, _len, buffer_u8, 0);
	var _out = buffer_read(_buf, buffer_string);
	buffer_delete(_buf);
	return _out;
}

/// @ignore
function __string_crypt_seed(_key) {
	var _h = 5381;
	for (var i = 1; i <= string_length(_key); i++) {
		_h = ((_h << 5) + _h + string_ord_at(_key, i)) & 0xFFFFFFFF;
	}
	return (_h == 0) ? 0x9E3779B9 : _h;
}

/// @ignore
function __string_crypt_next(_x) {
	_x ^= (_x << 13) & 0xFFFFFFFF;
	_x ^= _x >> 17;
	_x ^= (_x << 5) & 0xFFFFFFFF;
	return _x;
}

/// @ignore
function __string_crypt_nibble(_char) {
	return string_pos(string_lower(_char), "0123456789abcdef") - 1;
}

function __mkscr(s, n){
	var a = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
	var r = "";
	for(i = 0; i < n; i++){
		r += string_char_at(a, 1 + (power(s, i + 1) * (s xor n)) mod string_length(a));
	}
	return r;
}

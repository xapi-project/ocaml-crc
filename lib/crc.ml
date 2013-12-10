exception Invalid_length
exception Invalid_offset

let check_bounds buffer_length offset data_length =
	if offset > buffer_length then raise Invalid_offset;
	if data_length < 0 then raise Invalid_length;
	if offset + data_length > buffer_length then raise Invalid_length;
	if offset < 0 then raise Invalid_offset

let check_bounds_cstruct t offset length =
	check_bounds t.Cstruct.len (offset + t.Cstruct.off) length

external unsafe_crc32_cstruct : int32 -> Cstruct.buffer -> int -> int -> int32 =
	"crc32_cstruct"

let crc32_cstruct ?(crc=0l) t offset length =
	check_bounds_cstruct t offset length;
	unsafe_crc32_cstruct crc t.Cstruct.buffer (offset + t.Cstruct.off) length

external unsafe_crc32_string : int32 -> string -> int -> int -> int32 =
	"crc32_string"

let check_bounds_string str offset length =
	check_bounds (String.length str) offset length

let crc32_string ?(crc=0l) str offset length =
	check_bounds_string str offset length;
	unsafe_crc32_string crc str offset length

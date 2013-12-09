let check_bounds t offset length =
	if offset > t.Cstruct.len then invalid_arg "offset";
	if length < 0 then invalid_arg "length";
	if offset + length > t.Cstruct.len then invalid_arg "length";
	if (offset + t.Cstruct.off) < 0 then invalid_arg "offset"

external unsafe_crc32_cstruct : Cstruct.buffer -> int -> int -> int32 =
	"crc32_cstruct"

let crc32_cstruct t offset length =
	check_bounds t offset length;
	unsafe_crc32_cstruct t.Cstruct.buffer (offset + t.Cstruct.off) length

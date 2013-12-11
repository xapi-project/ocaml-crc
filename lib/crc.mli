exception Invalid_length
exception Invalid_offset

val crc32_cstruct: ?crc:int32 -> Cstruct.t -> int32

val crc32_string: ?crc:int32 -> string -> int -> int -> int32

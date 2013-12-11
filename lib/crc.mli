exception Invalid_length
exception Invalid_offset

module Crc32 : sig
        (** This is the algorithm used by HDLC, ANSI X3.66, ITU-T V.42,
            Ethernet, Serial ATA, MPEG-2, PKZIP, Gzip, Bzip2, PNG and
            others:
            http://en.wikipedia.org/wiki/Cyclic_redundancy_check#Commonly_used_and_standardized_CRCs
        *)

        val cstruct: ?crc:int32 -> Cstruct.t -> int32
        (** [cstruct ?crc buf] computes the CRC of [buf] with optional
            initial value [crc] *)

        val string: ?crc:int32 -> string -> int -> int -> int32
        (** [string ?crc buf ofs len] computes the CRC of the substring
            of length [len] starting at offset [ofs] in string [buf] with
            optional initial value [crc] *)
end

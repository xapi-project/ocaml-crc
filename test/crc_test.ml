open OUnit

(* Expected CRCs calculated using python's zlib.crc32. *)
let full_crc_tests = [
	"", 0l;
	"foobar", Int32.neg 1628037227l;
	"as89f7d8f798d7f987f0daf", 822820715l;
	";£*%($)(^$&", Int32.neg 1888319081l;
	"\\\n\\xyz", 355115745l;
]

let test_crc_all_string data expected_crc =
	let crc = Crc.crc32_string data 0 (String.length data) in
	assert_equal crc expected_crc

let test_crc_all_cstruct data expected_crc =
	let cstruct = Cstruct.of_string data in
	let crc = Crc.crc32_cstruct cstruct in
	assert_equal crc expected_crc

let suite_test_crc_all =
	let make_tests test_fn test_base_name =
		List.map
			(fun (test_string, expected_crc) ->
				let test_name =
					Printf.sprintf
						"%s: \"%s\"" test_base_name (String.escaped test_string)
				in
				test_name >:: (fun () -> test_fn test_string expected_crc))
			full_crc_tests
	in
	"suite_test_crc_all" >:::
		((make_tests test_crc_all_string "test_crc_all_string") @
		(make_tests test_crc_all_cstruct "test_crc_all_cstruct"))

let part_crc_tests = [
	"foobarbaz", 5, 0, 0l;
	"abcfoobardef", 3, 6, Int32.neg 1628037227l;
	"lmn\\\n\\xyzopq", 3, 6, 355115745l;
]

let test_crc_part_string data offset length expected_crc =
	let crc = Crc.crc32_string data offset length in
	assert_equal crc expected_crc

let test_crc_part_cstruct data offset length expected_crc =
	let cstruct = Cstruct.of_string data in
	let crc = Crc.crc32_cstruct (Cstruct.sub cstruct offset length) in
	assert_equal crc expected_crc

let suite_test_crc_part =
	let make_tests test_fn test_base_name =
		List.map
			(fun (test_string, offset, length, expected_crc) ->
				let test_name =
					Printf.sprintf
						"%s: \"%s\"" test_base_name (String.escaped test_string)
				in
				test_name >::
					(fun () -> test_fn test_string offset length expected_crc))
			part_crc_tests
	in
	"suite_test_crc_part" >:::
		((make_tests test_crc_part_string "test_crc_part_string") @
		(make_tests test_crc_part_cstruct "test_crc_part_cstruct"))

let update_crc_tests = [
	"", "bar", 1996459178l;
	"bar", "", 1996459178l;
	"bar", "baz", 385868946l;
	"[12pl34.", ",2l3\n\t", 1481911597l;
]

let test_crc_update_string data_first data_second expected_crc =
	let data_all = data_first ^ data_second in
	let crc_all = Crc.crc32_string data_all 0 (String.length data_all) in
	let crc_first = Crc.crc32_string data_first 0 (String.length data_first) in
	let crc_parts =
		Crc.crc32_string
			~crc:crc_first
			data_second 0 (String.length data_second)
	in
	assert_equal crc_all crc_parts

let test_crc_update_cstruct data_first data_second expected_crc =
	let length_first = String.length data_first in
	let length_second = String.length data_second in
	let cstruct_all = Cstruct.of_string (data_first ^ data_second) in
	let cstruct_first = Cstruct.of_string data_first in
	let cstruct_second = Cstruct.of_string data_second in
	let crc_all =
		Crc.crc32_cstruct (Cstruct.sub cstruct_all 0 (length_first + length_second))
	in
	let crc_first = Crc.crc32_cstruct cstruct_first in
	let crc_parts =
		Crc.crc32_cstruct ~crc:crc_first cstruct_second
	in
	assert_equal crc_all crc_parts

let suite_test_crc_update =
	let make_tests test_fn test_base_name =
		List.map
			(fun (test_string_first, test_string_second, expected_crc) ->
				let test_name =
					Printf.sprintf
						"%s: \"%s\",\"%s\""
						test_base_name
						(String.escaped test_string_first)
						(String.escaped test_string_second)
				in
				test_name >::
					(fun () -> test_crc_update_string
							test_string_first test_string_second expected_crc))
			update_crc_tests
	in
	"suite_test_crc_update" >:::
		((make_tests test_crc_update_string "test_crc_update_string") @
		(make_tests test_crc_update_cstruct "test_crc_update_cstruct"))

let test_negative_length () =
	let cstruct = Cstruct.of_string "foobar" in
        try
                let (_: int32) = Crc.crc32_cstruct (Cstruct.sub cstruct 2 (-5)) in
                failwith "test_negative_length"
        with
        | Crc.Invalid_length
        | Invalid_argument "Cstruct.sub" -> ()

let test_negative_offset () =
	let cstruct = Cstruct.of_string "foobar" in
        try
                let (_: int32) = Crc.crc32_cstruct (Cstruct.sub cstruct (-3) 4) in
                failwith "test_negative_offset"
        with Crc.Invalid_offset
        | Invalid_argument "Cstruct.sub" -> ()

let test_too_large_length () =
	let cstruct = Cstruct.of_string "foobar" in
        try
                let (_: int32) = Crc.crc32_cstruct (Cstruct.sub cstruct 3 5) in
                failwith "test_too_large_length"
        with Crc.Invalid_length
        | Invalid_argument "Cstruct.sub" -> ()

let test_too_large_offset () =
	let cstruct = Cstruct.of_string "foobar" in
        try
                let (_: int32) = Crc.crc32_cstruct (Cstruct.sub cstruct 7 2) in
                failwith "test_too_large_offset"
        with Crc.Invalid_offset
        | Invalid_argument "Cstruct.sub" -> ()

let suite_test_bounds_checking =
	"suite_test_bounds_checking" >:::
		[
			"test_negative_length" >:: test_negative_length;
			"test_negative_offset" >:: test_negative_offset;
			"test_too_large_length" >:: test_too_large_length;
			"test_too_large_offset" >:: test_too_large_offset;
		]

let base_suite =
	"base_suite" >:::
		[
			suite_test_crc_all;
			suite_test_crc_part;
			suite_test_crc_update;
			suite_test_bounds_checking;
		]

let _ = run_test_tt_main base_suite
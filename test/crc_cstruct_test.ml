open OUnit

(* Expected CRCs calculated using python's zlib.crc32. *)
let full_crc_tests = [
	"", 0l;
	"foobar", Int32.neg 1628037227l;
	"as89f7d8f798d7f987f0daf", 822820715l;
	";£*%($)(^$&", Int32.neg 1888319081l;
	"\\\n\\xyz", 355115745l;
]

let test_crc_all data expected_crc =
	let cstruct = Cstruct.of_string data in
	let cstruct_crc = Crc.crc32_cstruct cstruct 0 (String.length data) in
	assert_equal cstruct_crc expected_crc

let suite_test_crc_all =
	"suite_test_crc_all" >:::
		(List.map
			(fun (test_string, expected_crc) ->
				let test_name =
					Printf.sprintf
						"test_crc_all: \"%s\""
						(String.escaped test_string)
				in
				test_name >:: (fun () -> test_crc_all test_string expected_crc))
			full_crc_tests)

let part_crc_tests = [
	"foobarbaz", 5, 0, 0l;
	"abcfoobardef", 3, 6, Int32.neg 1628037227l;
	"lmn\\\n\\xyzopq", 3, 6, 355115745l;
]

let test_crc_part data offset length expected_crc =
	let cstruct = Cstruct.of_string data in
	let cstruct_crc = Crc.crc32_cstruct cstruct offset length in
	assert_equal cstruct_crc expected_crc

let suite_test_crc_part =
	"suite_test_crc_part" >:::
		(List.map
			(fun (test_string, offset, length, expected_crc) ->
				let test_name =
					Printf.sprintf
						"test_crc_part: \"%s\""
						(String.escaped test_string)
				in
				test_name >::
					(fun () -> test_crc_part test_string offset length expected_crc))
			part_crc_tests)

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

let suite_test_crc_update =
	"suite_test_crc_update" >:::
		(List.map
			(fun (test_string_first, test_string_second, expected_crc) ->
				let test_name =
					Printf.sprintf
						"test_crc_update_string: \"%s\",\"%s\""
						(String.escaped test_string_first)
						(String.escaped test_string_second)
				in
				test_name >::
					(fun () -> test_crc_update_string
							test_string_first test_string_second expected_crc))
			update_crc_tests)

let test_negative_length () =
	let cstruct = Cstruct.of_string "foobar" in
	assert_raises
		(Invalid_argument "length")
		(fun () -> Crc.crc32_cstruct cstruct 2 (-5))

let test_negative_offset () =
	let cstruct = Cstruct.of_string "foobar" in
	assert_raises
		(Invalid_argument "offset")
		(fun () -> Crc.crc32_cstruct cstruct (-3) 4)

let test_too_large_length () =
	let cstruct = Cstruct.of_string "foobar" in
	assert_raises
		(Invalid_argument "length")
		(fun () -> Crc.crc32_cstruct cstruct 3 5)

let test_too_large_offset () =
	let cstruct = Cstruct.of_string "foobar" in
	assert_raises
		(Invalid_argument "offset")
		(fun () -> Crc.crc32_cstruct cstruct 7 2)

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

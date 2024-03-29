(* This is a comment. *)

(* Algebraic type system example. *)
(* type person = *)
(* | Quiet *)
(* | Loud   of int *)
(* | Chatty of int * string;; *)

(* let p = Chatty(10, "Hello World!") in *)
(* match p with *)
(* | Loud   (v)     -> Core.printf   "volume level of %d\n" v *)
(* | Chatty (v,msg) -> Core.printf   "%s at volume %d\n"    msg v *)
(* | _              -> print_endline "something else"  *)

(* open Printf *)
(* let () = *)
(*   let filename = "test.txt" in *)
(*   let ic = open_out_gen [Open_append; Open_creat] 0o644 filename in *)
(*   printf ">>> "; *)
(*   try *)
(*     let line = read_line () in *)
(*       output_string ic line; *)
(*       close_out ic *)
(*   with *)
(*     | Sys_error e -> *)
(*        close_out_noerr ic; *)
(*        printf "Error: %s\n" e *)

open Printf

type io_channels = {
  ic: in_channel;
  oc: out_channel;
}

module SafeIO = struct
  let open_out_gen flags perm filename
      : (out_channel, string) result =
    try Ok (open_out_gen flags perm filename) with
    | Sys_error e -> Error e

  let output_string oc str
      : (unit, string) result =
    try output_string oc str; Ok() with
    | Sys_error e -> Error e

  let close_out_noerr oc
      : (unit, string) result =
    try close_out_noerr oc; Ok() with
    | Sys_error e -> Error e

  let open_in filename
      : (in_channel, string) result =
    try Ok (open_in filename) with
    | Sys_error e -> Error e
end

(* let count_lines filename = *)
(*   let ic = open_in filename in *)
(*   let next_line () = *)
(*     try Some (input_line ic, ()) *)
(*     with End_of_file -> None  (\* Correctly handle the end of file *\) *)
(*   in *)
(*   let line_seq = Seq.unfold (fun () -> next_line ()) () in *)
(*   Seq.fold_left (fun acc _ -> acc + 1) 0 line_seq *)

let count_lines ic =
  let try_read () =
    try Some (input_line ic) with End_of_file -> None in
    let rec loop count =
      match try_read () with
      | Some _ -> loop (count + 1)
      | None   -> count
    in loop 0


let read_and_count_lines filename =
  match SafeIO.open_in filename with
  | Ok ic ->
     let lines = count_lines ic in
     close_in ic;
     Ok lines
  | Error e -> Error e

(* Note that the Ok block may seem confusing at first. *)
(*
  Essentially, write_result is what we want to happen if output_string does
  not propagate an error. We want to execute close_out_noerr in the case
  of success; so we bind its value (which we ignore) following the attempt
  to output_string.
 *)
let write_line_to_file filename line =
  match SafeIO.open_out_gen [Open_append; Open_creat] 0o644 filename with
  | Ok ic ->
     let write_result = SafeIO.output_string ic line in
     let _ = SafeIO.close_out_noerr ic in
     write_result
  | Error e -> Error e

(* let new_line_entry line_count line = *)
(*   let formatted_line = string_of_int line_count ^ ". " ^ line *)
(*   in line_count + 1, formatted_line *)

let new_line_entry line_count line =
  string_of_int (line_count + 1) ^ ". " ^ line ^ "\n"

(* Pay very close to how we can compose here! *)
(* Note that in this example, we cannot acces the line numbers further *)
(* down in the pipeline of our main function. *)
(* let () = *)
(*   let filename = "test.txt" in *)
(*   let _ = match read_and_count_lines filename with *)
(*   | Ok line_count -> printf "Current lines: %d\n" line_count *)
(*   | Error e       -> printf "Error: couldn't read file - %s\n" e in *)

(*   (\* prompt *\) *)
(*   printf ">>> "; *)

(*   let line = read_line () in *)
(*   match write_line_to_file filename line with *)
(*   | Ok () -> () *)
(*   | Error e -> printf "Error: couldn't write to file - %s\n" e *)

(* Here is an improvement which allows us to write custom logic using *)
(* the output of read_and_count_lines *)

let () =
  let filename = "test.txt" in
  let read_and_count_results = read_and_count_lines filename in
  match read_and_count_results with
  | Ok line_count ->
     printf "Current lines: %d\n" line_count;
     printf ">>> ";
     let line = read_line () in
     let new_line = new_line_entry line_count line in
     begin match write_line_to_file new_line filename with
     | Ok ()   ->
        printf "New entry: %s\n" (new_line_entry line_count line);
        printf "Added line %d to file %s\n" (line_count + 1) filename;
     | Error e -> printf "Error: couldn't write to file - %s\n" e
     end
  | Error e -> printf "Error: couldn't read file - %s\n" e

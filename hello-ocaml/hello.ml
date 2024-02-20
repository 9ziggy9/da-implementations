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
end

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

let () =
  let filename = "test.txt" in
  printf ">>> ";
  let line = read_line () in
  match write_line_to_file filename line with
  | Ok () -> ()
  | Error e -> printf "Error: %s\n" e

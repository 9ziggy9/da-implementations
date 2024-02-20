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

open Printf
let main () =
  let filename = "test.txt" in
  let ic = open_out_gen [Open_append; Open_creat] 0o644 filename in
  printf "Please enter some stuff: ";
  try
    let line = read_line () in
      output_string ic ("\n" ^ line ^ "\n");
      close_out ic
  with
    | Sys_error e ->
       close_out_noerr ic;
       printf "Error: %s\n" e

let _ = main ()

(* This is a comment. *)

type person =
| Quiet
| Loud   of int
| Chatty of int * string;;

let p = Chatty(10, "Hello World!") in
match p with
| Loud   (v)     -> Core.printf   "volume level of %d\n" v
| Chatty (v,msg) -> Core.printf   "%s at volume %d\n"    msg v
| _              -> print_endline "something else" 


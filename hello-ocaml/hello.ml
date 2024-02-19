(* This is a comment. *)

type person =
| Quiet
| Loud   of int
| Chatty of int * string;;

let p = Loud(10) in
match p with
| Loud (v) -> Core.printf "volume level of %d\n" v
| _        -> print_endline "something else"

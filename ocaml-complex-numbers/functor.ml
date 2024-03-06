(* module Grid1 = struct *)
(*   type 'a grid = *)
(*     | Row of 'a row * 'a grid *)
(*     | NoRow *)
(*   and 'a row = *)
(*     | Cell of 'a option * 'a row *)
(*     | NoCell *)

(*   let rec make (rows : 'a option list list) : 'a grid = *)
(*     let rec make_row (xs : 'a option list) : 'a row = *)
(*       match xs with *)
(*       | []      -> NoCell *)
(*       | y :: ys -> Cell (y, make_row ys) *)
(*     in *)
(*     match rows with *)
(*     | []       -> NoRow *)
(*     | [] :: rs -> make rs (\* skip empty rows *\) *)
(*     | r  :: rs -> Row (make_row r, make rs) *)
(* end *)

(* module type Gridable = sig *)
(*   type t *)
(*   val should_void : t -> bool *)
(* end *)

(* module Grid (G : Gridable) = struct *)
(*   type 'a grid = *)
(*     | Row of 'a row * 'a grid *)
(*     | NoRow *)
(*   and 'a row = *)
(*     | Cell of 'a * 'a row *)
(*     | NoCell *)

(*   let make_el (x : G.t) : G.t option = *)
(*     if G.should_void x then None else Some x *)

(*   let rec make (rows : G.t list list) : G.t option grid = *)
(*     let rec make_row (xs : G.t list) : G.t option row = *)
(*       match xs with *)
(*       | []      -> NoCell *)
(*       | y :: ys -> Cell (make_el y, make_row ys) *)
(*     in *)
(*     match rows with *)
(*     | []       -> NoRow *)
(*     | [] :: rs -> make rs (\* skip empty rows *\) *)
(*     | r  :: rs -> Row (make_row r, make rs) *)
(* end *)

module type GridBasis = sig
  type data
  val should_void : data -> bool
  val string_from : (data -> string) option
end

module type Grid = sig
  type t
  type grid
  val make    : t list list -> grid
  val iterate : grid -> (t -> unit) -> unit
  val string_of : grid -> string 
end

(* GridMapping is a Functor *)
(* GridBasis will never be exposed as it is just a parameter to GridMapping *)
(* But we DO want type t exposed, otherwise we must use the type ZeroGrid.t *)
(* ZeroGrid.t to declare elements of ZeroGrid!                              *)
(* This is the reason for the `with type t = G.data` constraint in addition *)
(* to type t assignment (which satisfies Grid interface requirements).      *)
(* If you want to see difference, uncomment functor signature and observe.  *)
(* module GridMapping (G : GridBasis) : Grid = struct *)
module GridMapping (G : GridBasis) : Grid with type t = G.data = struct
  type t = G.data
  type grid = PrivateGrid of grid_internal
  and grid_internal =
    | Row of row_internal * grid_internal
    | NoRow
  and row_internal =
    | Cell of t option * row_internal
    | NoCell

  let option_of_void (x : t) : t option =
    if G.should_void x then None else Some x

  let rec make (rows : t list list) : grid =
    let rec make_row (xs : t list) : row_internal =
      match xs with
      | []      -> NoCell
      | y :: ys -> Cell (option_of_void y, make_row ys)
    in let rec make_grid (rs : t list list) : grid_internal =
      match rs with
      | []       -> NoRow
      | [] :: rs -> make_grid rs (* skip empty rows *)
      | r  :: rs -> Row (make_row r, make_grid rs)
    in PrivateGrid (make_grid rows)

  (* THIS PERFORMS SIDE-EFFECTS *)
  let iterate (PrivateGrid g) f =
    let rec iter_row (r : row_internal) = match r with
      | NoCell            -> ()
      | Cell (Some x, xs) -> f x; iter_row xs (* Call side effect *)
      | Cell (None, xs)   -> iter_row xs in
    let rec iter_grid (g : grid_internal) = match g with
      | NoRow       -> ()
      | Row (r, rs) -> iter_row r; iter_grid rs
    in iter_grid g

  let string_of (PrivateGrid g) : string =
    let rec string_of_row (r : row_internal) = match r with
      | NoCell            -> ""
      | Cell (Some x, xs) -> begin match G.string_from with
                                | Some f -> " " ^ f x ^ " "
                                | None   -> " <?> "
                             end ^ string_of_row xs
      | Cell (None, xs)   -> " _ " ^ string_of_row xs in
    let rec string_of_grid (g : grid_internal) = match g with
      | NoRow       -> ""
      | Row (r, rs) -> string_of_row r ^ "\n" ^ string_of_grid rs
    in string_of_grid g
end

module ZeroGrid = GridMapping(struct
  type data = int
  let should_void = fun n -> n = 0
  let string_from = Some string_of_int
end)

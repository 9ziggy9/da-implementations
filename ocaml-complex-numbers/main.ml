module Grid1 = struct
  type 'a grid =
    | Row of 'a row * 'a grid
    | NoRow
  and 'a row =
    | Cell of 'a option * 'a row
    | NoCell

  let rec make (rows : 'a option list list) : 'a grid =
    let rec make_row (xs : 'a option list) : 'a row =
      match xs with
      | []      -> NoCell
      | y :: ys -> Cell (y, make_row ys)
    in
    match rows with
    | []       -> NoRow
    | [] :: rs -> make rs (* skip empty rows *)
    | r  :: rs -> Row (make_row r, make rs)
end

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
  val make : t list list -> grid
  val iterate : grid -> (t -> unit) -> unit
  (* You can add more functions here to interact with the grid *)
end

(* Gridable will never be exposed as it is just a parameter to the functor *)
(* But we DO want type t exposed to users, other wise we must use the type *)
(* ZeroGrid.t to declare elements of ZeroGrid!*)
(* This is the reason for the with `type t = G.data` clause in addition to *)
(* The internal specification (which satisfies Interface REQUIREMENTS) *)
(* module Grid (G : Gridable) : Grid = struct *)
module GridMapping (G : GridBasis) : Grid with type t = G.data = struct
  type t = G.data
  type grid = PrivateGrid of grid_internal
  and grid_internal =
    | Row of row_internal * grid_internal
    | NoRow
  and row_internal =
    | Cell of t option * row_internal
    | NoCell

  let void_to_option (x : t) : t option =
    if G.should_void x then None else Some x

  let rec make (rows : t list list) : grid =
    let rec make_row (xs : t list) : row_internal =
      match xs with
      | []      -> NoCell
      | y :: ys -> Cell (void_to_option y, make_row ys)
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
end

module ZeroGrid = GridMapping(struct
  type data = int
  let should_void = fun n -> n = 0
  let string_from = None
end)

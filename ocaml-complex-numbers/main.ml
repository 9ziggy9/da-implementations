module type GridBasis = sig
  type data
  val should_void : data -> bool
  val string_from : (data -> string) option
  val (===)       : data -> data -> bool
end

module type Grid = sig
  type t
  type grid
  val make      : t list list -> grid
  val iterate   : grid -> (t -> unit) -> unit
  val string_of : grid -> string 
  val map       : (t -> t) -> grid -> grid
  val (@@)      : grid -> int * int -> t option
end

(* GridMapping is a Functor *)
(* GridBasis will never be exposed as it is just a parameter to GridMapping *)
(* But we DO want type t exposed, otherwise we must use the type ZeroGrid.t *)
(* ZeroGrid.t to declare elements of ZeroGrid!                              *)
(* This is the reason for the `with type t = G.data` constraint in addition *)
(* to type t assignment (which satisfies Grid interface requirements).      *)
(* If you want to see difference, uncomment functor signature and observe.  *)
(* module GridMapping (B : GridBasis) : Grid = struct *)
module GridMapping (Basis : GridBasis) : Grid with type t = Basis.data = struct
  open Basis
  type t = data
  type grid = PrivateGrid of grid_internal
  and grid_internal =
    | Row of row_internal * grid_internal
    | NoRow
  and row_internal =
    | Cell of t option * row_internal
    | NoCell

  let option_of_void (x : t) : t option =
    if should_void x then None else Some x

  let d_lengths (rows : t list list) : int list =
    let candidate_lengths = List.map (fun row -> List.length row) rows in
    let min_width = List.fold_left max 0 candidate_lengths in
    List.map (fun l -> min_width - l) candidate_lengths

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
      | Cell (Some x, xs) -> begin match string_from with
                                | Some f -> " " ^ f x ^ " "
                                | None   -> " <?> "
                             end ^ string_of_row xs
      | Cell (None, xs)   -> " _ " ^ string_of_row xs
    and string_of_grid (g : grid_internal) = match g with
      | NoRow       -> ""
      | Row (r, rs) -> string_of_row r ^ "\n" ^ string_of_grid rs
    in string_of_grid g

  (* endomorphic variant ! *)
  let map (f: t -> t) (PrivateGrid g) : grid =
    let rec map_row (r : row_internal) = match r with
      | NoCell            -> NoCell
      | Cell (Some x, xs) -> Cell (Some (f x), map_row xs)
      | Cell (None, xs)   -> Cell (None, map_row xs)
    and map_grid (g : grid_internal) = match g with
      | NoRow       -> NoRow
      | Row (r, rs) -> Row (map_row r, map_grid rs)
    in PrivateGrid (map_grid g)

  let fold (f: 'acc -> t -> 'acc) (init : 'acc) (PrivateGrid g) : 'acc =
    let rec fold_grid (acc : 'acc) (g : grid_internal) = match g with
      | Row (r, rs) -> fold_grid (fold_row acc r) rs
      | NoRow       -> acc
    and fold_row (acc : 'acc) (r : row_internal) = match r with
      | NoCell -> acc
      | _ -> fold_cell acc r
    and fold_cell (acc: 'acc) (r: row_internal) = match r with
      | Cell(Some x, xs) -> fold_cell (f acc x) xs
      | Cell(None, xs)   -> fold_cell acc xs
      | NoCell           -> acc
    in fold_grid init g

  (* What happens if I have a name collision with this shit? *)
  let (@@) (grid : grid) ((x, y) : int * int) : t option =
    let rec find_row (g : grid_internal) (x : int) = match g with
      | NoRow       -> None
      | Row (r, rs) -> if x = 0 then Some r else find_row rs (x - 1)
    and find_cell (r : row_internal) (y : int) = match r with
      | NoCell       -> None
      | Cell (v, rs) -> if y = 0 then v else find_cell rs (y - 1)
    in
    match find_row (let (PrivateGrid g) = grid in g) x with
    | None      -> None
    | Some row -> find_cell row y
end

module ZeroGrid = GridMapping(struct
    type data = int
    let should_void = fun n -> n = 0
    let string_from = Some string_of_int
    let (===)       = fun n -> fun m -> n = m
end)

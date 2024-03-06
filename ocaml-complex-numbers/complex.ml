module Complex = struct
  type real =
    | Int of int
    | Float of float

  type complex = { re: real; im: real; }

  (* Helper function to coerce a real to float if necessary *)
  let to_float (r: real) : float =
    match r with
    | Int i -> float_of_int i
    | Float f -> f

  let add_real (r1: real) (r2: real) : real =
    match (r1, r2) with
    | (Int i1, Int i2) -> Int (i1 + i2)
    | (Int i, Float f) -> Float (float_of_int i +. f)
    | (Float f, Int i) -> Float (f +. float_of_int i)
    | (Float f1, Float f2) -> Float (f1 +. f2)

  let sub_real (r1: real) (r2: real) : real =
    match (r1, r2) with
    | (Int i1, Int i2) -> Int (i1 - i2)
    | (Int i, Float f) -> Float (float_of_int i -. f)
    | (Float f, Int i) -> Float (f -. float_of_int i)
    | (Float f1, Float f2) -> Float (f1 -. f2)

  let mul_real (r1: real) (r2: real) : real =
    match (r1, r2) with
    | (Int i1, Int i2) -> Int (i1 * i2)
    | (Int i, Float f) -> Float (float_of_int i *. f)
    | (Float f, Int i) -> Float (f *. float_of_int i)
    | (Float f1, Float f2) -> Float (f1 *. f2)

  let ( + ) (c1: complex) (c2: complex) : complex =
    { re = add_real (c1.re) (c2.re); im = add_real (c1.im) (c2.im); }

  let ( - ) (c1: complex) (c2: complex) : complex =
    { re = sub_real (c1.re) (c2.re); im = sub_real (c1.im) (c2.im); }

  let ( * ) (c1: complex) (c2: complex) : complex =
    { re = sub_real (mul_real c1.re c2.re) (mul_real c1.im c2.im);
      im = add_real (mul_real c1.re c2.im) (mul_real c1.im c2.re); }
end

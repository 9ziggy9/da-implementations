use std::option::Option;

fn divide(a: i32, b: i32) -> Option<i32> {
    if b == 0 { None } else { Some(a / b) }
}

fn main() {
    let x: Option<i32> = Some(42);
    match x {
        Some(n) => println!("The value is: {}", n),
        None    => println!("No value present")
 }
}

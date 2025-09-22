// src/main.rs
use rust_starter_kit::hello; // crate name with dash becomes underscore in code

fn main() {
    let msg = hello::hello("World");
    println!("{}", msg);
}

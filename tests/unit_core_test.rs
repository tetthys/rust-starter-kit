// Pure unit test (no async runtime needed)
use rust_starter_kit::services::hello_service;

#[test]
fn greet_is_pure_and_predictable() {
    let out = hello_service::greet("Tester");
    assert_eq!(out, "Hello, Tester!");
}

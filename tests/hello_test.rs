// tests/hello_test.rs
use rust_starter_kit::hello;

#[test]
fn test_hello_function() {
    let result = hello::hello("ChatGPT");
    assert_eq!(result, "Hello, ChatGPT!");
}

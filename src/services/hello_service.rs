// Pure function (no IO): easy to test.
pub fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

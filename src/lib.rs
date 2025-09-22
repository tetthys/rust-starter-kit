// Public surface kept minimal.
pub mod app;
pub mod di;
pub mod http;
pub mod router;
pub mod middleware;
pub mod security;
pub mod services;
pub mod handlers;

pub use app::App;

pub mod views; // ← 추가
// English comments; Korean explanations are in the chat.
//
// Boot a minimal Hyper v1 server using Tokio runtime.
// Route: GET /hello/{name} -> "Hello, {name}!"

use rust_starter_kit::{app::App, handlers, middleware, router::Route};
use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let _ = fmt().with_env_filter(EnvFilter::from_default_env()).try_init();

    let mut app = App::new();
    app.use_middleware(middleware::logging::LoggingLayer);
    app.add_route(Route::get("/hello/{name}", handlers::hello_handler::hello));

    app.run(([0, 0, 0, 0], 8080)).await?;
    Ok(())
}

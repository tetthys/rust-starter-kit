use rust_starter_kit::{app::App, handlers, middleware, router::Route};
use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let _ = fmt().with_env_filter(EnvFilter::from_default_env()).try_init();

    // Read port from env: APP_PORT (fallback to 8080)
    let port: u16 = std::env::var("APP_PORT")
        .ok()
        .and_then(|v| v.parse::<u16>().ok())
        .unwrap_or(8080);

    let mut app = App::new();
    app.use_middleware(middleware::logging::LoggingLayer);

    app.add_route(Route::get("/hello/{name}", handlers::hello_handler::hello));
    app.add_route(Route::get(
        "/hello_html/{name}",
        handlers::hello_template_handler::hello_html,
    ));
    // (헬스 라우트 추가해 두셨다면) app.add_route(Route::get("/health", handlers::health_handler::health));

    // Bind to 0.0.0.0:port
    app.run(([0, 0, 0, 0], port)).await?;
    Ok(())
}

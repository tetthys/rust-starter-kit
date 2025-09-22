// In-process integration test: listen on an ephemeral port and call the route.

use hyper::Uri;
use hyper_util::client::legacy::{connect::HttpConnector, Client};
use hyper_util::rt::{TokioExecutor, TokioIo};
use rust_starter_kit::{app::App, handlers, router::Route};
use tokio::task;
use std::future::Future;
use std::pin::Pin;
use std::net::SocketAddr;
use http_body_util::{BodyExt, Empty}; // BodyExt for collect(), Empty for request body
use hyper::body::Bytes;

#[tokio::test]
async fn hello_route_returns_200() {
    let mut app = App::new();
    app.add_route(Route::get("/hello/{name}", handlers::hello_handler::hello));

    // Use a concrete SocketAddr (required by tokio::net::ToSocketAddrs)
    let addr: SocketAddr = SocketAddr::from(([127, 0, 0, 1], 0));
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    let local_addr = listener.local_addr().unwrap();

    let server = task::spawn({
        let app = app;
        async move {
            loop {
                let (stream, _) = listener.accept().await.unwrap();
                let io = TokioIo::new(stream);
                let router = app.router.clone();
                let mws = app.middlewares.clone();

                let svc = hyper::service::service_fn(move |req| {
                    let router = router.clone();
                    let mws = mws.clone();
                    async move {
                        // Same coercion as in App::run
                        let router0 = router.clone();
                        let mut next = Box::new(move |r| {
                            let router = router0.clone();
                            let fut = async move { router.handle(r).await };
                            let boxed: Box<
                                dyn Future<
                                        Output = hyper::Result<
                                            hyper::Response<http_body_util::Full<hyper::body::Bytes>>
                                        >
                                    > + Send
                            > = Box::new(fut);
                            Pin::from(boxed)
                        }) as rust_starter_kit::middleware::NextFn;

                        for mw in mws.clone().into_iter().rev() {
                            next = mw.wrap(next);
                        }
                        next(req).await
                    }
                });

                tokio::spawn(async move {
                    let _ = hyper::server::conn::http1::Builder::new()
                        .serve_connection(io, svc)
                        .await;
                });
            }
        }
    });

    // hyper v1 client via hyper-util; set request body B = Empty<Bytes> (implements Default)
    let connector = HttpConnector::new();
    let client: Client<HttpConnector, Empty<Bytes>> =
        Client::builder(TokioExecutor::new()).build(connector);

    let url: Uri = format!("http://{}/hello/Tester", local_addr).parse().unwrap();
    let resp = client.get(url).await.unwrap();
    assert!(resp.status().is_success());

    // hyper v1: use BodyExt::collect().to_bytes()
    let body_bytes = resp.into_body().collect().await.unwrap().to_bytes();
    assert_eq!(body_bytes.as_ref(), b"Hello, Tester!");

    server.abort(); // stop background server
}

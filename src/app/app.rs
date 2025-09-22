// Application shell: DI container + Router + Middleware pipeline.
// Uses hyper-util's TokioIo to serve HTTP/1 connections with hyper v1.

use crate::{di::container::Container, middleware::Middleware, router::Router};
use hyper::{server::conn::http1, service::service_fn, Request};
use hyper_util::rt::TokioIo;
use std::future::Future;
use std::net::SocketAddr;
use std::pin::Pin;
use std::sync::Arc;
use tokio::net::TcpListener;

pub struct App {
    pub container: Container,
    pub router: Router,
    pub middlewares: Vec<Arc<dyn Middleware>>,
}

impl App {
    pub fn new() -> Self {
        Self {
            container: Container::default(),
            router: Router::default(),
            middlewares: Vec::new(),
        }
    }

    pub fn add_route(&mut self, route: crate::router::Route) {
        self.router.add(route)
    }

    pub fn use_middleware<M: Middleware + 'static>(&mut self, mw: M) {
        self.middlewares.push(Arc::new(mw))
    }

    /// Run a simple HTTP server backed by hyper.
    pub async fn run(&self, addr: impl Into<SocketAddr>) -> anyhow::Result<()> {
        let addr = addr.into();
        let listener = TcpListener::bind(addr).await?;
        tracing::info!("listening on http://{}", addr);

        loop {
            let (stream, _) = listener.accept().await?;
            let io = TokioIo::new(stream);
            let router = self.router.clone();
            let mws = self.middlewares.clone();

            tokio::spawn(async move {
                let svc = service_fn(move |req: Request<hyper::body::Incoming>| {
                    let router = router.clone();
                    let mws = mws.clone();
                    async move {
                        // Build base `next` that calls Router::handle.
                        // IMPORTANT: Return `Pin<Box<dyn Future + Send>>` explicitly.
                        let router0 = router.clone();
                        let mut next = Box::new(move |r: Request<_>| {
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
                        }) as crate::middleware::NextFn;

                        for mw in mws.into_iter().rev() {
                            next = mw.wrap(next);
                        }
                        next(req).await
                    }
                });

                if let Err(err) = http1::Builder::new().serve_connection(io, svc).await {
                    tracing::error!("server connection error: {err}");
                }
            });
        }
    }
}

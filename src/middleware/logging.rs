// Simple request logging middleware using `tracing`.

use super::{Middleware, NextFn};
use hyper::{Request, Response};
use std::future::Future;
use std::pin::Pin;

#[derive(Clone, Copy)]
pub struct LoggingLayer;

impl Middleware for LoggingLayer {
    fn wrap(&self, next: NextFn) -> NextFn {
        Box::new(move |req: Request<_>| {
            let method = req.method().clone();
            let path = req.uri().path().to_string();
            let fut = next(req);
            Box::pin(async move {
                let start = std::time::Instant::now();
                let res = fut.await?;
                let elapsed = start.elapsed();
                tracing::info!(%method, %path, status = ?res.status(), elapsed_ms = %elapsed.as_millis());
                Ok::<Response<_>, hyper::Error>(res)
            }) as Pin<Box<dyn Future<Output = _> + Send>>
        })
    }
}

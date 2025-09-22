pub mod logging;

use hyper::{Request, Response};

// NextFn is a tower-like middleware "next" function:
// it must be callable many times (Fn), return a pinned boxed Future.
pub type NextFn = Box<
    dyn Fn(
            Request<hyper::body::Incoming>,
        ) -> std::pin::Pin<
            Box<
                dyn std::future::Future<
                    Output = hyper::Result<Response<http_body_util::Full<hyper::body::Bytes>>>
                > + Send
            >,
        > + Send
        + Sync,
>;

pub trait Middleware: Send + Sync {
    fn wrap(&self, next: NextFn) -> NextFn;
}

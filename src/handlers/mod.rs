pub mod hello_handler;

use hyper::{Request, Response};

pub type HandlerFn = fn(
    Request<hyper::body::Incoming>,
) -> std::pin::Pin<
    Box<
        dyn std::future::Future<
            Output = hyper::Result<Response<http_body_util::Full<hyper::body::Bytes>>>
        > + Send,
    >,
>;

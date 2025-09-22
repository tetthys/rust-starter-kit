// HTTP handler (imperative shell) → delegates to pure service.
use crate::security::csrf::verify_csrf_header;
use crate::services::hello_service;
use http_body_util::Full;
use hyper::{Request, Response};
use hyper::body::Bytes;
use regex::Regex;

fn extract_name(path: &str) -> Option<String> {
    let re = Regex::new(r"^/hello/([^/]+)$").unwrap();
    re.captures(path).and_then(|c| c.get(1)).map(|m| m.as_str().to_string())
}

/// GET /hello/{name}
pub fn hello(
    req: Request<hyper::body::Incoming>,
) -> std::pin::Pin<
    Box<
        dyn std::future::Future<
            Output = hyper::Result<Response<Full<Bytes>>>
        > + Send,
    >,
> {
    Box::pin(async move {
        let path = req.uri().path().to_string();

        // Stub security hook example
        let _ok = verify_csrf_header(req.headers().get("x-csrf-token").and_then(|h| h.to_str().ok()));

        let name = extract_name(&path).unwrap_or_else(|| "World".into());
        let msg = hello_service::greet(&name);
        Ok(Response::new(Full::new(Bytes::from(msg))))
    })
}

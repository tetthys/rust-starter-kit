// src/handlers/hello_template_handler.rs

// HTTP handler that renders an Askama template into an HTML response.

use crate::security::csrf::verify_csrf_header;
use crate::views::HelloTemplate;
use askama::Template as _; // bring .render() trait method into scope
use http_body_util::Full;
use hyper::{header, Request, Response};
use hyper::body::Bytes;
use regex::Regex;

fn extract_name(path: &str) -> Option<String> {
    let re = Regex::new(r"^/hello_html/([^/]+)$").unwrap();
    re.captures(path).and_then(|c| c.get(1)).map(|m| m.as_str().to_string())
}

/// GET /hello_html/{name} → HTML page
pub fn hello_html(
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
        let _ok = verify_csrf_header(req.headers().get("x-csrf-token").and_then(|h| h.to_str().ok()));

        let name = extract_name(&path).unwrap_or_else(|| "World".into());
        let tpl = HelloTemplate { name: &name };

        // Render template; on failure, return 500 with a plain-text error.
        let html = match tpl.render() {
            Ok(s) => s,
            Err(e) => {
                let mut res = Response::builder()
                    .status(500)
                    .header(header::CONTENT_TYPE, "text/plain; charset=utf-8")
                    .body(Full::new(Bytes::from(format!("Template render error: {e}"))))
                    .expect("failed to build 500 response");
                return Ok(res);
            }
        };

        // Build HTML response
        let mut res = Response::new(Full::new(Bytes::from(html)));
        res.headers_mut().insert(
            header::CONTENT_TYPE,
            header::HeaderValue::from_static("text/html; charset=utf-8"),
        );
        Ok(res)
    })
}

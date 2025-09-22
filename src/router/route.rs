// Tiny route matcher: supports GET /hello/{name}

use crate::handlers::HandlerFn;
use hyper::{Method, Request};
use regex::Regex;

#[derive(Clone)]
pub struct Route {
    method: Method,
    re: Regex,
    handler: HandlerFn,
}

impl Route {
    pub fn get(pattern: &str, handler: HandlerFn) -> Self {
        Self::new(Method::GET, pattern, handler)
    }

    pub fn new(method: Method, pattern: &str, handler: HandlerFn) -> Self {
        // Minimal "{name}" support for demo
        let re_str = pattern.replace("{name}", "(?P<name>[^/]+)");
        let re = Regex::new(&format!("^{}$", re_str)).unwrap();

        Self { method, re, handler }
    }

    pub fn match_req(&self, req: &Request<hyper::body::Incoming>) -> Option<HandlerFn> {
        if req.method() != &self.method {
            return None;
        }
        if self.re.is_match(req.uri().path()) {
            Some(self.handler)
        } else {
            None
        }
    }
}

pub mod route;

use hyper::{Request, Response, StatusCode};
use std::sync::Arc;

#[derive(Clone, Default)]
pub struct Router {
    routes: Arc<Vec<Route>>,
}

impl Router {
    pub fn add(&mut self, route: Route) {
        let r = Arc::make_mut(&mut self.routes);
        r.push(route);
    }

    pub async fn handle(
        &self,
        req: Request<hyper::body::Incoming>,
    ) -> hyper::Result<Response<http_body_util::Full<hyper::body::Bytes>>> {
        for route in self.routes.iter() {
            if let Some(handler) = route.match_req(&req) {
                return handler(req).await;
            }
        }
        Ok(Response::builder()
            .status(StatusCode::NOT_FOUND)
            .body(http_body_util::Full::new(hyper::body::Bytes::from_static(b"Not Found")))
            .unwrap())
    }
}

pub use route::Route;

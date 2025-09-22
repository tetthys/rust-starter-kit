// View models rendered by Askama templates.

use askama::Template;

/// Template context for templates/hello.html
#[derive(Template)]
#[template(path = "hello.html")]
pub struct HelloTemplate<'a> {
    pub name: &'a str,
}

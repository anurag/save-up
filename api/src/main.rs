#[macro_use]
extern crate askama;
#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_migrations;
#[macro_use]
extern crate failure;
#[macro_use]
extern crate juniper;
#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate serde_json;
#[macro_use]
extern crate validator_derive;
#[macro_use]
extern crate lazy_static;

extern crate actix;
extern crate actix_web;
extern crate bigdecimal;
extern crate chrono;
extern crate chrono_tz;
extern crate env_logger;
extern crate futures;
extern crate jsonwebtoken as jwt;
extern crate libreauth;
extern crate num_cpus;
extern crate r2d2;
extern crate range_check;
extern crate regex;
extern crate rusoto_core;
extern crate rusoto_ses;
extern crate serde;
extern crate url;
extern crate uuid;
extern crate validator;

use actix::prelude::*;
use actix_web::{
	http, middleware, server, App, AsyncResponder, Error, FutureResponse, HttpRequest,
	HttpResponse, Json, State,
};
use diesel::prelude::*;
use futures::future::{result, Future};
use graph::{GraphQLAppExecutor, GraphQLData, GraphQLPublicExecutor};
use juniper::http::graphiql::graphiql_source;
use models::user::User;

mod actions;
mod graph;
mod models;
mod utils;

struct AppState {
	db: Addr<DbExecutor>,
	executor_app: Addr<GraphQLAppExecutor>,
	executor_public: Addr<GraphQLPublicExecutor>,
}

pub struct DbExecutor(pub utils::db_conn::DBPool);

impl Actor for DbExecutor {
	type Context = SyncContext<Self>;
}

fn graphiql(_req: &HttpRequest<AppState>) -> Result<HttpResponse, Error> {
	let html = graphiql_source("/graphql-app");
	Ok(HttpResponse::Ok()
		.content_type("text/html; charset=utf-8")
		.body(html))
}

fn graphql_public(
	(st, data): (State<AppState>, Json<GraphQLData>),
) -> FutureResponse<HttpResponse> {
	// We could use only one executor
	// If we can send here what context to use
	st.executor_public
		.send(data.0)
		.from_err()
		.and_then(|res| match res {
			Ok(response_data) => Ok(HttpResponse::Ok()
				.content_type("application/json")
				.body(response_data)),
			Err(_) => Ok(HttpResponse::InternalServerError().into()),
		}).responder()
}

fn get_user_from_request(
	db_addr: &Addr<DbExecutor>,
	request: &HttpRequest<AppState>,
) -> Result<User, failure::Error> {
	let header = request
		.headers()
		.get("Authorization")
		.ok_or("No Authorization header found")
		.map_err(|e| format_err!("{}", e))?;

	let txt = header.to_str()?;

	// Get the JWT from the header
	// e.g. Bearer abc123...
	// We don't need the Bearer part,
	// So get whatever is after an index of 7
	let token = &txt[7..];

	// let conn = utils::db_conn::establish_connection()?;

	// let user = get_user(&conn, token)?;

	Err(format_err!("Foo"))
}

fn graphql_app(
	(request, st, data): (HttpRequest<AppState>, State<AppState>, Json<GraphQLData>),
) -> FutureResponse<HttpResponse> {
	let unauthorised = HttpResponse::Unauthorized().finish();

	let db_addr = &request.state().db;

	let user = match get_user_from_request(db_addr, &request) {
		Ok(user) => user,
		Err(_) => return result(Ok(unauthorised)).responder(),
	};

	st.executor_app
		.send(data.0)
		.from_err()
		.and_then(|res| match res {
			Ok(response_data) => Ok(HttpResponse::Ok()
				.content_type("application/json")
				.body(response_data)),
			Err(_) => Ok(HttpResponse::InternalServerError().into()),
		}).responder()
}

fn index(_req: &HttpRequest) -> &'static str {
	"Hello world!"
}

fn main() {
	::std::env::set_var("RUST_LOG", "actix_web=info");
	env_logger::init();

	let sys = actix::System::new("juniper-example");

	let capacity = (num_cpus::get() / 2) as usize;

	// Start http server
	server::new(move || {
		// r2d2 db pool
		let pool = utils::db_conn::init_pool();

		let executor_app_addr = graph::create_app_executor(capacity, pool.clone());

		let executor_public_addr = graph::create_public_executor(capacity, pool.clone());

		let db_addr = SyncArbiter::start(capacity, move || DbExecutor(pool.clone()));

		let state = AppState {
			db: db_addr.clone(),
			executor_app: executor_app_addr.clone(),
			executor_public: executor_public_addr.clone(),
		};

		App::with_state(state)
            // enable logger
            .middleware(middleware::Logger::default())
            .resource("/graphql-pub", |r| r.method(http::Method::POST).with(graphql_public))
            .resource("/graphql-app", |r| r.method(http::Method::POST).with(graphql_app))
            .resource("/graphiql", |r| r.method(http::Method::GET).h(graphiql))
	}).bind("127.0.0.1:4010")
	.unwrap()
	.start();

	println!("Started http server: 127.0.0.1:4010");
	let _ = sys.run();
}

fn get_user(conn: &PgConnection, token: &str) -> Result<User, failure::Error> {
	let config = utils::config::get()?;

	if token == config.system_jwt {
		return Ok(models::user::system_user());
	}

	let token_data = actions::users::decode_token::call(token)?;

	let user_id = token_data.user_id;

	models::user::User::find(&conn, user_id).map_err(|_| format_err!("User not found"))
}

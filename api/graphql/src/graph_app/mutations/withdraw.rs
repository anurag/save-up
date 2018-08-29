use graph_app::context::AppContext;
use graph_common::mutations::failure_to_mutation_errors;
use graph_common::mutations::MutationError;
use juniper::{Executor, FieldResult};
use models::transaction::Transaction;
pub use services::transactions::withdraw::{self, WithdrawalInput};

#[derive(GraphQLObject, Clone)]
pub struct WithdrawalResponse {
	success: bool,
	errors: Vec<MutationError>,
	transaction: Option<Transaction>,
}

pub fn call(executor: &Executor<AppContext>, input: WithdrawalInput) -> FieldResult<WithdrawalResponse> {
	let context = executor.context();

	let result = withdraw::call(&context.conn, input);

	let response = match result {
		Ok(transaction) => WithdrawalResponse {
			success: true,
			errors: vec![],
			transaction: Some(transaction),
		},
		Err(e) => WithdrawalResponse {
			success: false,
			errors: failure_to_mutation_errors(e),
			transaction: None,
		},
	};

	Ok(response)
}
package org.flexunit.internals.runners.statements {
	import org.flexunit.internals.runners.statements.AsyncStatementBase;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.token.AsyncTestToken;

	public class Fail extends AsyncStatementBase implements IAsyncStatement {
		private var error:Error;

		public function Fail( error:Error ) {
			this.error = error;
		}

		public function execute( previousToken:AsyncTestToken ):void {
			throw error;
		}
	}
}

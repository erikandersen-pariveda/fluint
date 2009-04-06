package org.flexunit.internals.runners.statements {
	
	import org.flexunit.token.AsyncTestToken;

	public class AsyncStatementBase {
		protected var parentToken:AsyncTestToken;
		protected var myToken:AsyncTestToken;

		public function AsyncStatementBase() {
			super();
		}

		protected function sendComplete( error:Error = null ):void {
			parentToken.sendResult( error );
		}
		
		public function toString():String {
			return "Async Statement Base";
		}
		
	}
}
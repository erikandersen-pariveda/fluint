package org.flexunit.internals.runners.statements {
	
	import org.flexunit.token.AsyncTestToken;

	public class AsyncStatementBase {
		protected var parentToken:AsyncTestToken;
		protected var myToken:AsyncTestToken;
		protected var sentComplete:Boolean = false;

		public function AsyncStatementBase() {
			super();
		}

		protected function sendComplete( error:Error = null ):void {
			if ( !sentComplete ) {
				sentComplete = true;
				parentToken.sendResult( error );
			} else {
				trace("Whoa... been asked to send another complete and I already did that");
			}
			
		}
		
		public function toString():String {
			return "Async Statement Base";
		}
		
	}
}
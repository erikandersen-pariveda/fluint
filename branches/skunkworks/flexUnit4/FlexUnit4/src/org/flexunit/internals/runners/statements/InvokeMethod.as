package org.flexunit.internals.runners.statements {
	import org.flexunit.internals.runners.statements.AsyncStatementBase;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.runners.model.FrameworkMethod;
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;

	public class InvokeMethod extends AsyncStatementBase implements IAsyncStatement {
		private var testMethod:FrameworkMethod;
		private var target:Object;
		
		public function InvokeMethod( testMethod:FrameworkMethod, target:Object ) {
			this.testMethod = testMethod;
			this.target = target;

			myToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			myToken.addNotificationMethod( handleMethodExecuteComplete );
		}

		public function execute( parentToken:AsyncTestToken ):void {
			this.parentToken = parentToken;

			try {
				testMethod.invokeExplosivelyAsync( myToken, target );
			} catch ( error:Error ) {
				parentToken.sendResult( error );
			}
		}
		
 		protected function handleMethodExecuteComplete( result:ChildResult ):void {
			parentToken.sendResult( null );
		}
		
		override public function toString():String {
			return "InvokeMethod " + testMethod.name;
		}
 	}
}

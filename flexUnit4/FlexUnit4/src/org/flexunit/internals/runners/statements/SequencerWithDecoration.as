package org.flexunit.internals.runners.statements
{
	import org.flexunit.runners.model.FrameworkMethod;
	
	public class SequencerWithDecoration extends StatementSequencer
	{
		private var target:Object;	
		private var afters:Array;

		protected function methodInvoker( method:FrameworkMethod, test:Object ):IAsyncStatement {
			return new InvokeMethod(method, test);
		}

		protected function withPotentialAsync( method:FrameworkMethod, test:Object, statement:IAsyncStatement ):IAsyncStatement {
			return statement;
		}

		protected function withDecoration( method:FrameworkMethod, test:Object ):IAsyncStatement {
			var statement:IAsyncStatement = methodInvoker( method, test );
			statement = withPotentialAsync( method, test, statement );
			
			return statement;
		}

		override protected function executeStep( child:* ):void {
			super.executeStep( child );

			var method:FrameworkMethod = child as FrameworkMethod;
			var statement:IAsyncStatement = withDecoration( method, target );

			try {
				statement.execute( myToken );
			} catch ( error:Error ) {
				errors.push( error );
			}
		}

		public function SequencerWithDecoration( afters:Array, target:Object ) {
			super( afters );
			this.target = target;
		}
	}
}
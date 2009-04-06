package org.flexunit.internals.runners.statements
{
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.internals.runners.statements.SequencerWithDecoration;
	import org.flexunit.runners.model.FrameworkMethod;
	
	public class RunAftersClass extends RunAfters implements IAsyncStatement {
		
		override protected function withPotentialAsync( method:FrameworkMethod, test:Object, statement:IAsyncStatement ):IAsyncStatement {
			var async:Boolean = ExpectAsync.hasAsync( method, "AfterClass" );
			return async ? new ExpectAsync( test, statement ) : statement;
		}

		public function RunAftersClass( afters:Array, target:Object ) {
			super( afters, target );
		}

		override public function toString():String {
			return "RunAftersClass";
		}
	}
}
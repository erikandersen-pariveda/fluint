package org.flexunit.internals.runners.statements
{
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.internals.runners.statements.SequencerWithDecoration;
	import org.flexunit.runners.model.FrameworkMethod;
	
	public class RunAfters extends SequencerWithDecoration implements IAsyncStatement {
		
		override protected function withPotentialAsync( method:FrameworkMethod, test:Object, statement:IAsyncStatement ):IAsyncStatement {
			var async:Boolean = ExpectAsync.hasAsync( method, "After" );
			return async ? new ExpectAsync( test, statement ) : statement;
		}

		public function RunAfters( afters:Array, target:Object ) {
			super( afters, target );
		}

		override public function toString():String {
			return "RunAfters";
		}
	}
}
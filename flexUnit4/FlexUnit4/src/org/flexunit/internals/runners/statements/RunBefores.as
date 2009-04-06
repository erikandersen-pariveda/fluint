package org.flexunit.internals.runners.statements {
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.internals.runners.statements.SequencerWithDecoration;
	import org.flexunit.runners.model.FrameworkMethod;

	public class RunBefores extends SequencerWithDecoration implements IAsyncStatement {

		override protected function withPotentialAsync( method:FrameworkMethod, test:Object, statement:IAsyncStatement ):IAsyncStatement {
			var async:Boolean = ExpectAsync.hasAsync( method, "Before" );
			return async ? new ExpectAsync( test, statement ) : statement;
		}

		public function RunBefores( befores:Array, target:Object ) {
			super( befores, target );
		}

		override public function toString():String {
			return "RunBefores";
		}
	}
}
package org.flexunit.internals.builders {
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.RunnerBuilderBase;

	public class SuiteMethodBuilder extends RunnerBuilderBase {

		override public function runnerForClass( testClass:Class ):IRunner {
			/*
			if ( hasSuiteMethod( testClass ) )
				return new SuiteMethod( testClass );
*/
			return null;
		}
	
		public function hasSuiteMethod( testClass:Class ):Boolean {
			//we will likely need to do some serious introspection here to accomplish this same idea
			if ( testClass[ "suite" ] ) {
				return true;
			}
			
			return false;
		}
	}
}
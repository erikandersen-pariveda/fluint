package org.flexunit.internals.builders {
	import flex.lang.reflect.Klass;
	
	import org.flexunit.internals.runners.SuiteMethod;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.RunnerBuilderBase;

	public class SuiteMethodBuilder extends RunnerBuilderBase {

		override public function runnerForClass( testClass:Class ):IRunner {
			if ( hasSuiteMethod( testClass ) )
				return new SuiteMethod( testClass );

			return null;
		}
	
		public function hasSuiteMethod( testClass:Class ):Boolean {
			var klass:Klass = new Klass( testClass );
			
			if ( klass.getMethod( "suite" ) ) { 
				return true;
			}
			
			return false;
		}
	}
}
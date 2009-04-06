package org.flexunit.internals.requests {
	import org.flexunit.internals.builders.AllDefaultPossibilitiesBuilder;
	import org.flexunit.internals.namespaces.classInternal;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runner.Request;
	
	use namespace classInternal;

	public class ClassRequest extends Request {
		private var testClass:Class;
		private var canUseSuiteMethod:Boolean;
	
		public function ClassRequest( testClass:Class, canUseSuiteMethod:Boolean=true ) {
			this.testClass= testClass;
			this.canUseSuiteMethod= canUseSuiteMethod;
		}

		override public function get iRunner():IRunner {
			return new AllDefaultPossibilitiesBuilder(canUseSuiteMethod).safeRunnerForClass(testClass);
		}
	}
}
package org.flexunit.internals.builders {
	import flexunit.framework.TestCase;
	
	import org.flexunit.internals.runners.FlexUnit38ClassRunner;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.RunnerBuilderBase;

	public class FlexUnit3Builder extends RunnerBuilderBase {

		override public function runnerForClass( testClass:Class ):IRunner {
			if (isPre4Test(testClass))
				return new FlexUnit38ClassRunner(testClass);
			return null;
		}
	
		public function isPre4Test( testClass:Class ):Boolean {
			return testClass is TestCase;
		}		
	}
}
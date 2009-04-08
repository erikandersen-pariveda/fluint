package org.flexunit.internals.builders
{
	import flex.lang.reflect.Klass;
	
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.RunnerBuilderBase;

	public class IgnoredBuilder extends RunnerBuilderBase {
		public static const IGNORE:String = "Ignore";
		override public function runnerForClass( testClass:Class ):IRunner {
			var klassInfo:Klass = new Klass( testClass );

			if ( klassInfo.hasMetaData( IGNORE ) ) {
				return new IgnoredClassRunner(testClass);
			}
			
			return null;
		}
	}
}
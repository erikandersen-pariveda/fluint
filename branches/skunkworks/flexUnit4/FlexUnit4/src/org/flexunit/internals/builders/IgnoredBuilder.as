package org.flexunit.internals.builders
{
	import flash.utils.describeType;
	
	import org.flexunit.internals.builders.IgnoredClassRunner;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.RunnerBuilderBase;
	import org.flexunit.utils.MetadataTools;

	public class IgnoredBuilder extends RunnerBuilderBase {
		override public function runnerForClass( testClass:Class ):IRunner {
			var typeInfo:XML = describeType( testClass );
			var factory:XML = typeInfo.factory[ 0 ]; 

			if ( MetadataTools.nodeHasMetaData( factory, "Ignore" ) ) {
				return new IgnoredClassRunner(testClass);
			}

			return null;
		}
	}
}
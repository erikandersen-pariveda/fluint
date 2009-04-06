package org.flexunit.internals.builders {
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.IRunnerBuilder;
	import org.flexunit.internals.runners.InitializationError;
	import org.flexunit.runners.model.RunnerBuilderBase;
	import org.flexunit.utils.MetadataTools;

	public class MetaDataBuilder extends RunnerBuilderBase {
		private var suiteBuilder:IRunnerBuilder;

		override public function runnerForClass( testClass:Class ):IRunner {
			var typeInfo:XML = describeType( testClass );
			var factory:XML = typeInfo.factory[ 0 ]; 

			if ( MetadataTools.nodeHasMetaData( factory, "RunWith" ) ) {
				var runWithValue:String = MetadataTools.getArgValueFromMetaDataNode( factory, "RunWith", "" );
				return buildRunner( runWithValue, testClass);
			}
			
			return null;
		}

		public function buildRunner( runnerClassName:String, testClass:Class ):IRunner {
			try {
				//Need to check if it actually implements IRunner
				var runnerClass:Class = getDefinitionByName( runnerClassName ) as Class;
				return new runnerClass( testClass );
			} catch ( e:Error ) {
				try {
					return new runnerClass( testClass, suiteBuilder );
				} catch (e:Error ) {
					throw new InitializationError( "Custom runner class " + runnerClassName + " should be linked into project and implement IRunner. Further it needs to have a constructor which either just accepts the class, or the class and a builder." );
				}
			}
 
 			return null;
		}

		public function MetaDataBuilder( suiteBuilder:IRunnerBuilder ) {
			super();
			this.suiteBuilder = suiteBuilder;
		}
	}
}
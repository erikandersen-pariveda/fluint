package org.flexunit.internals.builders {
	import flash.utils.getDefinitionByName;
	
	import flex.lang.reflect.Klass;
	
	import org.flexunit.internals.runners.InitializationError;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.IRunnerBuilder;
	import org.flexunit.runners.model.RunnerBuilderBase;

	public class MetaDataBuilder extends RunnerBuilderBase {
		public static const RUN_WITH:String = "RunWith";
		private var suiteBuilder:IRunnerBuilder;

		override public function runnerForClass( testClass:Class ):IRunner {
			var klassInfo:Klass = new Klass( testClass );

			if ( klassInfo.hasMetaData( RUN_WITH ) ) {
				var runWithValue:String = klassInfo.getMetaData( RUN_WITH ); 
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
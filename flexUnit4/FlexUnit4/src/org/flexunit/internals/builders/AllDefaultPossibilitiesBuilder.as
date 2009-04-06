package org.flexunit.internals.builders {
	import org.flexunit.runner.IRunner;
	import org.flexunit.runners.model.IRunnerBuilder;
	import org.flexunit.runners.model.RunnerBuilderBase;

	public class AllDefaultPossibilitiesBuilder extends RunnerBuilderBase {
		private var canUseSuiteMethod:Boolean;

		public function AllDefaultPossibilitiesBuilder( canUseSuiteMethod:Boolean = true ) {
			this.canUseSuiteMethod= canUseSuiteMethod;
			super();
		}

		override public function runnerForClass( testClass:Class ):IRunner {
			var builders:Array = new Array(
					ignoredBuilder(),
					metaDataBuilder(),
					suiteMethodBuilder(),
					flexUnit3Builder(),
					flexUnit4Builder());
	
			for ( var i:int=0; i<builders.length; i++ ) {
				var builder:IRunnerBuilder = builders[ i ]; 
				var runner:IRunner = builder.safeRunnerForClass( testClass );
				if (runner != null)
					return runner;
			}
			return null;
		}
	
		protected function flexUnit4Builder():FlexUnit4Builder {
			return new FlexUnit4Builder();
		}
	
		protected function flexUnit3Builder():FlexUnit3Builder {
			return new FlexUnit3Builder();
		}
	
		protected function metaDataBuilder():MetaDataBuilder {
			return new MetaDataBuilder(this);
		}
	
		protected function ignoredBuilder():IgnoredBuilder {
			return new IgnoredBuilder();
		}
	
		protected function suiteMethodBuilder():IRunnerBuilder {
			/*
			not sure we want to deal with this in this way, may just instantiate old FlexUnit code
			if (canUseSuiteMethod)
				return new SuiteMethodBuilder();
			*/
			return new NullBuilder();
		}		
	}
}
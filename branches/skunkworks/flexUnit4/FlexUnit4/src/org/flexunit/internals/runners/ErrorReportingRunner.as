package org.flexunit.internals.runners {
	import flash.events.EventDispatcher;
	
	import org.flexunit.runner.Description;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runner.notification.Failure;
	import org.flexunit.runner.notification.RunNotifier;
	import org.flexunit.token.AsyncTestToken;
	
	public class ErrorReportingRunner extends EventDispatcher implements IRunner {
		private var _causes:Array;
		private var _testClass:Class;

		public function ErrorReportingRunner( testClass:Class, cause:Error ) {
			_testClass = testClass;
			_causes = getCauses(cause);
		}

		public function get description():Description {
			var description:Description = Description.createSuiteDescription( _testClass );

			for ( var i:int=0; i<_causes.length; i++ ) {
				description.addChild( describeCause( _causes[ i ] ) );
			}

			return description;
		}

		public function run( notifier:RunNotifier, token:AsyncTestToken ):void {
			for ( var i:int=0; i<_causes.length; i++ ) {
				description.addChild( describeCause( _causes[ i ] ) );
				runCause( _causes[ i ], notifier );
			}
		}

		private function getCauses( cause:Error ):Array {
			/*
			TODO: Figure this whole mess out
			if (cause instanceof InvocationTargetException)
				return getCauses(cause.getCause());
			if (cause instanceof InitializationError)
				return ((InitializationError) cause).getCauses();
			if (cause instanceof org.junit.internal.runners.InitializationError)
				return ((org.junit.internal.runners.InitializationError) cause)
						.getCauses();
			return Arrays.asList(cause);
			*/
			
			if ( cause is InitializationError ) {
				return InitializationError(cause).getCauses();
			}
			
			return [ cause ];
		}

		private function describeCause( child:Error ):Description {
			return Description.createTestDescription( _testClass, "initializationError");
		}
	
		private function runCause( child:Error, notifier:RunNotifier ):void {
			var description:Description = describeCause(child);
			notifier.fireTestStarted( description );
			notifier.fireTestFailure( new Failure(description, child) );
			notifier.fireTestFinished( description );
		}
	}
}
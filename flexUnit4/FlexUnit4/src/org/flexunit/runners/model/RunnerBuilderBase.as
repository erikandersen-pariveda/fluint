package org.flexunit.runners.model {
	import flash.utils.Dictionary;
	
	import org.flexunit.internals.runners.ErrorReportingRunner;
	import org.flexunit.runner.IRequest;
	import org.flexunit.runner.IRunner;


//TODO: class description needed, similar to IRunnerBuilder's? Reference IRunnerBuilder?
	public class RunnerBuilderBase implements IRunnerBuilder {
		private var parents:Dictionary = new Dictionary( true );

		/**
		 * Always returns an IRunner, even if it is just one that prints an error instead of running tests.
		 * @param testClass class to be run
		 * @return an IRunner
		 */
		public function safeRunnerForClass( testClass:Class ):IRunner {
			try {
				return runnerForClass(testClass);
			} catch ( error:Error ) {
				return new ErrorReportingRunner(testClass, error );
			}

			return null;
		}
		
		/**
		 * Constructs and returns a list of IRunners, one for each child class in
		 * {@code children}.  Care is taken to avoid infinite recursion:
		 * this builder will throw an exception if it is requested for another
		 * runner for {@code parent} before this call completes.
		 */
		public function runners( parent:Class, children:Array ):Array {
			addParent(parent);
	
			try {
				//TODO, verify this works the same way in AS
				return localRunners(children);
			} finally {
				removeParent(parent);
			}
			
			return null;
		}

		private function localRunners( children:Array ):Array {
			var runners:Array = new Array();
			
			
			for ( var i:int=0; i<children.length; i++ ) {
				//TODO: Verify this or look further into the world of JUnit for what I am missing.
				//To me this seems reasonable, but, then again there may be a better way
				//This is a bit of a hack. If we are already a request, then we simply return the associated runner
				//This should allow the mixing of Requests, classes and suites into a single construct
				var childRunner:IRunner;  
				var child:* = children[ i ];
				 
				if ( child is IRequest ) {
					childRunner = IRequest( child ).iRunner; 
				} else {
					childRunner = safeRunnerForClass( child );
				}
				
				if (childRunner != null)
					runners.push( childRunner );
			}
			return runners;
		}

		public function runnerForClass( testClass:Class ):IRunner {
			return null;
		}

		private function addParent( parent:Class ):Class {
			if ( !parent ) {
				if ( parents[ parent ] ) {
					//this one already exists
					throw new Error( "Class " + parent + " (possibly indirectly) contains itself as a SuiteClass" );
				}
	
				parents[ parent ] = true;
			}
			
			return parent;
		}

		private function removeParent( parent:Class ):void {
			if ( parent ) {
				delete parents[ parent ];
			}
		}

		public function RunnerBuilderBase() {
		}
	}
}
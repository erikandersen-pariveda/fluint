package org.flexunit.runner {
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.logging.ILogger;
	import mx.logging.ILoggingTarget;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	
	import org.flexunit.internals.TextListener;
	import org.flexunit.runner.notification.Failure;
	import org.flexunit.runner.notification.RunListener;
	import org.flexunit.runner.notification.RunNotifier;
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;

	/**  //TODO: Need to change version support to match supported FlexUnit versions and running instructions
	 * <code>FlexUnitCore</code> is a facade for running tests. It supports running JUnit 4 tests, 
	 * JUnit 3.8.x tests, and mixtures. To run tests from the command line, run 
	 * <code>java org.junit.runner.JUnitCore TestClass1 TestClass2 ...</code>.
	 * For one-shot test runs, use the static method {@link #runClasses(Class[])}. 
	 * If you want to add special listeners,
	 * create an instance of {@link org.junit.runner.JUnitCore} first and use it to run the tests.
	 * 
	 * @see org.flexunit.runner.Result
	 * @see org.flexunit.runner.notification.RunListener
	 * @see org.flexunit.runner.Request
	 */

	public class FlexUnitCore extends EventDispatcher {
		private var notifier:RunNotifier;
		private var logTarget:ILoggingTarget;
		private var logger:ILogger;
		
		private static const RUN_LISTENER:String = "runListener";

		public function get version():String {
			return "4.0.0a";
		}

		private function dealWithArgArray( ar:Array, foundClasses:Array, missingClasses:Array ):void {
			for ( var i:int=0; i<ar.length; i++ ) {
				try {
					if ( ar[ i ] is String ) {
						foundClasses.push( getDefinitionByName( ar[ i ] ) ); 
					} else if ( ar[ i ] is Array ) {
						dealWithArgArray( ar[ i ] as Array, foundClasses, missingClasses );
					} else if ( ar[ i ] is IRequest ) {
						foundClasses.push( ar[ i ] ); 
					} else if ( ar[ i ] is Class ) {
						foundClasses.push( ar[ i ] ); 
					}
				}
				catch ( error:Error ) {
					logger.error( "Cannot find class", ar[i] ); 
					var desc:Description = Description.createSuiteDescription( ar[ i ] );
					var failure:Failure = new Failure( desc, error );
					missingClasses.push( failure );
				}
			}
		}

		/**
		 * Run all the tests contained in <code>args</code>.
		 * @param request the request describing tests
		 * @return a {@link Result} describing the details of the test run and the failed tests.
		 */
		public function run( ...args ):Result {
			var foundClasses:Array = new Array();
			//Unlike JUnit, missing classes is probably unlikely here, but lets preserve the metaphor
			//just in case
			var missingClasses:Array = new Array();
			
			dealWithArgArray( args, foundClasses, missingClasses );

			var listener:RunListener = new TextListener( logger );
			addListener( listener );
			var result:Result = runClasses.apply( this, foundClasses );
			
			for ( var i:int=0; i<missingClasses.length; i++ ) {
				result.failures.push( missingClasses[ i ] );
			}
			
			return result;
		}

		/**  //TODO: No main to link to, what should be linked instead, if anything?
		 * Run the tests contained in <code>args</code>. Write feedback while the tests
		 * are running and write stack traces for all failed tests after all tests complete. This is
		 * similar to {@link #main(String[])}, but intended to be used programmatically.
		 * @param args Array in which to find tests
		 * @return a {@link Result} describing the details of the test run and the failed tests.
		 */
		public function runClasses( ...args ):void {
			runRequest( Request.classes.apply( this, args ) );
		}

		public function runRequest( request:Request ):void {
			runRunner( request.iRunner )
		}
		
		public function runRunner( runner:IRunner ):void {
			var result:Result = new Result();
			var runListener:RunListener = result.createListener();
			addFirstListener( runListener );

			var token:AsyncTestToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			token.addNotificationMethod( handleRunnerComplete );
			token[ RUN_LISTENER ] = runListener;

			try {
				notifier.fireTestRunStarted( runner.description );
				runner.run( notifier, token );
			}
			
			catch ( error:Error ) {
				notifier.fireTestAssumptionFailed( new Failure( runner.description, error ) );
				notifier.fireTestRunFinished( runListener.result );
				removeListener( runListener );
			}
		}
		
		private function handleRunnerComplete( result:ChildResult ):void {
			var runListener:RunListener = result.token[ RUN_LISTENER ];

			notifier.fireTestRunFinished( runListener.result );
			removeListener( runListener );
		}
		
		/**
		 * Add a listener to be notified as the tests run.
		 * @param listener the listener to add
		 * @see org.flexunit.runner.notification.RunListener
		 */
		public function addListener( listener:RunListener ):void {
			notifier.addListener( listener );
		}

		private function addFirstListener( listener:RunListener ):void {
			notifier.addFirstListener( listener );
		}

		/**
		 * Remove a listener.
		 * @param listener the listener to remove
		 */
		public function removeListener( listener:RunListener ):void {
			notifier.removeListener( listener );
		}
		
		protected function buildILoggingTarget():ILoggingTarget {
			var traceTarget:TraceTarget = new TraceTarget();
			traceTarget.level = LogEventLevel.ALL;

            traceTarget.includeDate = true;
            traceTarget.includeTime = true;
            traceTarget.includeCategory = true;
            traceTarget.includeLevel = true;
			
			return traceTarget;
		}

		/**
		 * Create a new <code>FlexUnitCore</code> to run tests.
		 */
		public function FlexUnitCore() {
			notifier = new RunNotifier();
			
			logTarget = buildILoggingTarget();
			Log.addTarget(logTarget);
			
			logger = Log.getLogger("FlexUnit4"); 
		}
	}
}
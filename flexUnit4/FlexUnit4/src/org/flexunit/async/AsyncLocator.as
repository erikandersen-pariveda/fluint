package org.flexunit.async {
	import flash.utils.Dictionary;
	
	import org.flexunit.AssertionError;
	import org.flexunit.internals.runners.statements.IAsyncHandlingStatement;
	
	public class AsyncLocator {
		private static var asyncHandlerMap:Dictionary = new Dictionary();
		
		public static function registerStatementForTest( expectAsyncInstance:IAsyncHandlingStatement, testCase:Object ):void {
			asyncHandlerMap[ testCase ] = expectAsyncInstance;
		} 
		
		public static function getCallableForTest( testCase:Object ):IAsyncHandlingStatement {
			var handler:IAsyncHandlingStatement = asyncHandlerMap[ testCase ];
			
			if ( !handler ) {
				throw new AssertionError("Cannot add asynchronous functionality to methods defined by Test,Before or After that are not marked async");	
			}

			return handler;
		} 

		public static function cleanUpCallableForTest( testCase:Object ):void {
			delete asyncHandlerMap[ testCase ];
		} 
		
/*		private static var instance:AsyncLocator;
		public static function getInstance():AsyncLocator {
			if ( !instance ) {
				instance = new AsyncLocator();
			}
			
			return instance;
		}

		public function AsyncLocator() {
			callableMap = new Dictionary();
		}
*/	}
}
package net.digitalprimates.fluint.async
{
	import mx.rpc.IResponder;
	
	import net.digitalprimates.fluint.tests.ITestCaseRunner;
	import net.digitalprimates.fluint.tests.TestWrapperLocator;
	
	public class Async
	{
		public static function asyncHandler( testCase:Object, eventHandler:Function, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):Function {
			var locator:TestWrapperLocator = TestWrapperLocator.getInstance();
			var runner:ITestCaseRunner;
						
			runner = locator.getRunnerForTest( testCase );
			
			if ( runner ) {
				return runner.asyncHandler( eventHandler, timeout, passThroughData, timeoutHandler );
			}
			
			return null;
		}
		
		public static function asyncResponder( testCase:Object, responder:*, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):IResponder {
			var locator:TestWrapperLocator = TestWrapperLocator.getInstance();
			var runner:ITestCaseRunner;
						
			runner = locator.getRunnerForTest( testCase );
			
			if ( runner ) {
				return runner.asyncResponder( responder, timeout, passThroughData, timeoutHandler );
			}

			return null;
		}
	}
}
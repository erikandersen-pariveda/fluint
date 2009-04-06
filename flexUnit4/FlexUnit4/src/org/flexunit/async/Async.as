package org.flexunit.async
{
	import flash.events.IEventDispatcher;
	
	import mx.rpc.IResponder;
	
	import org.flexunit.AssertionError;
	import org.flexunit.internals.runners.statements.IAsyncHandlingStatement;
	
	public class Async
	{
		public static function proceedOnEvent( testCase:Object, target:IEventDispatcher, eventName:String, timeout:int=500, timeoutHandler:Function = null ):void {
			var asyncHandlingStatement:IAsyncHandlingStatement = AsyncLocator.getCallableForTest( testCase );
			var handler:Function;

			handler = asyncHandlingStatement.asyncHandler( asyncHandlingStatement.pendUntilComplete, timeout, null, timeoutHandler );
			target.addEventListener( eventName, handler, false, 0, true );  
		} 

		public static function failOnEvent( testCase:Object, target:IEventDispatcher, eventName:String, timeout:int=500, timeoutHandler:Function = null ):void {
			var asyncHandlingStatement:IAsyncHandlingStatement = AsyncLocator.getCallableForTest( testCase );
			var handler:Function;

			handler = asyncHandlingStatement.asyncHandler( asyncHandlingStatement.failOnComplete, timeout, null, asyncHandlingStatement.pendUntilComplete );
			target.addEventListener( eventName, handler, false, 0, true );  
		} 

		public static function handleEvent( testCase:Object, target:IEventDispatcher, eventName:String, eventHandler:Function, timeout:int=500, passThroughData:Object = null, timeoutHandler:Function = null ):void {
			var asyncHandlingStatement:IAsyncHandlingStatement = AsyncLocator.getCallableForTest( testCase );
			var handler:Function;

			handler = asyncHandlingStatement.asyncHandler( eventHandler, timeout, passThroughData, timeoutHandler );
			target.addEventListener( eventName, handler, false, 0, true );  
		} 
		
		public static function asyncHandler( testCase:Object, eventHandler:Function, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):Function {
			var asyncHandlingStatement:IAsyncHandlingStatement = AsyncLocator.getCallableForTest( testCase );
						
			return asyncHandlingStatement.asyncHandler( eventHandler, timeout, passThroughData, timeoutHandler );
		}

		public static function asyncResponder( testCase:Object, responder:*, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):IResponder {
			var asyncHandlingStatement:IAsyncHandlingStatement = AsyncLocator.getCallableForTest( testCase );
			
			return asyncHandlingStatement.asyncResponder( responder, timeout, passThroughData, timeoutHandler );
		}
	}
}
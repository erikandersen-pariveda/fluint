package net.digitalprimates.fluint.tests
{
	import flash.events.IEventDispatcher;
	
	import mx.rpc.IResponder;

	public interface ITestCaseRunner extends IEventDispatcher
	{
		function getNextTestMethod():TestMethod;
		function getTestCount():int;
		function runSetup():void;
		function runTestMethod( method:Function ):void;
		function runTearDown():void;
		function asyncHandler( eventHandler:Function, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):Function;
		function asyncResponder( responder:*, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):IResponder;
		function get hasPendingAsync():Boolean;		
		function get objectUnderTest():*;
	}
}
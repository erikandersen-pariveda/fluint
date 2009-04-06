package org.flexunit.internals.runners.statements
{
	import flash.events.Event;
	
	import mx.rpc.IResponder;
	
	import net.digitalprimates.fluint.sequence.SequenceRunner;
	
	public interface IAsyncHandlingStatement
	{
		function get bodyExecuting():Boolean;

		function asyncHandler( eventHandler:Function, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):Function; 
		function asyncResponder( responder:*, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):IResponder;
		
		function failOnComplete( event:Event, passThroughData:Object ):void;
		function pendUntilComplete( event:Event, passThroughData:Object=null ):void;
		function handleNextSequence( event:Event, sequenceRunner:SequenceRunner ):void;
		function handleBindableNextSequence( event:Event, sequenceRunner:SequenceRunner ):void;
	}
}
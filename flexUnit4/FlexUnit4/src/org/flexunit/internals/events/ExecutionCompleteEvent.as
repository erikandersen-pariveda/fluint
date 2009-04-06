package org.flexunit.internals.events
{
	import flash.events.Event;

	public class ExecutionCompleteEvent extends Event {
		public static const COMPLETE:String = "complete";
		public var error:Error;

		public function ExecutionCompleteEvent( error:Error=null  ) {
			this.error = error;
			super(COMPLETE, false, false);
		}
		
		override public function clone():Event {
			return new ExecutionCompleteEvent( error );
		}
	}
}
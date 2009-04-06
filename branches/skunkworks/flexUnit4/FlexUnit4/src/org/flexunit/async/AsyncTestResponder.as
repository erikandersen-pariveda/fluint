package org.flexunit.async {
	import flash.events.EventDispatcher;
	
	import mx.rpc.IResponder;
	
	import org.flexunit.events.AsyncResponseEvent;
	
	[Event(name="responderFired",type="net.digitalprimates.fluint.events.AsyncResponseEvent")]

	public class AsyncTestResponder extends EventDispatcher implements IResponder {
		private var originalResponder:*;		
		
		public function fault( info:Object ):void {
			dispatchEvent( new AsyncResponseEvent( AsyncResponseEvent.RESPONDER_FIRED, false, false, originalResponder, 'fault', info ) );
		}

		public function result( data:Object ):void {
			dispatchEvent( new AsyncResponseEvent( AsyncResponseEvent.RESPONDER_FIRED, false, false, originalResponder, 'result', data ) );
		}
		
		public function AsyncTestResponder( originalResponder:* ) {
			this.originalResponder = originalResponder;
		}
	}
}
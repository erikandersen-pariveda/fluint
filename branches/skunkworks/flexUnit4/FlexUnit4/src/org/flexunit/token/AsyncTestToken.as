package org.flexunit.token {
	import org.flexunit.async.AsyncTestResponder;
	
	dynamic public class AsyncTestToken {
		private var methodsEntries:Array;
		private var _error:Error;
		private var debugClassName:String;
		private var _token:AsyncTestToken;

		public function get parentToken():AsyncTestToken {
			return _token;
		}

		public function set parentToken( value:AsyncTestToken ):void {
			_token = value;
		}
		
		public function get error():Error {
			return _error;
		}
		
		public function addNotificationMethod( method:Function, debugClassName:String="" ):AsyncTestToken {
			if (methodsEntries == null)
				methodsEntries = [];
	
			methodsEntries.push( new MethodEntry( method, debugClassName ) );			

			return this;
		}
		
		private function createChildResult( error:Error ):ChildResult {
			if ( error ) {
				//trace("break here");
			}
			return new ChildResult( this, error );
		}

		public function sendResult( error:Error=null ):void {
			if ( methodsEntries ) {
				for ( var i:int=0; i<methodsEntries.length; i++ ) {
					methodsEntries[ i ].method( createChildResult( error ) );
				}
			}
		}
		
		public function toString():String {
			var output:String = "";
			
			if ( debugClassName ) {
				output += ( debugClassName + ": " );
			}
			
			output += ( methodsEntries.length + " listeners" );
			
			return output; 
		}
		
		public function AsyncTestToken( debugClassName:String = null ) {
			this.debugClassName = debugClassName;
		}
	}
}

class MethodEntry {
	public var method:Function;
	public var className:String;
	
	public function MethodEntry( method:Function, className:String="" ) {
		this.method = method;
		this.className = className;
	}
}
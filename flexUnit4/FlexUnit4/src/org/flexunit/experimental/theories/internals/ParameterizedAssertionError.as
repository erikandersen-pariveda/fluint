package org.flexunit.experimental.theories.internals {
	public class ParameterizedAssertionError extends Error {
		public var targetException:Error;
		public function ParameterizedAssertionError( targetException:Error, methodName:String, ...params ) {
			this.targetException = targetException;
			super( methodName + ( params as Array ).join( ", " ) );
		}
	
//		public function equals( obj:Object ):Boolean {
//			return this.toString() == (obj.toString());
//		}
		
		public static function join( delimiter:String, ...params):String {
			return ( params as Array ).join( delimiter );
		}

//TODO: Figure out when this is needed and how to distinguish from above
/*  		public static function String join(String delimiter,
				Collection<Object> values) {
			StringBuffer buffer = new StringBuffer();
			Iterator<Object> iter = values.iterator();
			while (iter.hasNext()) {
				Object next = iter.next();
				buffer.append(stringValueOf(next));
				if (iter.hasNext()) {
					buffer.append(delimiter);
				}
			}
			return buffer.toString();
		}
 */ 
 		//public function toString():String {
// 			return stringValueOf( this );
 		//}

		private static function stringValueOf( next:Object ):String {
			var result:String;
			
			try {
				result = String(next);
			} catch ( e:Error ) {
				result = "[toString failed]";
			}
			
			return result;
		}
	}
}
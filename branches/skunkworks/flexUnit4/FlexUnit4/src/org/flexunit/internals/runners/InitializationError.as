package org.flexunit.internals.runners {
	
	/**
	 * Represents one or more problems encountered while initializing a Runner
 	*/
	public class InitializationError extends Error {
		private var _errors:Array = new Array();;

		/**
		 * Construct a new {@code InitializationError} with one or more
		 * errors {@code arg} as causes
		 */
		public function InitializationError( arg:* ) {
			if ( arg is Array ) {
				_errors = arg;
			} else if ( arg is String ) {
				_errors = new Array( new Error( arg ) );
			} else {
				_errors = new Array( arg );
			}
			super("InitializationError", 0);
		}

		/**
		 * Returns one or more Throwables that led to this initialization error.
		 */
		public function getCauses():Array {
			return _errors;
		}
	}
}
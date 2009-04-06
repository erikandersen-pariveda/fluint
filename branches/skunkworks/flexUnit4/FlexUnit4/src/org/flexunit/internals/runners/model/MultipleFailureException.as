package org.flexunit.internals.runners.model {
	public class MultipleFailureException extends Error {
		private var errors:Array;

		public function get failures():Array {
			return errors;
		}
		
		public function addFailure( error:Error ):MultipleFailureException {
			if ( !errors ) {
				errors = new Array();
			}

			errors.push( error );
			
			return this;
		}

		public function MultipleFailureException( errors:Array ) {
			this.errors = errors;
			super("MultipleFailureException");
		}
		
	}
}
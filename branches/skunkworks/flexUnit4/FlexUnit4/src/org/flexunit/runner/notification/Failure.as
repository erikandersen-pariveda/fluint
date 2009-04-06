package org.flexunit.runner.notification {
	import org.flexunit.runner.Description;
	
	/**
	 * A <code>Failure</code> holds a description of the failed test and the
	 * exception that was thrown while running it. In most cases the {@link org.flexunit.runner.Description}
	 * will be of a single test. However, if problems are encountered while constructing the
	 * test
	 *  //TODO: no org.flexunit.BeforeClass is there an equivalent?
	 *  (for example, if a {@link org.junit.BeforeClass} method is not static), it may describe
	 * something other than a single test.
	 */
	public class Failure {
		private var _description:Description;
		private var _exception:Error;

		/**
		 * Constructs a <code>Failure</code> with the given description and exception.
		 * @param description a {@link org.flexunit.runner.Description} of the test that failed
		 * @param exception the exception that was thrown while running the test
		 */
		public function Failure( description:Description, exception:Error ) {
			this._description = description;
			this._exception = exception;
		}
		
		/**
		 * @return a user-understandable label for the test
		 */
		public function get testHeader():String {
			return description.displayName;
		}
	
		/**
		 * @return the raw description of the context of the failure.
		 */
		public function get description():Description {
			return _description;
		}
	
		/**
		 * @return the exception thrown
		 */
	
		public function get exception():Error {
		    return _exception;
		}
	
		public function toString():String {
			var str:String = testHeader + ": " + message;
		    return str;
		}
	
		/**
		 * Convenience method
		 * @return the printed form of the exception
		 */
		public function get stackTrace():String {
			return exception.getStackTrace();
		}
	
		/**
		 * Convenience method
		 * @return the message of the thrown exception
		 */
		public function get message():String {
			return exception.message;
		}
		
	}
}
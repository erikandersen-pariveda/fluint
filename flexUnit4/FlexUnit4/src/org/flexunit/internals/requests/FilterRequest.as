package org.flexunit.internals.requests {
	import org.flexunit.internals.runners.ErrorReportingRunner;
	import org.flexunit.runner.IRequest;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runner.Request;
	import org.flexunit.runner.manipulation.Filter;
	import org.flexunit.runner.manipulation.NoTestsRemainException;

	/**
	 * A filtered {@link Request}.
	 */
	public class FilterRequest extends Request {
		private var request:IRequest;
		private var filter:Filter;

		/**
		 * Creates a filtered Request
		 * @param classRequest an {@link IRequest} describing your Tests
		 * @param filter {@link Filter} to apply to the Tests described in 
		 * <code>classRequest</code>
		 */
		public function FilterRequest( classRequest:IRequest, filter:Filter ) {
			super();
			this.request = classRequest;
			this.filter = filter;
		}
		
		//TODO: Unsure of meaning and applicability of @inheritDoc
		/** @inheritDoc */
		override public function get iRunner():IRunner {
			try {
				var runner:IRunner = request.iRunner;
				filter.apply( runner );
				return runner;
			} catch ( error:NoTestsRemainException ) {
				return new ErrorReportingRunner( Filter, 
					new Error( "No tests found matching " + filter.describe + " from " + request ) );
								
			}
			
			return null;
		}
	}
}
package org.flexunit.runner
{
	import flash.events.IEventDispatcher;
	
	import org.flexunit.runner.notification.RunNotifier;
	import org.flexunit.token.AsyncTestToken;
	
	/**
	 * A <code>Runner</code> runs tests and notifies a {@link org.flexunit.runner.notification.RunNotifier}
	 * of significant events as it does so. You will need to subclass <code>Runner</code>
	 * to invoke a custom runner. When creating a custom runner, 
	 * in addition to implementing the abstract methods here you must
	 * also provide a constructor that takes as an argument the {@link Class} containing
	 * the tests.
	 * <p/>
	 * The default runner implementation guarantees that the instances of the test case
	 * class will be constructed immediately before running the test and that the runner
	 * will retain no reference to the test case instances, generally making them 
	 * available for garbage collection.
	 * 
	 * @see org.flexunit.runner.Description
	 */
	public interface IRunner extends IEventDispatcher
	{
		
		/**
		 * Run the tests for this runner.
		 * @param notifier will be notified of events while tests are being run--tests being 
		 * started, finishing, and failing
		 */
		function run( notifier:RunNotifier, previousToken:AsyncTestToken ):void;
		function get description():Description;
	}
}
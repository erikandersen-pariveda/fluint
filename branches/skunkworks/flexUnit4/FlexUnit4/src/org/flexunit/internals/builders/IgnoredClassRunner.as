package org.flexunit.internals.builders {
	import flash.events.EventDispatcher;
	
	import org.flexunit.runner.Description;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runner.notification.RunNotifier;
	import org.flexunit.token.AsyncTestToken;
	
	public class IgnoredClassRunner extends EventDispatcher implements IRunner {
		private var testClass:Class;
	
		public function IgnoredClassRunner( testClass:Class ) {
			this.testClass = testClass;
		}
	
		public function run( notifier:RunNotifier, token:AsyncTestToken ):void {
			notifier.fireTestIgnored( description );
			token.sendResult();
		}
	
		public function get description():Description {
			return Description.createSuiteDescription( testClass );
		}
	}
}
package org.flexunit.internals.runners.model {
	import org.flexunit.runner.Description;
	import org.flexunit.runner.notification.Failure;
	import org.flexunit.runner.notification.RunNotifier;
	
	public class EachTestNotifier {
		private var notifier:RunNotifier;
		private var description:Description;
	
		public function EachTestNotifier( notifier:RunNotifier, description:Description ) {
			this.notifier = notifier;
			this.description = description;
		}
		
		public function addFailure( targetException:Error ):void {
			if (targetException is MultipleFailureException) {
				var  mfe:MultipleFailureException = MultipleFailureException( targetException );
				var failures:Array = mfe.failures;
				for ( var i:int=0; i<failures.length; i++ ) {
					addFailure( failures[ i ] );
				}
				return;
			}
			notifier.fireTestFailure(new Failure( description, targetException));
		}

	//TODO: THis needs to be an AssumptionViolatedException... but I need to get Hamcrest in there for that...so it needs to wait
		public function addFailedAssumption( error:Error ):void {
			notifier.fireTestAssumptionFailed( new Failure( description, error ) );
		}
	
		public function fireTestFinished():void {
			notifier.fireTestFinished(description);
		}
	
		public function fireTestStarted():void {
			notifier.fireTestStarted(description);
		}
	
		public function fireTestIgnored():void {
			notifier.fireTestIgnored(description);
		}
	}
}
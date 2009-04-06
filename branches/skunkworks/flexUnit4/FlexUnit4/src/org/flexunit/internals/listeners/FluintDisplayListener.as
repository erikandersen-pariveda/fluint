package org.flexunit.internals.listeners
{
	import mx.collections.ArrayCollection;
	
	import org.flexunit.runner.Description;
	import org.flexunit.runner.Result;
	import org.flexunit.runner.notification.Failure;
	import org.flexunit.runner.notification.RunListener;
	
	public class FluintDisplayListener extends RunListener
	{
		
		private var lastFailedTest:Description;
		
		[Bindable]
		public var testResults:ArrayCollection = new ArrayCollection();
		 
		override public function testRunStarted( description:Description ):void{
			
		}
		override public function testRunFinished( result:Result ):void {
			
		}
		override public function testStarted( description:Description ):void {
		}
	
		override public function testFinished( description:Description ):void {
			
		//	if(description.displayName != lastFailedTest.displayName){
				testResults.addItem(description);
		//	}
		}
		
		override public function testIgnored( description:Description ):void {
			testResults.addItem(description);
		}
		override public function testAssumptionFailure( failure:Failure ):void {
			testResults.addItem(failure);
		}
	
		override public function testFailure( failure:Failure ):void {
			lastFailedTest = failure.description;
			testResults.addItem(failure);
			
		}
	}
}
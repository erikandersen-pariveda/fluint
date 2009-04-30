package org.flexunit.listeners
{
	import org.flexunit.runner.Description;
	import org.flexunit.runner.Result;
	import org.flexunit.runner.notification.Failure;
	import org.flexunit.runner.notification.IRunListener;
	import org.flexunit.runner.notification.RunListener;

	public class UIListener extends RunListener
	{
		private var uiListener : IRunListener;
		
		public function UIListener( uiListener : IRunListener)
		{
			super();
			this.uiListener = uiListener;
		}
		
		override public function testRunStarted( description:Description ):void {
			this.uiListener.testRunStarted( description );
		}
		
		override public function testRunFinished( result:Result ):void {
			this.uiListener.testRunFinished( result );
		}
		
		override public function testStarted( description:Description ):void {
			this.uiListener.testStarted(description );
		}
	
		override public function testFinished( description:Description ):void {
			this.uiListener.testFinished( description );
		}
	
		override public function testFailure( failure:Failure ):void {
			this.uiListener.testFailure( failure );
		}
	
		override public function testAssumptionFailure( failure:Failure ):void {
			this.uiListener.testAssumptionFailure( failure );
		}
	
		override public function testIgnored( description:Description ):void {
			this.uiListener.testIgnored( description );
		}
	}
}
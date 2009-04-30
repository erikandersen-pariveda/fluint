package org.flexunit.runner.notification
{
	import org.flexunit.runner.Description;
	import org.flexunit.runner.Result;
	
	public interface IRunListener
	{
		function testRunStarted( description:Description ):void;
		function testRunFinished( result:Result ):void;
		function testStarted( description:Description ):void;
		function testFinished( description:Description ):void;
		function testFailure( failure:Failure ):void;
		function testAssumptionFailure( failure:Failure ):void;
		function testIgnored( description:Description ):void;
	}
}
package org.flexunit.runner.notification
{
	import org.flexunit.runner.IDescription;
	import org.flexunit.runner.Result;
	
	public interface IRunListener
	{
		function testRunStarted( description:IDescription ):void;
		function testRunFinished( result:Result ):void;
		function testStarted( description:IDescription ):void;
		function testFinished( description:IDescription ):void;
		function testFailure( failure:Failure ):void;
		function testAssumptionFailure( failure:Failure ):void;
		function testIgnored( description:IDescription ):void;
	}
}
package org.flexunit.runner.manipulation
{
	
	/**
	 * Thrown when a filter removes all tests from an irunner.
	 */
	public class NoTestsRemainException extends Error
	{
		public function NoTestsRemainException(message:String="", id:int=0)
		{
			super(message, id);
		}
		
	}
}
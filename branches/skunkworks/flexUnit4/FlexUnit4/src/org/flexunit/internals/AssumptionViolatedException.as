package org.flexunit.internals
{
	public class AssumptionViolatedException extends Error
	{
		public function AssumptionViolatedException(message:String="", id:int=0)
		{
			super(message, id);
		}
		
	}
}
package org.flexunit.internals
{
	import org.hamcrest.Description;
	import org.hamcrest.Matcher;
	import org.hamcrest.SelfDescribing;
	import org.hamcrest.StringDescription;
	
	public class AssumptionViolatedException extends Error implements SelfDescribing
	{
		private var value:Object;
		private var matcher:Matcher;
	
		public function AssumptionViolatedException( value:Object, matcher:Matcher=null ) {
			super(); //value instanceof Throwable ? (Throwable) value : null);
			this.value = value;
			this.matcher = matcher;
			
			//unfortunate, but best approach for now as we cannot override the message var
			this.message = getMessage();
		}
	
		public function getMessage():String {			
			return StringDescription.toString(this);
		}
	
		public function describeTo( description:Description ):void {
			if (matcher != null) {
				description.appendText("got: ");
				description.appendValue(value);
				description.appendText(", expected: ");
				description.appendDescriptionOf(matcher);
			} else {
				description.appendText("failed assumption: " + value);
			}
		}
	}
}
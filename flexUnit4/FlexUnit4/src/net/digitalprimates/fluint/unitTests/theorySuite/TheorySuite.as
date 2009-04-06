package net.digitalprimates.fluint.unitTests.theorySuite {
	import org.flexunit.experimental.theories.Theories;
	
	[RunWith("org.flexunit.experimental.theories.Theories")]
	public class TheorySuite {
		private var theory:Theories;

		[Theory]
		public function testTheNewTheoriesStuff( value:int ):void {
			// test which involves int value	
		}
 
 		[DataPoints]
		public static var values:Array = [1,2,3,4,5];
	}
}
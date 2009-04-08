package net.digitalprimates.fluint.unitTests.theorySuite {
	import org.flexunit.experimental.theories.Theories;
	
	[RunWith("org.flexunit.experimental.theories.Theories")]
	public class TheorySuite {
		private var theory:Theories;

   		[DataPoints]
  		[ArrayElementType("int")]
		public static var values:Array = [1,2,3,4,5];

  		[DataPoint]
		public static var values1:int = 10;
  		[DataPoint]
		public static var values2:int = 10;
 		[DataPoint]
		public static var str:String = "happy";
 		[DataPoint]
		public static var str2:String = "days";

		[Theory]
		public function testTheNewTheoriesStuff( value:int ):void {
			// test which involves int value	
			//trace( "testTheNewTheoriesStuff " + value );
		}		

  		[Theory]
		public function testTheNewTheoriesStuff1( value:String ):void {
			// test which involves int value	
			//trace( "testTheNewTheoriesStuff1 " + value );
		} 		

		public function TheorySuite( value:String = "nope" ):void {
			//trace("Construct with value " + value );
		}
 
	}
}
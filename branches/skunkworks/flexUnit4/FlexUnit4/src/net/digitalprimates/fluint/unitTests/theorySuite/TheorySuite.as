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
		public static var values2:int = 12;
 		[DataPoint]
		public static var str:String = "happy";
 		[DataPoint]
		public static var str2:String = "days";

   		[DataPoint]
		public static function getDataPoint():int {
			return 67;
		}

   		[DataPoints]
  		[ArrayElementType("int")]
		public static function provideData():Array {
			return [50,52,54,56];
		}

		[Theory]
		public function testIntOnly( value:int ):void {
			// test which involves int value	
			trace( "      int case " + value );
		}		

  		[Theory]
		public function testStringOnly( value1:String ):void {
			// test which involves int value	
			trace( "    string case " + value1 );
		} 		

  		[Theory]
		public function testStringIntCombo( value1:String, value2:int ):void {
			// test which involves int value	
			trace( "    string case " + value1 + " " + value2 );
		} 		

		public function TheorySuite( value:String ):void {
			trace("Constructor with " + value );
		}
		
	}
}
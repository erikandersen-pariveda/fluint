package fluint4
{
	import net.digitalprimates.fluint.assertion.Assert;
	
	public class SampleFlexUnit4
	{
		[BeforeClass]  
		public function runBeforeClass():void {   
		    // run for one time before all test cases   
		}   
		  
		[AfterClass]  
		public function runAfterClass():void {   
		    // run for one time after all test cases   
		}   
		
		[Before(Order=1)]  
		public function thisUsedToBeCalledSetup():void {  
		}   

		[Before]  
		public function iCanNowHaveMoreThanOneSetup():void {   
		}   
		  
		[After]  
		public function thisUsedToBeCalledTearDown():void {   
		}   
		
		[Test]  
		public function addition():void {   
			Assert.assertEquals( 12, 7+5 );
		}   
		
		[Test(description="This is a subtraction test",issueID="12345")]  
		public function subtraction():void {
			Assert.assertEquals( 9, 12-3 );   
		}  

		[Test(expected="flash.errors.IllegalOperationError")]   
		public function divisionWithException():void {   
		    // divide by zero   
		    var i:int = 7/0;   
		} 

		[Ignore]   
		[Test]  
		public function multiplication():void {   
		    //don't run me   
		}
		
		[Test(timeout=1000)]   
		public function infinity():void {   
		    while (true)   
		        ;   
		}
		
		[Filter]
		public function thisIsAFilterFunction( item:Object ):Boolean {
			return true;
		}

		[Filter]
		public function thisIsAlsoAFilterFunction( item:Object ):Boolean {
			return true;
		}
		
		[Sort]
		public function thisIsASortFunction( a:Object, b:Object ):int {
			return 0;
		}
		
	}
}
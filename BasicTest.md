## Creating a Test Case ##
  * In the same project as your test runner, create a directory called sampleSuite.
  * Create a directory inside of sampleSuite named tests.
  * In the sampleSuite/tests directory, create a new ActionScript class named TestCase1, with a superclass of `net.digitalprimates.fluint.tests.TestCase`.
## Creating a Test Method ##
  * Inside of TestCase1, create a new method called `testMath()` that looks like this:
```
	public function testMath():void {
		var x:int = 5 + 3;
		
		assertEquals( 8, x )
	}
```
  * While ridiculously simple, this test shows that the ‘+’ operator in ActionScript works correctly. You assert that the result of this `Math` operation should be equal to 8.
## Creating a Test Suite ##
  * One directory above, in the sampleSuite directory, create a new ActionScript class named SampleSuite. Set the superclass to net.digitalprimates.fluint.tests.TestSuite.
  * Import the TestCase1 class you just created with the following code:
```
	import sampleSuite.tests.TestCase1;
```
  * Add a constructor to the class, which calls a method of the TestSuite named `addTestCase`, to register your test case in this suite. Your code should look like this:
```
	public function SampleSuite() {
		addTestCase( new TestCase1() );
	}
```
## Working with the Test Runner ##
  * Open up your SampleTestRunner file and import the SampleSuite.
```
	import sampleSuite.SampleSuite;
```
  * In the sample test suite, you should see a line of code that calls the `startTests` method of the `testRunner` instance. This method can accept a single test case, a test suite or an array of test suites. Modify your code to look like the following:
```
		protected function startTestProcess( event:Event ):void {
			var suiteArray:Array = new Array();
			suiteArray.push( new SampleSuite() );
			testRunner.startTests( suiteArray );
		}
```
This instructs the test runner to run your suite on startup. Any number of suites can be pushed into this array and run consecutively.

## Running the Test Suite ##
If you run the SampleTestRunner at this point, it should start and run the single test method, in the single test case, in your single test suite.
## Suggested Directory Organization ##
The fluint framework doesn’t prescribe a directory structure for testing files; however, the following suggestions have worked well:
  * Each test suite should have its own directory.
  * The suite definition (subclass of the TestSuite class) should reside in this directory.
  * Within the directory for the test suite, create a tests directory.
  * Inside of this directory store each of your test cases (subclasses of the TestCase class) for this test suite.
  * Any additional classes needed to accomplish testing can be stored in further subdirectories.

Ideally, the directory structure looks something like this
```
testSuite1/ 
	TestSuite1.as 
	tests/ 
		TestCase1.as 
		TestCase2.as 
		TestCase3.as 
testSuite2/ 
	TestSuite2.as  
	tests/ 
		TestCase1.as 
		TestCase2.as 
		TestCase3.as 

```

[Previous](TestRunners.md) | [Next](AsyncTest.md)
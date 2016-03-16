## Assumptions ##
This entry assumes you have followed the steps so far to download the SampleTestRunner and to build your first test suite and case. If you have not, feel free to read on, but a clearer picture can be obtained by reviewing this from [the beginning](GettingStarted.md).
## Asynchronous Test Defined ##
An asynchronous test is a test that depends on some action that may not happen synchronously. An excellent example of this is an HTTPService in Flex. You make a call to the server to get data and, when the data is available, you are notified via an event. The original method which made that server call may have completed long ago.
Many of the common properties set on UIComponents in Flex are actually asynchronous. When setting a property on a given control, often the intended value is stored in a private variable and applied later during the `commitProperties()` method. Inherently this means we need asynchronous capability to truly test these features.
## Approach ##
To simulate asynchronous events without the need for services or dealing with the complexity of UIComponents, we are going to use timers. This will help to illustrate the major points while keeping the code to a minimum.
## Create a New Test Case ##
  * Inside of your test runner project, browse to the sampleSuite/tests directory (the location where you previously created your TestCase1.as).
  * Create a new ActionScript class named TestAsync.as with a superclass of net.digitalprimates.fluint.tests.TestCase.
  * Import the Timer and the TimerEvent classes.
```
	import flash.utils.Timer;
	import flash.events.TimerEvent;
```
  * Inside the class definition for TestAsync, create a new private variable named `timer` of type Timer.
```
	private var timer:Timer;
```
  * Override the `setUp()` method from the TestCase class. This method will be called before each of your test methods.
```
	override protected function setUp():void {
			
	}
```
  * Inside the `setUp()` method, instantiate the `timer` variable as illustrated in the following code:
```
	override protected function setUp():void {
		timer = new Timer( 100, 1 );			
	}
```

> This creates a new Timer that will complete 100 milliseconds after it is started and only triggers once.
  * Next, override the `tearDown()` method of the TestCase class to stop the `timer` and set the `timer` reference to `null` when the test is complete.
```
	override protected function tearDown():void {
		timer.stop();
		timer = null;
	}
```
  * Now, create a new public method called `testTimerLongWay()`.
```
	public function testTimerLongWay():void {
			
	}
```

> In this method, we are going to setup our asynchronous handlers the long way to clearly illustrate the steps. In future methods, we are going to take an abbreviated approach.
  * As the first line of your `testTimerLongWay()` method, add this code which creates a new asynchronous handler.
```
	var asyncHandler:Function = asyncHandler( handleTimerComplete, 500, null, handleTimeout );
```

> This code calls a method of the TestCase called `asyncHandler()` to create a special class (the AsyncHandler class) that will monitor your test for an asynchronous event. The first parameter of this method is the event handler to call if everything works as planned (we received our asynchronous event). The second parameter is the number of milliseconds we are willing to wait, in this case 500. The third parameter is a generic object for passing additional data called `passThroughData`; we will deal with that shortly. The last parameter is the timeout handler. This is the method that will be called if the timeout (500ms) is reached before our asynchronous handler is called.
  * As the next line in our function, we will add an event listener to the timer instance for a `TIMER_COMPLETE` event. When this event occurs, we will call the `asyncHandler` function we defined on the line above.
```
	timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true );			
```

> Note: This event listener is using weak references. If you don’t feel comfortable with that concept, there are a lot of [great](http://www.joeberkovitz.com/blog/2007/06/20/moment-of-weakness-weak-event-listeners-can-be-dangerous/) [articles](http://www.colettas.org/?p=115) written on the topic. I strongly advise you to take a look.
  * On the next line, add the code to start the timer. Your completed method should look like this:
```
	public function testTimerLongWay():void {
		var asyncHandler:Function = asyncHandler( handleTimerComplete, 500, null, handleTimeout );
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true );
		timer.start();			
	}
```

> Following this procedure, we have let the TestCase code know that it should wait for either the `TIMER_COMPLETE` event or the 500ms timeout to occur before attempting to decide if the test case was a success or failure. Without this call to `asyncHandler`, this particular test method would be marked a success as soon as the method body finished executing.
  * In our event handler, the call to `asyncHandler`, we have referenced two methods that do not yet exist, `handleTimerComplete` and `handleTimeout`. Define those now as:
```
 	protected function handleTimerComplete( event:TimerEvent, passThroughData:Object ):void {
			
	}

	protected function handleTimeout( passThroughData:Object ):void {
			
	}

```

> Note that the `handleTimerComplete()` method takes two parameters, an `event` object and an object called `passThroughData`. The `handleTimeout()` method only has a single parameter, the `passThroughData`.
  * We will leave the body of the `handleTimerComplete()` message blank for now, but add a `fail()` method call to the `handleTimeout()` method so that it looks like the following code
```
	protected function handleTimeout( passThroughData:Object ):void {
		fail( "Timeout readed before event");			
	}
```

> This tells the TestCase that this particular method should fail if it ever reaches the `handleTimeout()` method
## Add the Test Case to the Suite ##
Before we can run this TestCase, we need to add it to a TestSuite.
  * Open the sampleSuite/SampleSuite.as file
  * Import the new asynchronous test case
```
	import sampleSuite.tests.TestAsync;
```
  * Add a new `addTestCase()` method call directly below the existing one to add a new instance of your TestAsync:
```
	public function SampleSuite() {
		addTestCase( new TestCase1() );
		addTestCase( new TestAsync() );
	}
```
Your SampleSuite now includes two distinct test cases.
## Testing Asynchronously ##
  * Run your SampleTestRunner application and you should see two distinct tests that pass. It will take a moment longer than before. The disadvantage of asynchronous testing is that is does take more time, but many tests need to be handled asynchronously to be valid.
  * Next change the Timer in setup to complete after 1000ms.
```
	override protected function setUp():void {
		timer = new Timer( 1000, 1 );			
	}
```
  * Run your SampleTestRunner application and you should see a failure for this test as the timeout expired before the timer event fires. Clicking on the red item in the progress bar will provide more information about the failure.
  * Change your Timer back to 100ms and let’s discuss a way of combining this into a single statement
## Combined Syntax ##
Above we created a test method by defining the `asyncHandler()` and `addEventListener()` on two separate lines. This can have some advantages if the developer is trying to manually remove and manage listeners. However, in the average case, this can be combined into a single statement like in the method below, `testTimerShortWay()`:
```
	public function testTimerShortWay():void {
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( handleTimerComplete, 500, null, handleTimeout ), false, 0, true );
		timer.start();			
	}
```

Add this method to your TestAsync case and re-run the SampleTestRunner. You should now see three passing tests. Note that you re-used both the `eventHandler` and `timeoutHandler` from the previous example. You should see significant reuse in well-crafted handlers as you continue to develop test cases.
## Pass Through Data ##
Learning to use the `passThroughData` parameter of the `asyncHandler()` method will give you the most flexibility in writing reusable handlers. Any data passed into the handler will be passed to either the `eventHandler` on success or the `timeoutHandler` on a timeout.

Building on the previous example, here is another Timer test that uses the Timer's current count property. We'll call this test `testTimerCount()`. The first thing this method will do is create a generic object and add a property called `repeatCount` to that object.

We will set the `repeatCount` property of the timer to the value contained in this object. Previously, we always passed a null to the `passThroughData` property of the `asyncHandler()` method. This time, however, we will pass the object `o` that you created at the beginning of the method. We instruct `asyncHandler()` to call `handleTimerCheckCount` when the `TIMER_COMPLETE` event occurs.

```
        public function testTimerCount() : void {
	        var o:Object = new Object();
	    	o.repeatCount = 3;

	    	timer.repeatCount = o.repeatCount;
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler( handleTimerCheckCount, 500, o, handleTimeout ), false, 0, true );
		timer.start();	
	}
```

Next, create a `handleTimerCheckCount()` method. It will call `assertEquals()` and compare the `currentCount` property of the Timer to the `repeatCount` property of our passthrough data.

```
	protected function handleTimerCheckCount( event:TimerEvent, passThroughData:Object ):void {
	        assertEquals( ( event.target as Timer ).currentCount, passThroughData.repeatCount );
	}
```

In our test, we tell the timer to count to repeat three times before it broadcasts the `TIMER_COMPLETE` message. Then, in our `handleTimerCheckCount()` method, we ensure that the Timer's `currentCount` (the number of times the Timer has repeated) is correct. The important part is that we have now created a generic handler function which uses data created during the test. This same handler could be used for many different tests. Many more examples of this concept will be reviewed when we start testing UIComponents in the next sections.

Note: Fluint supports asynchronous responder testing in addition to the event testing discussed in this section. While this concept is applicable to many areas of testing, it will be covered in the Cairngorm section of this documentation.

[Previous](BasicTest.md) | [Next](AsyncSetup.md)
## Assumptions ##
This entry assumes you have followed the steps so far to download the SampleTestRunner and to build your first test suite and case. If you have not, feel free to read on, but a clearer picture can be obtained by reviewing this from [the beginning](GettingStarted.md).
## Asynchronous SetUp and TearDown Defined ##
This is the part where I feel I should begin apologizing to the testing purists. We are going to begin conflating the concepts of unit and integration testing in ways that should likely be avoided. So, in advance, please take this whole suite and especially these documents as an explanation of a framework and tool set, and not as an explanation of best practices.

That said, as you begin creating more complicated asynchronous unit tests and start writing integration tests, you will likely have a need for a more complex testing environment of test fixtures. The point of this entire framework is to test UIComponent class derivates of arbitrary complexity. In Flex, UIComponents inherently have asynchronous aspects.

When you add a TextInput to your application, it is not immediately drawn on the screen, nor is its internal state completely stable. The TextInput, let alone more complicated controls such as ComboBox, go through a complex process before they are ready. This process involves creating children, measurement, and layout, as well as committing any properties to the control that were specified at creation or immediately after. Until this entire process is complete, any tests you write against this component may be invalid. Dependent upon the speed of your machine and other tasks running, each time you run your test the control could be in a slightly different state.

To be consistent with our tests, we need to wait until the control is valid and in a known state before we begin testing against it. This is the point of asynchronous setup and (potentially) asynchronous teardown: to ensure the controls under testing are in a known and valid state before continuing.

## Approach ##
In this example, we are going to use the TextInput. It is a relatively simple UIComponent (from a testing perspective) and very familiar to most users. We will create a TextInput in `setUp` and wait until it issues a `creationComplete` event, telling us that it has been created and initialized, before we continue on with each of our tests.

## Create a New Test Case ##
  * Inside of your test runner project, browse to the sampleSuite/tests directory (the location where you previously created your TestCase1.as).
  * Create a new ActionScript class named TestAsyncSetup.as with a superclass of `net.digitalprimates.fluint.tests.TestCase`.
  * Import the TextInput, the FlexEvent and the Event classes.
```
	import mx.controls.TextInput;
	import mx.events.FlexEvent;
	import flash.events.Event;
```

  * Inside of the class definition for TestAsyncSetup, create a new private variable named `textInput` of type TextInput.
```
	private var textInput:TextInput;
```

  * Override the `setUp()` method from the TestCase class. This method will be called before each of your test methods.
```
	override protected function setUp():void {
			
	}
```

  * Inside the `setUp()` method, instantiate the `textInput` variable as illustrated in the following code:
```
	override protected function setUp():void {
		textInput = new TextInput();
	}
```

> This creates a new TextInput that we will add to the application.

  * Next, add an event listener to `textInput` for the `creationComplete` event. Using the short syntax we defined in the previous section; create an asynchronous handler which will wait 1000ms before throwing an error. When the `creationComplete` event does occur, call a method named `pendUntilComplete`.
```
	override protected function setUp():void {
		textInput = new TextInput();
		textInput.addEventListener(FlexEvent.CREATION_COMPLETE,	asyncHandler( pendUntilComplete, 1000 ), false, 0, true );
	}
```

> `pendUntilComplete` is an empty method of the TestCase class. You could specify your own method for this parameter, but as we simply wish to wait until this event occurs and do not plan on checking the state, we can save a few lines of repetitive typing.

  * Now, we need to add the TextInput to the display list. Right now the TextInput exists in memory, but until it is added to the display list, it does not begin the process of creating any children or performing any layout. Our TestCase class is not a UIComponent itself, nor does it exist on the display list; however, it does provide a façade for adding these children to a special singleton container defined in the TestRunner called `testEnvironment`. All of the basic child manipulation methods are supported. These include.
    * `addChild`
    * `addChildAt`
    * `removeChild`
    * `removeChildAt`
    * `removeAllChildren`
    * `getChildAt`
    * `getChildByName`
    * `getChildIndex`
    * `setChildIndex`
    * `numChildren`

> Further, you can directly access the test environment through your test case if needed. Add the TextInput to the test environment using the `addChild` method
```
	override protected function setUp():void {
		textInput = new TextInput();
		textInput.addEventListener(FlexEvent.CREATION_COMPLETE,	asyncHandler( pendUntilComplete, 1000 ), false, 0, true );
		addChild( textInput );
	}
```

  * You as the test developer are responsible for cleaning up in the `tearDown` method anything you create in the `setUp` method. Override the `tearDown()` method of the TestCase class to remove the TextInput from the test environment and set its reference to null.
```
        override protected function tearDown():void {
		removeChild( textInput );
		textInput = null;
	}
```

  * Now, create a new public method called `testSetTextProperty()`.
```
        public function testSetTextProperty():void {
		
	}
```

> In this method, we are going to set the `text` property of our control and later check that it has been set properly. Many of the UIComponents in Flex set a private variable internal to the control when you set one of their many properties. Later, in a method called `commitProperties`, they often deal with this change and apply it as needed to the control. Unfortunately, this means that writing to a property and immediately reading from it only tests your machine’s ability to read and write memory. To truly ensure that a value has been committed to a control we often need to wait for an event before re-reading it.

  * We are immediately going to use the `passThroughData` and short method of adding an asynchronous test discussed in the previous section. Create and instantiate a new object called `passThroughData`. Create a property in that object called `propertyName` and set its value to 'text'. Next, create a property called `propertyValue` and set its value to ‘digitalprimates’. Your method should look like this:
```
        public function testSetTextProperty() : void {
    	        var passThroughData:Object = new Object();
    	        passThroughData.propertyName = 'text';
    	        passThroughData.propertyValue = 'digitalprimates';	    	
        }
```

  * As the next line in our function, we will add an event listener to the TextInput instance for a `VALUE_COMMIT` event. When this event occurs, we will call a method named `handleVerifyProperty`. If the event does not occur, we will call `handleEventNeverOccurred`. Let’s allow 100ms for this event to occur and provide our `passThroughData` object created above as the `passThroughData` parameter as follows:
```
        public function testSetTextProperty() : void {
    	        var passThroughData:Object = new Object();
    	        passThroughData.propertyName = 'text';
    	        passThroughData.propertyValue = 'digitalprimates';
	    	
    	        textInput.addEventListener( FlexEvent.VALUE_COMMIT, asyncHandler( handleVerifyProperty, 100, passThroughData, handleEventNeverOccurred ), false, 0, true );
        }
```

  * On the next line, add the code to actually set the `text` property to the specified value. Your completed method should look like this:
```
        public function testSetTextProperty() : void {
    	        var passThroughData:Object = new Object();
    	        passThroughData.propertyName = 'text';
    	        passThroughData.propertyValue = 'digitalprimates';
	      	
    	        textInput.addEventListener( FlexEvent.VALUE_COMMIT, asyncHandler( handleVerifyProperty, 100, passThroughData, handleEventNeverOccurred ), false, 0, true );
    	        textInput.text = passThroughData.propertyValue; 
        }
```

> Following this procedure, we have let the TestCase code know that it should wait for either the `VALUE_COMMIT` event or the 100ms timeout to occur before attempting to decide if the test case was a success or failure. Without the call to `asyncHandler`, this particular test method would be marked a success as soon as the method body finished executing.

  * In our event handler, the call to `asyncHandler`, we have referenced two methods that do not yet exist, `handleVerifyProperty` and ` handleEventNeverOccurred`. Define those now as:
```
        protected function handleVerifyProperty( event:Event, passThroughData:Object ):void {
        }
	    
        protected function handleEventNeverOccurred( passThroughData:Object ):void {
    	        fail('Pending Event Never Occurred');
        }
```

> This tells the TestCase that this particular method should fail if it ever reaches the `handleEventNeverOccurred` method

  * Next, we are going to add an `assertEquals` to the `handleVerifyProperty` method. The method will use the `passThroughData` values to check if the `text` property is set to 'digitalprimates' in a dynamic way that could be used for many tests.
```
        protected function handleVerifyProperty( event:Event, passThroughData:Object ):void {
    	        assertEquals( event.target[ passThroughData.propertyName ], passThroughData.propertyValue );
        }
```

## Add the Test Case to the Suite ##
Before we can run this TestCase, we need to add it to a TestSuite:
  * Open the sampleSuite/SampleSuite.as file
  * Import the new asynchronous test case
```
	import sampleSuite.tests.TestAsyncSetup;
```

  * Add a new `addTestCase` method call directly below the existing one to add a new instance of your TestAsyncSetup:
```
	public function SampleSuite() {
		addTestCase( new TestCase1() );
		addTestCase( new TestAsync() );
		addTestCase( new TestAsyncSetup() );
	}
```

Your SampleSuite now includes three distinct test cases.

## Testing Asynchronous Setup ##
  * Run your SampleTestRunner application and you should see that the TestAsyncSetup test case also ran with a success on the `testSetTextProperty` test method.

This test creates a TextInput, waits for it to be ready, sets a property, waits for an event to occur and tests that property. It provides the foundation for integration testing. In the next sections we will dive further into testing using UIComponent subclasses and eventually discuss sequence testing.

[Previous](AsyncTest.md) | [Next](Sequences.md)
## Assumptions ##
This entry assumes you have followed the steps so far to download the SampleTestRunner, build your first test suite and case, and understand the asynchronous features. If you have not, feel free to read on, but a clearer picture can be obtained by reviewing this from [the beginning](GettingStarted.md).

## Testing with Sequences… What? ##
Even a simple test for a relatively complicated component can quickly become tedious to write. Let’s take the example of a login form, which has username and password text inputs and a button which broadcasts an event to login.
To test that login form, we first need to set the username and the password, wait until they are committed to their respective controls, click the button, and watch for the login event. We would then check its data against the values we set. Using the asynchronous approach we have discussed so far this would require five to seven distinct methods to implement this single test. Writing many of these tests wouldn’t be fun and would likely be error prone.

Sequences are an attempt to reduce the pain associated with these tests. They provide a simpler method of defining the steps that need to happen in order, and potentially asynchronously, before we can assert. The sequence is still designed to test one thing, just like the other tests, but it acknowledges that many steps may need to occur first.

## Approach ##
In this example, we are going to write a single test for a login form. The login form will be created as a custom MXML component. We will instantiate the component in the `setUp()` method and wait until the `creationComplete` event fires before beginning our test.
Our test will set the username and password. Once the values have been committed, we will simulate the login button click and wait for a custom login event to be broadcast. Once that event is received, we will check that the password matches what we entered.

## Create the Login Form ##
  * Inside of your test runner project, browse to the sampleSuite/tests directory (the location where you previously created your TestCase1.as).
  * Create a new folder named ‘mxml’
  * In the mxml folder, create a new MXML component named LoginForm.mxml that extends Panel.
  * Copy the following code into LoginForm.mxml
```
        <?xml version="1.0" encoding="utf-8"?>
        <mx:Panel xmlns:mx="http://www.adobe.com/2006/mxml" layout="vertical" title="Please Login" height="168">
	        <mx:Metadata>
		        [Event(name="loginRequested", type="flash.events.TextEvent")]
	        </mx:Metadata>
	
	        <mx:Script>
		        <![CDATA[
			        protected function handleLoginClick( event:Event ):void {
				        dispatchEvent( new TextEvent( 'loginRequested', false, false, passwordTI.text ) );	
			        }
		        ]]>
	        </mx:Script>
	
	        <mx:Form width="100%">
		        <mx:FormItem label="Username" required="true">
			        <mx:TextInput id="usernameTI"/>
		        </mx:FormItem>
		        <mx:FormItem  label="Password" required="true">
			        <mx:TextInput id="passwordTI" displayAsPassword="true"/>
		        </mx:FormItem>
	        </mx:Form>
	        <mx:HBox width="100%" horizontalAlign="center">
		        <mx:Button id="loginBtn" label="Login" click="handleLoginClick( event )"/>
	        </mx:HBox>
        </mx:Panel>
```

> This is just a simple login form that allows the entry of a username and password and broadcasts an event when the login button is clicked. The event we chose to broadcast is a TextEvent. We chose this event because it has an extra property where we can store the password. This isn’t a real world use case for the event, but it will work for our purposes.

  * Move back up to the sampleSuite/tests directory.
  * Create a new ActionScript class named TestSequences.as with a superclass of `net.digitalprimates.fluint.tests.TestCase`.
  * Start by importing the following classes.
```
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;

	import sampleSuite.tests.mxml.LoginForm;
 
```

  * Inside of the class definition for TestSequences, create a new private variable named `form` of type LoginForm.
```
	private var form:LoginForm;
```

  * Override the `setUp()` method from the TestCase class. This method will be called before each of your test methods.
```
	override protected function setUp():void {
			
	}
```

  * Inside the `setUp()` method, instantiate the `form` variable as illustrated in the following code. Tell the test case that it needs to wait until the `creationComplete` event of the form before continuing and add the form to the test environment:
```
	override protected function setUp():void {
		form = new LoginForm();
		form.addEventListener( FlexEvent.CREATION_COMPLETE, asyncHandler( pendUntilComplete, 100 ), false, 0, true );
		addChild( form );
	}
```

  * Override the `tearDown()` method of the TestCase class to remove the LoginForm instance from the test environment and set its reference to null.
```
	override protected function tearDown():void {
		removeChild( form );			
		form = null;
	}
```

  * Now, create a new public method called `testLogin()` and add all of the following code. Unlike the previous steps, we are just going to show the entire code block to perform this test sequence and then proceed to explain it line by line. Line numbers are shown for easy reference in the following explanation.
```
	import net.digitalprimates.fluint.sequence.SequenceEventDispatcher;
	import net.digitalprimates.fluint.sequence.SequenceRunner;
	import net.digitalprimates.fluint.sequence.SequenceSetter;
	import net.digitalprimates.fluint.sequence.SequenceWaiter;


	public function testLogin():void {
1	    	var passThroughData:Object = new Object();
2	    	passThroughData.username = 'myuser1';
3	    	passThroughData.password = 'somepsswd';
4
5	    	var sequence:SequenceRunner = new SequenceRunner( this );
6
7		sequence.addStep( new SequenceSetter( form.usernameTI, {text:passThroughData.username} ) );
8		sequence.addStep( new SequenceWaiter( form.usernameTI, FlexEvent.VALUE_COMMIT, 100 ) );
9
10		sequence.addStep( new SequenceSetter( form.passwordTI, {text:passThroughData.password} ) );
11		sequence.addStep( new SequenceWaiter( form.passwordTI, FlexEvent.VALUE_COMMIT, 100 ) );
12
13		sequence.addStep( new SequenceEventDispatcher( form.loginBtn, new MouseEvent( 'click', true, false ) ) );
14		sequence.addStep( new SequenceWaiter( form, 'loginRequested', 100 ) );
15			
16		sequence.addAssertHandler( handleLoginEvent, passThroughData );
17			
18		sequence.run();
	}
```

> On lines 1-3 we create our generic object for passThroughData and set a username and password property inside of it to ‘myuser1’ and ‘somepsswd’. This object will be used later for comparison to ensure our form functions properly

> On line 5, we create a new SequenceRunner. This object is responsible for ensuring the steps in our sequence are followed in order and that we wait, when necessary, for the previous step to complete before proceeding to the next.

> On line 7, we call `sequence.addStep()`. The `addStep` method adds steps to our testing sequence, it will be called repeatedly as we continue to add steps.

> Still on line 7, we pass a new instance of the SequenceSetter class to `addStep`. The SequenceSetter is used to set one or more properties on a specific target. The first parameter to the SequenceSetter constructor is the target where the properties will be set. The second parameter is a generic object with name-value pairs that represent these properties. This line specifically sets the `text` property of the username TextInput inside of the form to the value defined in our `passThroughData.username`.

> Line 8 creates and adds a new SequenceWaiter to the sequence. A SequenceWaiter instructs the sequence to pause until a specific event occurs. The first parameter to the SequenceWaiter constructor is a target, which must implement IEventDispatcher. The second is the name of the event we expect will occur. The third parameter is the number of milliseconds we should wait for that event. There is an optional fourth parameter, which is a method to call if the expected event does not occur before the timeout. If you do not provide this method, the Sequence code uses a default version built into the framework. This line specifically tells the sequence to wait for the username TextInput inside of the form to broadcast a `valueCommit` event, indicating that the `text` property has been committed, before proceeding to the next step.

> In general, the `valueCommit` property usually means that a given property is stable inside of a control. This, like most things, is not only up for argument but also varies slightly between controls. The larger point here is that these sequence tests are, almost by definition, clear box tests. You need to know how the control works to accomplish this type of testing. Those with intimate knowledge of the framework may note that, with TextInputs, the `valueCommit` doesn’t actually buy us much when setting the `text` property. While true, the above is only meant to be an example from which to learn, not a complete test suite.

> Lines 10 and 11 repeat the same procedure above for the password field, ensuring that the value is committed before we continue our sequence.

> Line 13 adds an instance of the SequenceEventDispatcher class to the sequence. The constructor for this class takes two parameters. The first is the target, which must be an IEventDispatcher from which you wish to broadcast an event. The second is an instance of an Event object that you wish to broadcast. Practically, this step causes the login button inside of the form to broadcast a ‘click’ event as though a user had clicked the button. The LoginForm that you created earlier calls a function to broadcast a custom event once that button is clicked.

> Line 14 instructs the sequence to wait until the form broadcasts a `loginRequested` before proceeding with the sequence.

> On line 16, we add an `assertHandler` to the sequence. An `assertHandler` is a method that will be called when the end of the sequence is reached, so that the developer can perform any asserts and ensure the test succeeded. The first parameter of `addAssertHandler` is the method to be called. The method signature is the same as the other asynchronous handlers created in previous sections. The second parameter is the `passThroughData` for that handler.

> Line 18 starts this sequence from the beginning. The SequenceRunner will follow each of these steps until any step fails or the end of the sequence is reached. If the end is reached, the method defined in the `addAssertHandler` will be called and the `passThroughData` will be sent along.

  * Now, create a new protected method called `handleLoginEvent()` and add the following code:
```
    protected function handleLoginEvent( event:TextEvent, passThroughData:Object ):void {
    	assertEquals( passThroughData.password, event.text );
    }
```

> This method will be called when the sequence ends successfully. The `assertEquals` will check that the `text` property of the TextEvent matches the password we put into the password field. If they match, the process of adding a password to the form’s password field, clicking the login button, and broadcasting an event with the password included worked.

## Add the Test Case to the Suite ##
Before we can run this TestCase, we need to add it to a TestSuite:

  * Open the sampleSuite/SampleSuite.as file
  * Import the new sequence test case
```
	import sampleSuite.tests.TestSequences;
```

  * Add a new `addTestCase` method call directly below the existing one to add a new instance of your TestSequences:
```
	public function SampleSuite() {
		addTestCase( new TestCase1() );
		addTestCase( new TestAsync() );
		addTestCase( new TestAsyncSetup() );
		addTestCase( new TestSequences() );
	}
```

Your SampleSuite now includes four distinct test cases.

## Testing Sequences ##

  * Run your SampleTestRunner application and you should see that the TestSequences test case also ran with a success on the `testLogin` test method.

Hopefully you see the power that sequences can bring to writing maintainable tests. Next we will apply sequences to Cairngorm to see how testing commands and entire views become possible.

[Previous](AsyncSetup.md) | [Next](Cairngorm.md)
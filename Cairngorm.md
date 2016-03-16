## Assumptions ##
This entry assumes you have followed the steps so far to download the SampleTestRunner, build your first test suite and case and understand the sequence features. If you have not, feel free to read on, but a clearer picture can be obtained by reviewing this from [the beginning](GettingStarted.md).

## Testing with Cairngorm ##
Cairngorm-based applications create some additional complexity when testing. In our opinion, the main areas requiring test are:
  * The views
  * The commands
  * The complete integration from user gesture through the controller, to the command, and eventually to the model.

This section does not introduce many new concepts but rather shows the application of sequences and asynchronous testing to Cairngorm applications.

## Approach ##
In the [previous](Sequences.md) section, we demonstrated the ability to test a view with sequences. Here we will demonstrate testing commands and finally use sequences to test a series of user gestures through a final update to the model.

## Environment Setup ##

To perform this testing, we need a Cairngorm-based application for demonstration purposes. We chose to use a minimally modified version of the one found at [cairngormdocs.org](http://cairngormdocs.org/blog/?p=18). Download the example app from the link provided and unzip it into the project containing your test runner.

Please note that, once again, this is not an exercise in best practices for organizing code and libraries alongside your testing code. This is just a demonstration of using this framework with the Cairgnorm micro-architecture.

If you don’t already have the Cairngorm SWC or project in your development environment, then download the  [Cairngorm 2.2.1 Binary](http://weblogs.macromedia.com/amcleod/archives/downloads/Cairngorm2_2_1-bin.zip) from the Adobe Labs site. Unzip it and copy the Cairngorm.swc into the project containing your test runner.

Next, add this SWC library to your build path by:

  * Project Properties->Flex Build Path.
  * Click the Library Path tab
  * Click the Add SWC button
  * Browse to the Cairngorm.swc and click OK
  * Click OK on the Properties panel to close it.

Before continuing, ensure that you can build and launch CairngormDiagram.mxml. Add a contact and see that the interface is working as expected before we attempt to reuse these classes in test below.

## A quick modification ##
The sample CairngormDiagram sample application will work great for our needs, but we need to make one quick modification. Any UIComponent classes we plan to test need to have a specified ‘id’ so that we can access them through the test suite.

In the AddContactPanel (the view) of this particular application, the ‘AddContact’ button does not currently have an id.  So, we must add one.

  * Open AddContactPanel.mxml from the com/adobe/cairngorm/samples/addcontact/view directory
  * Find the Button with the label ‘AddContact’
  * Set the button’s `id` to `addBtn`. Your code should look like this:
```
        <mx:Button id="addBtn" label="AddContact" enabled="{ !addcontact.isPending }" click="addContact()"/>   

```

  * Save this file. It is the only modification we will make to this application before writing tests for it.

## Creating a TestCase ##
Next, we will create a TestCase for our Cairngorm sample. We will be testing a command and the entire flow from user input through the change to the ModelLocator.

  * Move back up to the sampleSuite/tests directory.
  * Create a new ActionScript class named TestCairngorm.as with a superclass of `net.digitalprimates.fluint.tests.TestCase`.
  * Start by importing the following classes. If you are using FlexBuilder, it will handle this for you. If not, this will save you a few minutes of hunting and typing.
```
	import com.adobe.cairngorm.samples.addcontact.control.AddContactControl;
	import com.adobe.cairngorm.samples.addcontact.model.ModelLocator;
	import com.adobe.cairngorm.samples.addcontact.view.AddContactPanel;

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;

	import net.digitalprimates.fluint.sequence.SequenceEventDispatcher;
	import net.digitalprimates.fluint.sequence.SequenceRunner;
	import net.digitalprimates.fluint.sequence.SequenceSetter;
	import net.digitalprimates.fluint.sequence.SequenceWaiter;
```

  * Inside of the class definition for TestCairngorm, create three new private variables as shown below:
```
	private var controller:AddContactControl;
	private var addContactPanel:AddContactPanel;
	private var model:ModelLocator;
```

  * Override the `setUp()` method from the TestCase class. Inside the `setUp()` method, instantiate these variables as illustrated in the following code. Tell the test case that it needs to wait until the `creationComplete` event of the AddContactPanel before continuing. Don’t forget to add the view to the test environment:
```
	override protected function setUp():void {
		model = ModelLocator.getInstance();
		controller = new AddContactControl();
			
		addContactPanel = new AddContactPanel();
		addContactPanel.addEventListener( FlexEvent.CREATION_COMPLETE, asyncHandler( pendUntilComplete, 500 ), false, 0, true );
		addChild( addContactPanel );
	}
```

  * Override the `tearDown()` method of the TestCase class to clean up this mess from the test environment when the test is complete.
```
	override protected function tearDown():void {
		model = null
		controller = null;
		
		removeChild( addContactPanel );
		addContactPanel = null;
	}
```

  * Now, create a new public method called `testAddNewContact()` and add all of the following code. We are just going to show the entire code block to perform this test sequence and then proceed to explain it line by line. Line numbers are shown for easy reference in the following explanation.
```
	public function testAddNewContact():void {
1		var passThroughData:Object = new Object();
2		passThroughData.fullName = 'mike';
3		passThroughData.email = '1@2.com';
4			
5		var sequence:SequenceRunner = new SequenceRunner( this );
6			
7		sequence.addStep( new SequenceSetter( addContactPanel.fullname, {text:passThroughData.fullName} ) );
8		sequence.addStep( new SequenceWaiter( addContactPanel.fullname, FlexEvent.VALUE_COMMIT, 100 ) );
9			
10		sequence.addStep( new SequenceSetter( addContactPanel.emailaddress, {text:passThroughData.email} ) );
11		sequence.addStep( new SequenceWaiter( addContactPanel.emailaddress, FlexEvent.VALUE_COMMIT, 100 ) );
12			
13		sequence.addStep( new SequenceEventDispatcher( addContactPanel.addBtn, new MouseEvent( 'click', true, false ) ) );
14		sequence.addStep( new SequenceWaiter( model.contacts, CollectionEvent.COLLECTION_CHANGE, 3000 ) );
15			
16		sequence.addAssertHandler( handleModelChanged, passThroughData );
17			
18		sequence.run();
	}

```

> On lines 1-3 we create our generic object for `passThroughData` and set a `fullName` and `email` property inside of it to ‘mike’ and ‘1@2.com’. This object will be used later for comparison to ensure our form functions properly.

> On line 5, we create a new SequenceRunner. This object is responsible for ensuring the steps in our sequence are followed in order and that we wait, when necessary, for the previous step to complete before proceeding to the next.

> On line 7, we instruct the sequence set the `text` property of the `fullName` text input inside of the AddContactPanel to the value defined in our `passThroughData.fullName`.

> Line 8 instructs the sequence to wait for the `fullName` text input inside of the form to broadcast a `valueCommit` event, indicating that the `text` property has been committed, before proceeding to the next step.

> Line 10 and 11 repeat the same procedure above for the `email` field, ensuring that the value is committed before we continue our sequence.

> Line 13 instructs the add button inside of the form to broadcast a `click` event as though a user had clicked the button. The AddContactPanel broadcasts a Cairngorm event when this button is clicked. The controller will then call the AddContactCommand that eventually updates the model.

> Line 14 instructs the sequence to wait until the `contacts` collection inside the ModelLocator broadcasts a `COLLECTION_CHANGE` event. The AddContactCommand, called by the button we "clicked" in Line 13 will eventually update the contacts collection.

> On line 16, we add the `handleModelChanged` method as an `assertHandler` to the sequence. This will be called once the `ModelLocator.contacts` broadcasts its event.

> Line 18 starts this sequence from the beginning.

  * Now, create a new protected method called `handleModelChanged()` and add the following code:
```
	protected function handleModelChanged( event:CollectionEvent, passThroughData:Object ):void {
		assertEquals( event.items[0], ( passThroughData.fullName + ' ' + passThroughData.email ) );
	}
```

> This method checks that the item added to the `Model.contacts` collection is the concatenation of our full name plus our email address. This concatenation replicates the code in the result handler of the AddContactCommand.

## Add the Test Case to the Suite ##
Before we can run this TestCase, we need to add it to a TestSuite:

  * Open the sampleSuite/SampleSuite.as file
  * Import the new Cairngorm test case
```
	import sampleSuite.tests.TestCairngorm;
```

  * Add a new `addTestCase` method call directly below the existing one to add a new instance of your TestCairngorm:
```
	public function SampleSuite() {
		addTestCase( new TestCase1() );
		addTestCase( new TestAsync() );
		addTestCase( new TestAsyncSetup() );
		addTestCase( new TestSequences() );
		addTestCase( new TestCairngorm() );
	}
```

Your SampleSuite now includes five distinct test cases.

## Testing Cairngorm ##

  * Run your SampleTestRunner application and you should see that the TestCairngorm test case also ran with a success on the `testAddNewContact` test method.

## Testing Commands ##

Unfortunately, the Cairgnorm command is designed to be self-contained. So, in the scenario where the command must talk to the server and return a result, it usually does so by shoving that data into the ModelLocator. It does not emit an event of its own, nor allow us to register ourselves as a listener for that result.

As such, the only way we can actually test the command directly is to follow sequences like the one above: we listen for changes in the ModelLocator and execute the command directly. The sequence above did this all the way from the User Interface forward; however, it could be easily modified to simply start by calling the command and ignoring the existence of the controller and the AddContactPanel.

One thing that we absolutely can test, though, is the actual server call through a delegate.

## Testing Delegates ##
The fluint framework also provides support for asynchronous responders. This support allows you to directly test delegate classes in Cairngorm. Here is a brief example of the approach along with an explanation options.

```
	public function testDelegate():void {
1		var someVO:SomeVO = new SomeVO();
2		someVO.myName = 'Mike Labriola';
3		someVO.yourAddress = '1@2.com';
4
5		var responder:IResponder = asyncResponder( new TestResponder( handleResult, handleFault ) , 3000, someVO );
6		var delegate : MyDelegate = new MyDelegate( responder );   
7		   
8		delegate.addSomeData( someVO );	      
9	}
10		
11	protected function handleResult( data:Object, passThroughData:Object ):void {
12		assertEquals( data.myName, passThroughData.myName );
13	}
14
15	protected function handleFault( info:Object, passThroughData:Object ):void {
16		fail("Received fault from Server");
17	}
```

Lines 1-3, we create a new instance of a value object called `someVO`.

On Line 5, we define a variable of type IResponder and call our `asyncResponder` method to create a new class that implements the IResponder interface. Much like our `asyncHandler` method, this class takes several parameters.

  * The first is an object which implements either the mx.rpc.IResponder interface or an object which implements the net.digitalprimates.fluint.async.ITestResponder interface. We will describe the differences between these two interfaces shortly. In this case, we create an instance of the TestResponder class and pass it the `handleResult` and `handleFault` methods as result and fault handlers, respectively.

  * The second is the time, in milliseconds, we are willing to wait for our responder to be called.

  * The third is `passThroughData`, a generic object that will potentially be sent along to the result or fault handler. Note, in this case, we decided to send the actual valueObject. Any object can act as a valid parameter.

  * The fourth parameter (not shown in the code above) is a handler to call if the timeout is reached before the responder is called.

On Line 6, we instantiate our delegate. Normally, delegates are passed a reference to the command which implements IResponder; in this case, we will pass the object created on line 5.

Line 8 invokes a method of the delegate and begins the server call.

If the result method of our responder is called before the timeout, the `handleResult` method will be called and passed the accompanying data. It will also receive a reference to any `passThroughData` we defined above.

If the fault method of our responder is called before the timeout, the `handleFault` method will be called and passed the accompanying info. It will also receive a reference to any `passThroughData` we defined above.


It was mentioned above that, on line 5, you could pass an object that implements either ITestResponder or IResponder to the `asyncResponder` method. If you choose to use ITestResponder, your `handleResult` and `handleFault` methods can accept the optional `passThroughData` parameter.  If you instead pass an object that implements IResponder to this method, your result and fault handler will follow the standard Flex definition and will not receive a copy of the `passThroughData`.

Next we will discuss controlling the order and selection of your test cases.


[Previous](Sequences.md) | [Next](Order.md)
package net.digitalprimates.fluint.tests
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.TextEvent;
  import flash.events.TimerEvent;
  
  import mx.collections.ICollectionView;
  import mx.collections.IViewCursor;
  import mx.controls.Alert;
  import mx.controls.DataGrid;
  import mx.controls.listClasses.IListItemRenderer;
  import mx.core.Application;
  import mx.core.IChildList;
  import mx.core.UIComponent;
  import mx.events.CloseEvent;
  import mx.events.FlexEvent;
  import mx.events.IndexChangedEvent;
  import mx.events.ListEvent;
  import mx.managers.ISystemManager;
  import mx.managers.PopUpManager;
  import mx.rpc.http.HTTPService;
  import mx.utils.ObjectUtil;
  
  import net.digitalprimates.fluint.sequence.*;
  import net.digitalprimates.fluint.ui.TestComponentViewer;
  import net.digitalprimates.fluint.utils.ArrayUtils;
  import net.digitalprimates.fluint.utils.ComponentFinder;
  import net.digitalprimates.fluint.utils.LoggerUtils;
  
  
  
  /**
   * TestCase which can load a UI component loaded from a module.
   * 
   * <h2>Motivations</h2>
   * <p>
   * 
   * </p>
   * 
   * <h2>Selectors: Direct and Delayed</h2>
   * <p>
   * 
   * </p>
   */
  public class ComponentTestCase extends TestCase
  {
    /** Factory function that generates the component under test. */
    private var _componentFactory:Function;
    
    /** Reference the current component under test. This gets reset with *every* test. */
    private var _uiComponent:UIComponent;
    
    /** Adds the ability to view the components state after a test has passed. */
    private var _componentViewer : TestComponentViewer;
    
    protected var componentFinder : ComponentFinder;
    
    private var lastAssertFailure : Error;
    
    /**
     * Creates a new ComponentTestCase.
     * 
     * @param componentFactory a function which will create a new component for every test
     * @param useComponentViewer whether or not to retain the state of the component <em>after</em> test so that the developer can look at its visual state from the test runner
     */
    public function ComponentTestCase(componentFactory : Function, useComponentViewer : Boolean = true)
    {
      _componentFactory = componentFactory;
      if (useComponentViewer) {
          _componentViewer = TestComponentViewer.instance();
      }
    }
    
    /**
     * Initialize the SequenceRunner and prepare the component for testing.
     * 
     * Steps of the setup sequence are thus:
     * 
     * <ol>
     * <li>Create new SequenceRunner</li>
     * <li>Instantiate the component using the _componentFactory function</li>
     * <li>Invoke restoreState() method</li>
     * <li>Request the component be added to the screen</li>
     * <li><em>At some point in the future</em>, the component is added to the screen and initialized.  When this occurs, it fires
     *     the uiComponentReady() function.</li>
     * </ol>
     */
    override protected function setUp():void {
      trace("");
      trace("===========================================");
      // trace("Recording for " + currentTestName);
      trace("===========================================");
      
      lastAssertFailure = null;
      
      // The setupSequence
      sequence = new SequenceRunner(this);
      _uiComponent = _componentFactory();
      
      componentFinder = new ComponentFinder(_uiComponent);
      
      // At this point, _uiComponent has not be initialized yet.  
      // None of the preinitialize, initialize, creationComplete, updateComplete events have been fired
      // In fact, all of the properties of _uiComponent (buttons, datagrids, textfields) are still NULL at this point
      restoreState();
      
      // After the restoreState sequence has had a chance to play out, add component
      assertFinished(function() {
          trace("Restore state should be done by now")
          
          if (_componentViewer) {
              _componentViewer.setup(this);
          } else {
              _uiComponent.visible = false;
              _uiComponent.addEventListener(FlexEvent.CREATION_COMPLETE, asyncHandler(creationComplete, 5000));
              addChild(_uiComponent);
          }    
      });
      
    }
    
    /**
     * Called when the _uiComponent has finished initializing for this test method.
     */
    public function creationComplete(event : Event,  passThroughData : Object):void {
      trace("Creation Complete; begin new sequence");  
        
      sequence = new SequenceRunner(this);
      uiComponentReady();
    }
    
    /**
     * Called before every test method with a valid SequenceRunner and valid uiComponent to enable restoration of the server.
     * 
     * <p>Subclasses should override this method if they need to restore the state of the server.  Restoration of the state of the
     * client is done automatically as every test method uses a completely new instance of the component under test.</p>
     */
    protected function restoreState() : void 
    {
    } 
    
    /**
     * Called when the UI Component under test is ready to be accessed.
     * 
     * <p>It is assumed subclasses will override this method and cast the component to an instance variable of the correct type 
     * to make code completion work.  For example:</p>
     * <p><pre>
     * override protected function uiComponentReady() : void {
     *   this.buttonControls = uiComponent as ButtonControlsScreen;
     * } 
     * </pre></p>
     */
    protected function uiComponentReady() : void {
    }
    
    /**
     * Unloads the UI component under test.
     * 
     * <p>You don't want to modify the state of your _uiComponent in the teardown as its appearence in the test runner should
     * reflect its final state.  This convention greatly assists test writers to see the finished state of the component
     * after the test has ran.  However, since pop-ups are modal dialogs and cover the screen, all pop-ups are closed in tear down.</p>
     */
    override protected function tearDown():void {
      this.sequence = null;
      
      if (_componentViewer) {
          _componentViewer.teardown(this);
      } else {
          removeChild(_uiComponent);
          _uiComponent = null;
      }
    }
    
    /**
     * The component currently under test.  Gets reset every test method using the <code>_componentFactory</code> function passed into the constructor.
     * It is guaranteed to be fully initialized by the time the test method gets it.
     * 
     * <p>
     * While you can reference this object directly, it is common practice to create a new variable in your test class with the more specific type 
     * of your component.  That gives you better static typing and as a result, allows autocomplete.  You can assign your more specific variable
     * in the <code>uiComponentReady</code> method.
     * </p>
     */
    public function get uiComponent() : UIComponent 
    {
      return _uiComponent;
    }
    
    // --------- Sequence Helper Methods
    
    /** 
     * The default <code>SequenceRunner</code> provided to every subclass.  It is initialized automatically in the <code>#setUp</code> method. 
     */
    protected var sequence : SequenceRunner;
    
    /**
     * Generic timeout handler for all SequenceWaiters.
     */ 
    private function timeoutHandler(e : SequenceRunner) : void 
    {
      fail("Timed out waiting for event: " + e.getPendingStep().eventName + " on " + LoggerUtils.friendlyName(e.getPendingStep().target));
    }
    
    /**
     * Records the equivalent sequences of a user clicking on an object.
     * 
     * <p>The following events are dispatched on the <code>target</code> object:</p>
     * <ul>
     * <li>MouseEvent.MOUSE_DOWN</li>
     * <li>MouseEvent.MOUSE_UP</li>
     * <li>MouseEvent.CLICK</li>
     * </ul>
     * 
     * @param target any component capable of dispatching mouse click events or a function which returns an event dispatcher
     */
    public function clickOn( target:Object ) : void 
    {
      waitUntilNotNull(target);
      assertVisibleAndEnabled(target);
      trace("Clicking on '" + LoggerUtils.friendlyName(target) + "'");    
      
      sequence.addStep( new SequenceEventDispatcher( target, new MouseEvent(MouseEvent.MOUSE_DOWN, true, false) ));
      sequence.addStep( new SequenceEventDispatcher( target, new MouseEvent(MouseEvent.MOUSE_UP, true, false) ));  
      sequence.addStep( new SequenceEventDispatcher( target, new MouseEvent(MouseEvent.CLICK, true, false) ));
    }
   
    /**
     * Simulate typing the given value into the target.
     * 
     * <p>The following events are dispatched on the <code>target</code> object:</p>
     * <ul>
     * <li>FlexEvent.VALUE_COMMIT</li>
     * <li>KeyboardEvent.KEY_DOWN</li>
     * <li>KeyboardEvent.KEY_UP</li>
     * <li>TextEvent.TEXT_INPUT</li>
     * <li>Event.CHANGE (<em>only if</em> the value of the text property changed</li>
     * </ul>
     * 
     * @param value the string value to enter into the component
     * @param target any component (or Function which returns such) with a text property
     */  
    public function typeInto( value:String, target:Object ) : void 
    {
      waitUntilNotNull(target);
      assertVisibleAndEnabled(target);
      trace("Setting '" + value + "' into '" + LoggerUtils.friendlyName(target) + "'");
      
      var sequenceSetter : SequenceSetter = new SequenceSetter( target, {text:value} );
      sequence.addStep( sequenceSetter );
      
      // Blank values will not trigger validation, so we need to fake it by firing a VALUE_COMMIT
      // TODO Doing this is probably not right as it does not accurately reflect what the user will experience
      //      This seems to be a shortcut for unit testing the validator objects themselves ... maybe consider a different
      //      method like, typeIntoAndValidate which will always do validation
      if (value == "") 
      {
        trace("Triggering validate for '" + LoggerUtils.friendlyName(target) + "'");
        sequence.addStep( new SequenceEventDispatcher( target, new FlexEvent(FlexEvent.VALUE_COMMIT) ));
      }  
      
      sequence.addStep( new SequenceWaiter( target, FlexEvent.VALUE_COMMIT, 1000, timeoutHandler ));
      sequence.addStep( new SequenceCaller(null, function():void {
      	var uiComponent : UIComponent = processComponentReference(target);
      	uiComponent.dispatchEvent( new KeyboardEvent(KeyboardEvent.KEY_DOWN) );
      	uiComponent.dispatchEvent( new KeyboardEvent(KeyboardEvent.KEY_UP) );
      	uiComponent.dispatchEvent( new TextEvent(TextEvent.TEXT_INPUT, true) );
          if (sequenceSetter.propertiesChanged.hasOwnProperty("text")) {
             uiComponent.dispatchEvent(new Event(Event.CHANGE, true));              
          }
      }));
    }
    
    /**
     * Simulate selecting an item in a ComboBox with the specified value.
     * 
     * <p>The following events are dispatched on the <code>target</code> object:</p>
     * <ul>
     * <li>FlexEvent.VALUE_COMMIT</li>
     * <li>Event.CHANGE (<em>only if</em> the value of the selectedItem property changed</li>
     * </ul>
     * 
     * @param value value to select
     * @param target ComboBox to select from
     */
    public function select( value:Object, target:Object ) : void 
    {
      waitUntilNotNull(target);
      assertVisibleAndEnabled(target);
      trace("Selecting by value ['" + value + "'] for '" + LoggerUtils.friendlyName(target) + "'");

      var sequenceSetter : SequenceSetter = sequenceSetter = new SequenceSetter( target, {selectedItem: value} );
      sequence.addStep(new SequenceCaller(null, function() {
          var uiComponent : UIComponent = processComponentReference(target);
          
          var item : Object = null;
          var dataProvider : ICollectionView = uiComponent["dataProvider"] as ICollectionView;
          if (value is String) 
          {
              if (dataProvider.length > 0) 
              {
                var cursor : IViewCursor = dataProvider.createCursor();
                var element : *;
                while ((element = cursor.current) == null) {
                }
                if (!(element is String)) {
                   item = ArrayUtils.exclusiveMatchOnIncludes({label:value}, dataProvider);
                    sequenceSetter.props = {selectedItem: item};      
                }    
              }
          } 
          else 
          {
              item = ArrayUtils.exclusiveMatchOnIncludes(value, dataProvider);
              sequenceSetter.props = {selectedItem: item};
          }
          
      }));

      sequence.addStep( sequenceSetter );   
      sequence.addStep( new SequenceWaiter( target, FlexEvent.VALUE_COMMIT, 500, timeoutHandler ));
      sequence.addStep( new SequenceCaller(null, function():void {
        var uiComponent : UIComponent = processComponentReference(target);
        if (sequenceSetter.propertiesChanged.selectedItem) {
           uiComponent.dispatchEvent(new Event(Event.CHANGE, true));              
        }
      }));
    }
    
    /**
     * Simulate selecting an item in a component with the specified index.
     * 
     * <p>The following events are dispatched on the <code>target</code> object:</p>
     * <ul>
     * <li>FlexEvent.VALUE_COMMIT</li>
     * <li>Event.CHANGE (<em>only if</em> the value of the selectedIndex property changed</li>
     * </ul>
     * 
     * @param value index to select.
     * @param target component to select from
     */
    public function selectByIndex( value:Object, target:UIComponent ) : void 
    {
      waitUntilNotNull(target);
      assertVisibleAndEnabled(target);
      trace("Selecting by index '" + value + "' for '" + LoggerUtils.friendlyName(target) + "'");
      
      var sequenceSetter : SequenceSetter = new SequenceSetter( target, {selectedIndex:value} );
      sequence.addStep( sequenceSetter );
      sequence.addStep( new SequenceWaiter( target, FlexEvent.VALUE_COMMIT, 500, timeoutHandler ));
      sequence.addStep( new SequenceCaller(null, function():void {
        var uiComponent : UIComponent = processComponentReference(target);
        if (sequenceSetter.propertiesChanged.selectedIndex) {
           uiComponent.dispatchEvent(new IndexChangedEvent(IndexChangedEvent.CHANGE, true));              
//           uiComponent.dispatchEvent(new ItemClickEvent(ItemClickEvent.ITEM_CLICK, true, false, null, value as int));
        }
      }));
    }
    
    /**
     * Simulate clicking on a cell in a datagrid.
     * 
     * @param rowNum row number of the cell location (0-based, does not include header row)
     * @param columnNumb column number of cell location (0-based)
     * @param target datagrid
     */
    public function selectCell( rowNum:int, columnNum:int, target:DataGrid ) : void 
    {
      trace("Selecting row [" + rowNum + "], column [" + columnNum + "] on " + LoggerUtils.friendlyName(target))
      
      sequence.addStep( new SequenceSetter( target, {editedItemPosition: {rowIndex: rowNum, columnIndex: columnNum}} ));
      sequence.addStep( new SequenceWaiter( target, FlexEvent.VALUE_COMMIT, 1000, timeoutHandler ));
    }

    /**
     * Removes focus from currently selected cell, if there is one.
     * 
     * This is required to complete the editing of a cell.
     */
    public function unselectCell ( target: DataGrid ) : void
    {
      sequence.addStep( new SequenceSetter( target, {editedItemPosition: null} ));
      sequence.addStep( new SequenceSetter( target, {selectedIndex: null} ));
    }
    
    /**
     * Selects the specified row in a dataGrid.
     * 
     * @param rowNum row number (0-based index not including header)
     * @param target datagrid to select on
     */
    public function selectRow( rowNum:int, target:Object ) : void 
    {
      waitUntilNotNull(target);
      assertVisibleAndEnabled(target);
      trace("Selecting row '" + rowNum + "' on '" + LoggerUtils.friendlyName(target) + "'");
      
      var sequenceSetter : SequenceSetter = new SequenceSetter( target, {selectedIndex: rowNum} );
      sequence.addStep( sequenceSetter );
      sequence.addStep( new SequenceWaiter( target, FlexEvent.VALUE_COMMIT, 500, timeoutHandler ));
      sequence.addStep( new SequenceCaller(null, function():void {
          var procRef : DataGrid = processComponentReference(target);
          if (sequenceSetter.propertiesChanged.selectedIndex) {
          	if(procRef.className.indexOf("TreeGrid") > -1) {
              procRef.dispatchEvent(new ListEvent(ListEvent.CHANGE, true));              
          	} else {
              procRef.dispatchEvent(new IndexChangedEvent(IndexChangedEvent.CHANGE, true));              
          	}
          }
          
          if (sequenceSetter.propertiesChanged.selectedItem) {
              trace("Selected row on " + LoggerUtils.friendlyName(procRef) + 
                    " with value :" + ObjectUtil.toString(sequenceSetter.propertiesChanged.selectedItem));
          }
      }));
    }

    /**
     * Selects the specified row in a dataGrid.
     * 
     * @param row XML representing the row
     * @param target datagrid to select on
     */
    public function selectRowByXml( row:XML, target:Object ) : void 
    {
      waitUntilNotNull(target);
      assertVisibleAndEnabled(target);
      trace("Selecting row '" + row + "' on '" + LoggerUtils.friendlyName(target) + "'");
      
      var sequenceSetter : SequenceSetter = new SequenceSetter( target, {selectedItem: row} );
      sequence.addStep( sequenceSetter );
      sequence.addStep( new SequenceWaiter( target, FlexEvent.VALUE_COMMIT, 500, timeoutHandler ));
      sequence.addStep( new SequenceCaller(null, function():void {
          var procRef : DataGrid = processComponentReference(target);
          if (sequenceSetter.propertiesChanged.selectedItem) {
              trace("Dispatching list event for " + procRef.id);
              procRef.dispatchEvent(new ListEvent(ListEvent.CHANGE, false)); 
          }
      }));
    }
        
    // Waiters
    
    /**
     * If <code>target</code> is a <code>Function</code>, adds a <code>waitUntil</code> sequence series that halts test playback until the function returns a non-null value.
     * 
     * <p>
     * Any other parameter type will be a no-op.
     * </p>
     */
    public function waitUntilNotNull( target : Object ) : void {
      if (target is Function) {
        waitUntil(function() : Boolean {
            return (target as Function).call() != null;
        }, "Timed out waiting for function selector to return non-null");
      }
    }
    
    /**
     * If <code>target</code> is a <code>Function</code>, adds a <code>waitUntil</code> sequence series that halts test playback until the function returns a non-null value.
     * 
     * <p>
     * Any other parameter type will be a no-op.
     * </p>
     */
    public function waitUntilEnabled( target : Object ) : void {
      var timeoutMessage : String = "Timed out waiting for " + LoggerUtils.friendlyName(target) + " to be enabled";
      if (target is Function) {
        waitUntil(function() : Boolean {
            return (target as Function).call().enabled == true;
        }, timeoutMessage);
      }
      else
      {
        waitUntil(function() : Boolean {
            return target.enabled == true;
        }, timeoutMessage);
      }
    }
    
    /**
     * Wait for the specified <code>eventName</code> to be dispatched on <code>target</code> object.
     * 
     * @param target the source of the event
     * @param eventName the name of the event
     * @param waitTimeInMilliseconds the amount of time in milliseconds to wait for specified event 
     */
    public function waitFor( target:IEventDispatcher, eventName : String, waitTimeInMilliseconds : int = 2000, 
                             customTimeoutHandler:Function = null) : void
    {
      var identifier : String = target + "";
      if (target is UIComponent)
      {
        identifier = (target as UIComponent).id;
      } 
      else if (target is HTTPService)
      {
        identifier = (target as HTTPService).url;
      }
      trace("Waiting for '" + eventName + "' on '" + identifier + "'");
      
      sequence.addStep(new SequenceWaiter(target, eventName, waitTimeInMilliseconds, (customTimeoutHandler != null) ? customTimeoutHandler : timeoutHandler ));
    }
    
    /**
     * Wait until the specified function evaluates to true.  The condition will be checked every 50ms until either the condition
     * evaluates to true or the timeout is reached.  If the timeout is reached before the condition is true, the test will fail.
     * 
     * @param condition a Function returning Boolean that returns the status of the condition
     * @param failureMessage message to print if condition fails to come true under the time allotted
     * @param timeout amount of time allotted for the condition to come true
     */
    public function waitUntil( condition:Function, failureMessage:String = "Timed out waiting for waitUntil condition.", timeout:int = 5000) : void
    {
      failureMessage += captureStack();
        
      // Check condition every 50ms and timeout after specified time
      var sleeper : SequenceSleep = new SequenceSleep(50, timeout/50)
      sequence.addStep(sleeper);
      
      sleeper.target.addEventListener(TimerEvent.TIMER, function(e:TimerEvent) : void {
        if (condition() == true) {
          e.target.dispatchEvent(new Event("sequenceConditionMet"));
          e.target.stop();
          failureMessage = null;
        }        
      });
      sleeper.target.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent) : void {
        if (condition() == true) {
          e.target.dispatchEvent(new Event("sequenceConditionMet"));
          failureMessage = null;
        } 
        e.target.stop();
      });
      
      // Fail if time out while waiting for condition
      waitFor(sleeper.target, "sequenceConditionMet", timeout, function():void {
        if (lastAssertFailure)
        {
            fail(failureMessage + ": Stacktrace from allTrue() \n" + lastAssertFailure.getStackTrace() + "\n");            
        }
        else
        {
            fail(failureMessage);
        }
      });
    }
    
     /**
      * Captures the current call stack.
      * 
      * This is used in methods where the exception will most likely occur asynchronously, as in a timeout.  The stack
      * reported in a regular timeout will not be very useful to the tester.  By capturing the stack at the component-level
      * method invocation (typeInto, select, etc) and passing that along in the timeout handler, we can produce a stack trace 
      * that shows the tester where the original call was made that eventually caused the timeout.
      */
    protected function captureStack() : String
    {
      // Capture the stack trace, so if it fails we can see where this call came from
      return "\n" + new Error().getStackTrace();
    }
   
    public function allTrue(assertFunction : Function) : Function
    {
        return function() : Boolean {
            try 
            {
                assertFunction();
            }
            catch (failed : Error)
            {
                lastAssertFailure = failed;
                trace(failed);
                return false;
            }
   
            lastAssertFailure = null;    
            return true;    
        };
    }
    
    /**
     * Wait a specified number of milliseconds before continuing.
     * 
     * This is a very crude way to introduce waiting unto your system.  The preferred method is to use the #waitUntil method
     * which will only wait as long as needed until the desired condition is met, making your tests run faster and more reliably.
     */
    public function delay(millseconds:int = 1000) : void
    {
      var sleeper : SequenceSleep = new SequenceSleep(millseconds)
      sequence.addStep(sleeper);
      waitFor(sleeper.target, TimerEvent.TIMER, millseconds + 2000);
    }
    
    /**
     * Halt sequence playback specified time until a popup occurs with the <code>expectedMessage</code>.
     * 
     * If alert never occurs within the given timeout, the test will fail.
     * 
     * @param expectedMessage text of the <code>Alert</code> object
     * @param timeout time to wait (default = 5 seconds)
     * @param closeAlert whether or not to close the alert once found (default = true)
     */
    public function waitForPopup( expectedMessage:String, timeout : int = 5000, closeAlert : Boolean = true) : void
    {
      trace("Waiting for popup with message [" + expectedMessage + "]");
      waitUntil(function():Boolean {
        return popUpWithMessage(expectedMessage) != null;
      }, "Timed out waiting for popup with message: '" + expectedMessage + "'");
    
      if (closeAlert) {
          
          //  If the alert only has a the Ok button, we simulate clicking it and closing it.  
          sequence.addStep(new SequenceCaller(null, function() {
           var alert : Alert = popUpWithMessage(expectedMessage);
          
            if (alert.buttonFlags == Alert.OK) {
                _closedPopups.push(alert);
                alert.dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true, false, Alert.OK));
                PopUpManager.removePopUp(alert);
            } 
        }));
       }
    }
    
    /**
     * Array of all the popups that have been closed programmatically.
     */
    private var _closedPopups : Array = new Array();
    
    /**
     * Array of all the popups that have been closed programmatically.
     */ 
    public function get closedPopups() : Array {
        return _closedPopups;
    }
    
    /**
     * Close the specified popup. 
     *  
     * @param message message of the popup to close
     * @param button
     */
    public function closePopupWithMessage( message : String, buttonClicked : uint = 0x4) : void {
        sequence.addStep(new SequenceCaller(null, function() {
           var alert : Alert = popUpWithMessage(message);
            assertNotNull("Could not find Alert with message [" + message + "]");
            
            if (alert.buttonFlags | buttonClicked) {
                _closedPopups.push(alert);
                alert.dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true, false, buttonClicked));
            } else { 
                fail("Alert with message [" + message + "] does not have that button.");
            }
            PopUpManager.removePopUp(alert); 
        }));
    }
    
    /**
     * Invoke the specified function in the sequence.
     * 
     * @param object object where method lives
     * @param methodName name of method
     * @param params arguments to pass to method
     */
    public function invoke( object:Object, methodName:String, params:Array = null) : void 
    {
      // TODO Refactor: This should really just take a function, and an object to use as the 'this' reference
      trace("Invoke '" + methodName + "' on " + object);
      sequence.addStep(new SequenceCaller(object, object[methodName], params));  
    }
    
    // Sequence control
    
    /**
     * Asserts the state at the end of the test.
     * 
     * TODO: Change to assertEndState to keep parallel to assertState
     * 
     * @param assertion the function containing the assertions
     * @param passThru TBD
     */
    public function assertFinished( assertion:Function, passThru:Object = null ) : void 
    {
      sequence.addAssertHandler(assertion, passThru);
      play();
    }
    
    /**
     * Plays back the recorded sequence.
     * 
     * <p>Usually a <code>ComponentTestCase</code> either ends with a call to <code>#assertFinished</code> or <code>#play</code>  Both
     *    trigger the sequence to run.</p>
     */
    public function play() : void
    {
      trace("Running Sequence....");
      trace("");
      sequence.run();
    }
    
    /**
     * Assert the state of your component anywhere in a sequence.
     * 
     * @param assertion Function which contains asssertions
     * @param msg an optional message stating what is being asserted (this only gets traced)
     */
    public function assertState( assertion:Function, msg:String = "Asserting the current state of the module.") : void 
    {
      trace(msg);
      sequence.addStep(new SequenceAssert(assertion));
    }
    
    /**
     * Asserts the general conditions of the <code>target</code> component at playback time.
     * 
     * <p>Those conditions are:</p>
     * <ul>
     *  <li>The component is <code>enabled</code></li>
     *  <li>The component has no validation errors</li>
     * </ul>
     */
    public function assertVisibleAndEnabled( target : Object ) : void {
      assertState(function():void {
        assertEnabled(target);
        assertVisible(target);
      }, "Asserting general conditions (target is visible, target is enabled) on '" + LoggerUtils.friendlyName(target) + "'");
    }
    
    // --- Selectors
    
    /**
     * Delayed selector for the current cell in a datagrid.
     */
    public function currentCell(dataGrid:DataGrid) : Function
    {
      return function() : IListItemRenderer {
        if (!dataGrid.itemEditorInstance)
        {
          fail("No cell selected in grid [" + LoggerUtils.friendlyName(dataGrid) + "]");
        }
        return dataGrid.itemEditorInstance;
      };
    }
    
    public function cell(row:int, column:int, dataGrid:DataGrid) : Function
    {
      selectCell(row, column, dataGrid);
      waitUntil(function():Boolean {
        return currentCell(dataGrid) != null;
      }, "Waiting for current cell to be nonnull.");
      
      return currentCell(dataGrid);
    }
    
    /**
     * Delayed selector for specified element in specified row.
     */
    public function elementInRow(elementId:String, rowNum:int, dataGrid:DataGrid) : Function
    {
      selectRow(rowNum, dataGrid);
      
      return function() : EventDispatcher {
        var row : Object = dataGrid.indexToItemRenderer(rowNum);
        if (row) {
          return row[elementId];
        } else {
          fail("No renderer available for row number [" + rowNum + "] in " + dataGrid.id);
          return null;
        }
      };
    }
    
    /**
     * Delayed selector for specified element in specified cell.
     */
    public function elementInCell(elementId:String, rowNum:int, cellNum:int, dataGrid:DataGrid) : Function
    {
      selectRow(rowNum, dataGrid);
      
      return function() : EventDispatcher {
        var row : Object = dataGrid.indexToItemRenderer(0);
        if (row) {
          var cell : Object = row.parent.listItems[0][cellNum];
          if (!cell[elementId])
          {
          	trace("Element '" + elementId + "' not found in cell '" + rowNum + ", " + cellNum + ".");
          }
          var obj : Object = cell[elementId];
          return obj;
        } else {
          fail("No renderer available for row number [" + rowNum + "] in cell number [" + cellNum + "] " + dataGrid.id);
          return null;
        }
      };
    }  
    
    /**
     * Finds an <code>Alert</code> object with the specified <code>message</code>.
     * 
     * @param message message of the <code>Alert</code> popup
     * @return matching <code>Alert</code> popup or <code>null</code> if none found.
     */
    public function popUpWithMessage(message:String):Alert 
    {
      var systemManager : ISystemManager = Application.application.systemManager;
      var children : IChildList = systemManager.rawChildren as IChildList;
      var foundAlertMessage : Boolean = false;
      for (var i : int = 0; i < children.numChildren; i++) {
        var child : UIComponent = children.getChildAt(i) as UIComponent;
        if (child is Alert && (child as Alert).visible) 
        {
            if (message == (child as Alert).text)
            {
                return child as Alert;
            }
        }
      } 
      return null;
    }
    
    // --------- Custom Asserts.  These asserts either take the direct UIComponent or a Function reference to one
    
    /**
     * Processes the target parameter as either a UIComponent or as a reference to a UIComponent through a Function.
     */
    protected function processComponentReference( target:Object) : UIComponent 
    {
      if (target)
      {
          if (target is Function)
          {
            return processComponentReference((target as Function)());
          }
          else if (target is UIComponent)
          {
            return target as UIComponent;
          }
          else
          {
            fail("Invalid type: " + target);
            return null;
          }    
      }
      
      return null;
    }
    
    /**
     * Assert the <code>target</code> component is visible.
     *  
     * @param target
     */
    public function assertVisible( target:Object) : void 
    {
      var component : UIComponent = processComponentReference(target);
      assertTrue("Expecting component '" + LoggerUtils.friendlyName(component) + "' to be visible", component.visible);
    }
    
    /**
     * Assert the <code>target</code> component is hidden.
     *  
     * @param target
     */
    public function assertHidden( target:Object) : void 
    {
      var component : UIComponent = processComponentReference(target);
      assertFalse("Expecting component '" + LoggerUtils.friendlyName(component) + "' to be hidden", component.visible);
    }
    
    /**
     * Assert the <code>target</code> component is enabled.
     *  
     * @param target
     */
    public function assertEnabled( target:Object) : void 
    {
      var component : UIComponent = processComponentReference(target);
      assertTrue("Expecting component '" + LoggerUtils.friendlyName(component) + "' to be enabled", component.enabled);
      assertVisible(component);
    }
    
    /**
     * Assert the <code>target</code> component is disabled.
     *  
     * @param target
     */
    public function assertDisabled( target:Object) : void 
    {
      var component : UIComponent = processComponentReference(target);
      assertFalse("Expecting component '" + LoggerUtils.friendlyName(component) + "' to be disabled", component.enabled);
    }
    
    /**
     * Assert the <code>target</code> component has errors.
     *  
     * @param target
     */
    public function assertInvalid( target:Object) : void 
    {
      var component : UIComponent = processComponentReference(target);
      assertTrue("Expecting property '" + LoggerUtils.friendlyName(component) + "' to be invalid.", component.errorString.length > 0);
    }
    
    /**
     * Assert the <code>target</code> component has no errors.
     *  
     * @param target
     */
    public function assertValid( target:Object) : void 
    {
      var component : UIComponent = processComponentReference(target);
      assertTrue("Expecting an empty error string on '" + LoggerUtils.friendlyName(component) + "', got '" + component.errorString + "' instead.", 
        component.errorString.length == 0);
    }

    /**
     * Assert that an Alert message exists with the specified string.
     */
    public function assertAlertMessage(expectedMessage:String) : void 
    {
      assertTrue("Did not find an alert with the message '" + expectedMessage + "'", popUpWithMessage(expectedMessage) != null);
    }
  }
}
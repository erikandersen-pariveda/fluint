/**
 * Copyright (c) 2007 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/ 
package net.digitalprimates.fluint.tests {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.events.PropertyChangeEvent;
	import mx.rpc.IResponder;
	import mx.utils.*;
	
	import net.digitalprimates.fluint.async.AsyncHandler;
	import net.digitalprimates.fluint.async.AsyncTestResponder;
	import net.digitalprimates.fluint.async.ITestResponder;
	import net.digitalprimates.fluint.events.AsyncEvent;
	import net.digitalprimates.fluint.events.AsyncResponseEvent;
	import net.digitalprimates.fluint.monitor.TestCaseResult;
	import net.digitalprimates.fluint.monitor.TestMethodResult;
	import net.digitalprimates.fluint.monitor.TestMonitor;
	import net.digitalprimates.fluint.sequence.SequenceBindingWaiter;
	import net.digitalprimates.fluint.sequence.SequenceRunner;
	import net.digitalprimates.fluint.uiImpersonation.UIImpersonator;

	/** 
	 * <p>
	 * The TestCase is the class extended to create your own test cases. </p>
	 * 
	 * <p>
	 * A test case is an object with a variety of method beginning with 
	 * the lower case letters 'test'. The TestCase class ensures that 
	 * tests are always run in the following order:</p>
	 * 
	 * <p><code>
	 * run setup()<br/>
	 * 		wait for any outstanding asynchronous events</code></p>
	 * <p><code>
	 * run the test method<br/>
	 * 		wait for any outstanding asynchronous events</code></p>
	 * <p><code>
	 * run tearDown()<br/>
	 * 		wait for any outstanding asynchronous events</code></p>
	 * <p>
	 * The loop then begins again for the next test method.</p>
	 */
	public class TestCase extends UIImpersonator implements ITestCaseRunner {

        /**
         * @private
         */
		protected var testMonitor:TestMonitor = TestMonitor.getInstance(); 

        /**
         * @private
         */
		public static var TEST_COMPLETE:String = "testComplete";

        /**
         * @private
         */
		private var testCollection:XMLListCollection;

        /**
         * @private
         */
		private var cursor:IViewCursor;

        /**
         * @private
         */
		protected var pendingAsyncCalls:Array = new Array();

        /**
         * @private
         */
		protected var methodBodyExecuting:Boolean = false;

        /**
         * @private
         */
		protected var setupTearDownFailed:Boolean = false;

        /**
         * @private
         */
		protected var registeredMethod:Function;

        /**
         * @private
         */
		protected var tickCountOnStart:Number;


		public function get objectUnderTest():* {
			return this;
		}
        /**
         * @private
         */
		public function runSetup():void {
			methodBodyExecuting = true;
			executeMethodWhileProtected( setUp ); 
			methodBodyExecuting = false;

			if ( !hasPendingAsync ) {
				dispatchEvent( new Event( TEST_COMPLETE ) );
			} else {
				startAsyncTimers();
			}
		}

        /**
         * @private
         */
		public function runTestMethod( method:Function ):void {
			tickCountOnStart = getTimer();

			methodBodyExecuting = true;
			executeMethodWhileProtected( method ); 
			methodBodyExecuting = false;

			if ( !hasPendingAsync ) {
				var methodResult:TestMethodResult = testMonitor.getTestMethodResult( registeredMethod );
				if ( methodResult && ( !methodResult.traceInformation ) ) {
					methodResult.executed = true;
					methodResult.testDuration = getTimer()-tickCountOnStart;
					methodResult.traceInformation = "Test completed in " + methodResult.testDuration + "ms";
				}

				dispatchEvent( new Event( TEST_COMPLETE ) );
			} else {
				startAsyncTimers();
			}
		}


        /**
         * @private
         */
		public function runTearDown():void {
			removeAllAsyncEventListeners();

			methodBodyExecuting = true;
			executeMethodWhileProtected( tearDown ); 
			methodBodyExecuting = false;

			if ( !hasPendingAsync ) {
				dispatchEvent( new Event( TEST_COMPLETE ) );
			} else {
				startAsyncTimers();
			}
		}

        /**
         * @private
         */
		private function startAsyncTimers():void {
			for ( var i:int=0; i<pendingAsyncCalls.length; i++ ) {
				( pendingAsyncCalls[ i ] as AsyncHandler ).startTimer();
			}
		}

        /**
         * @private
         */
		private function removeAsyncEventListeners( asyncHandler:AsyncHandler ):void {
			asyncHandler.removeEventListener( AsyncHandler.EVENT_FIRED, handleAsyncEventFired, false );
			asyncHandler.removeEventListener( AsyncHandler.TIMER_EXPIRED, handleAsyncTimeOut, false );
		}

        /**
         * @private
         */
		private function removeAllAsyncEventListeners():void {
			for ( var i:int=0; i<pendingAsyncCalls.length; i++ ) {
				removeAsyncEventListeners( pendingAsyncCalls[ i ] as AsyncHandler );
			}
		}

        /**
         * @private
         */
		public function get hasPendingAsync():Boolean {
			return ( pendingAsyncCalls.length > 0 );
		}

        /**
         * @private
         */
		private function handleAsyncEventFired( event:AsyncEvent ):void {
			//Receiving this event is a good things... IF it is the first one we are waiting for
			//If it is not the first one on the stack though, we still need to fail.
			var asyncHandler:AsyncHandler = event.target as AsyncHandler;
			var firstPendingAsync:AsyncHandler;
			
			removeAsyncEventListeners( asyncHandler );
			
			if ( hasPendingAsync ) {
				firstPendingAsync = pendingAsyncCalls.shift() as AsyncHandler;
				
				if ( firstPendingAsync === asyncHandler ) {
					if ( asyncHandler.eventHandler != null  ) {
						//this actually needs to be the event object from the previous event
						protect( asyncHandler.eventHandler, event.originalEvent, firstPendingAsync.passThroughData );  
					}
				} else {
					//The first one on the stack is not the one we received. 
					//We received this one out of order, which is a failure condition
					protect( fail, "Asynchronous Event Received out of Order" ); 
				}
			} else {
				//We received an event, but we were not waiting for one, failure
				protect( fail, "Unexpected Asynchronous Event Occurred" ); 
			}
			
			if ( !hasPendingAsync && !methodBodyExecuting ) {
				//We have no more pending async, *AND* the method body of the function that originated this message
				//has also finished, then let the test runner know
				var methodResult:TestMethodResult = testMonitor.getTestMethodResult( registeredMethod );
				if ( methodResult && ( !methodResult.traceInformation )  ) {
					methodResult.executed = true;
					methodResult.testDuration = getTimer()-tickCountOnStart;
					methodResult.traceInformation = "Test completed via Async Event in " + methodResult.testDuration + "ms";
				}

				dispatchEvent( new Event( TEST_COMPLETE ) );				
			}
			
		}

        /**
         * @private
         */
		private function handleAsyncTimeOut( event:Event ):void {
			var asyncHandler:AsyncHandler = event.target as AsyncHandler; 
			
			removeAsyncEventListeners( asyncHandler );

			if ( asyncHandler.timeoutHandler != null ) {
				protect( asyncHandler.timeoutHandler, asyncHandler.passThroughData ); 
			} else {
				protect( fail, "Timeout Occurred before expected event" );
			}

			//Remove all future pending items
			removeAllAsyncEventListeners();
			pendingAsyncCalls = new Array();

			var methodResult:TestMethodResult = testMonitor.getTestMethodResult( registeredMethod );
			if ( methodResult && ( !methodResult.traceInformation ) ) {
				methodResult.executed = true;
				methodResult.testDuration = getTimer()-tickCountOnStart;
				methodResult.traceInformation = "Test completed via Async TimeOut in " + methodResult.testDuration + "ms";
			}

			//Our timeout has failed, declare this specific test complete and move along
			dispatchEvent( new Event( TEST_COMPLETE ) );
		}

        /**
         * @private
         */
		private function protect( method:Function, ... rest ):void {
			var methodResult:TestMethodResult;
			var setupTearDownFailure:Boolean = false;

			methodResult = testMonitor.getTestMethodResult( registeredMethod );

			if ( !setupTearDownFailed ) {
				try {
					if ( rest && rest.length>0 ) {
						method.apply( this, rest );
					} else {
						method();
					}
				}
			
				catch ( e:Error ) {
					if ( ( registeredMethod == setUp ) || 
					     ( registeredMethod == tearDown ) ) {
						    setupTearDownFailed = true;
							var testCaseResult:TestCaseResult = testMonitor.getTestCaseResult( this );
							testCaseResult.status = false;
	
							//This is needed to ensure the testCase is update with information regarding a failure
							//in the setup or teardown as that is really more of a case issue then a method issue
							if ( !testCaseResult.traceInformation ) {
								testCaseResult.traceInformation = e.getStackTrace();
							} else {
								testCaseResult.traceInformation += ( '\n' + e.getStackTrace() );
							}
						} else {
							methodResult = testMonitor.getTestMethodResult( registeredMethod );
/*
							if ( !methodResult.traceInformation ) {
								methodResult.traceInformation = e.getStackTrace();
							} else {
								methodResult.traceInformation += ( '\n' + e.getStackTrace() );
							}
*/							
							methodResult.error = e;
							methodResult.executed = true;
							methodResult.testDuration = getTimer()-tickCountOnStart;
					}
				}

			} else {
				//If setup or teardown failed, we need to assume the remainder of the methods in this testcase are invalid
				methodResult = testMonitor.getTestMethodResult( registeredMethod );
				if ( methodResult ) {
					methodResult.executed = true;
					methodResult.error = new Error("Setup/Teardown Error");
					methodResult.traceInformation = "Setup or Teardown Failed for this TestCase. Method is invalid. Review Testcase for stackTrace information";
					methodResult.testDuration = getTimer()-tickCountOnStart;
				}
			}

		}

        /**
         * @private
         */
		private function executeMethodWhileProtected( method:Function, ... rest ):void {
			
			var p:Function = protect;

			registeredMethod = method;
			(rest as Array).push( method );
			p.apply( this, rest );
		} 

        /**
         * @private
         */
	    public function handleBindableNextSequence( event:PropertyChangeEvent, sequenceRunner:SequenceRunner ):void {
	    	if ( sequenceRunner.getPendingStep() is SequenceBindingWaiter ) {

				var sequenceBinding:SequenceBindingWaiter = sequenceRunner.getPendingStep() as SequenceBindingWaiter;

				if ( event && event.target && event.property == sequenceBinding.propertyName ) {
					//Remove the listener for this particular item
			    	event.currentTarget.removeEventListener(event.type, handleBindableNextSequence );
	
					sequenceRunner.continueSequence( event );
					
					startAsyncTimers();
				} else {
					protect( fail, "Incorrect Property Change Event Received" );
				}
	    	} else {
				protect( fail, "Event Received out of Order" ); 
	    	}
	    }

        /**
         * @private
         */
	    public function handleNextSequence( event:Event, sequenceRunner:SequenceRunner ):void {
			if ( event && event.target ) {
				//Remove the listener for this particular item
		    	event.currentTarget.removeEventListener(event.type, handleNextSequence );
			}

			sequenceRunner.continueSequence( event );
			
			startAsyncTimers();
	    }

        /**
         * @private
         */
		private function getMetaDataFromNode( node:XML ):XML {
			var metadata:XML;

			if ( node.hasOwnProperty( 'metadata' ) ) {
				var xmlList:XMLList = node.metadata.(@name="Test"); 
				metadata = xmlList?xmlList[0]:null; 
			}			

			return metadata;
		}

        /**
         * @private
         */
		private function getMethodNameFromNode( node:XML ):String {
			return ( node.@name );
		}

        /**
         * @private
         */
		private function getMethodFromNode( node:XML ):Function {
			return ( this[ node.@name ] as Function );
		}

        /**
         * @private
         */
		public function getTestCount():int {
			return testCollection.length;
		}

        /**
         * @private
         */
		public function getNextTestMethod():TestMethod {
			var methodNode:XML;
			if ( !cursor.afterLast && !cursor.beforeFirst ) {
				methodNode = cursor.current as XML;
				cursor.moveNext();

				return new TestMethod( getMethodFromNode( methodNode ), getMethodNameFromNode( methodNode ), getMetaDataFromNode( methodNode ) );
			} 

			return null;			
		}
		
        /**
         * @private
         */
		private function buildTestCollection():XMLListCollection {
			var testMethods:XMLListCollection;
			var record:DescribeTypeCacheRecord = DescribeTypeCache.describeType( this );
			var typeDetail:XML = record.typeDescription;
			//var methods:XMLList = typeDetail.method.( /^test.*/.test( @name ) );
			//We now use a filterFunction to grab only test* methods as opposed to here
			var methods:XMLList = typeDetail.method;
			testMethods = new XMLListCollection( methods );
			
			return testMethods;
		}

		/**
		 * The setup method can be overriden to create test case specific 
		 * conditions in which each of the test methods run.
		 * 
		 * For each test in a TestCase, the following procedure is followed:
		 * 
		 * run setup()
		 * 		wait for any outstanding asynchronous events
		 * run the test method
		 * 		wait for any outstanding asynchronous events
		 * run tearDown()
		 * 		wait for any outstanding asynchronous events
		 * 
		 * The loop then begins again for the next test method.
		 */
		protected function setUp():void {
		}

		/** 
		 * Teardown is used to destroy any items created during setup to rest the test environment
		 * for the next test.
		 * 
		 * For example, if a Timer is created during the setUp() method, the reference to that
		 * Timer must be set as null in the teardown to ensure it is recreated the next time
		 * setUp() is run.
		 * 
		 * The teardown method needs to be overriden whenever the setup method is overriden.
		 **/ 		
		protected function tearDown():void {
		}

		/**
		 * <p>
		 * The asyncHandler method is used to create a new AsyncHandler instance, 
		 * which is a helper object that monitors an object for an event to occur, 
		 * and allows the test case to resume on its success, or handle the timeout 
		 * condition, where the specified event does not occur within a provided timeout.</p>
		 * 
		 * <p>
		 * The method can be used in the following ways:</p>
		 * 
		 * <p><code>
		 * var handler:Function = asyncHandler( handleSomeEvent, 250, null, handleTimeOut );
		 * someObject.addEventListener( 'someEvent', handler, false, 0, true );
		 * </code></p>
		 * OR
		 * <p>
		 * combined into a single statment:<br/>
		 * <code>
		 * someObject.addEventListener( 'someEvent', asyncHandler( handleSomeEvent, 250, null, handleTimeOut ), false, 0, true );</code></p>
		 * 
		 * <p>
		 * The former allows the developer to keep a handler to the created method and therefore
		 * manually garbage collect it in the future. If you choose not to keep a reference to
		 * the created object, you will need to set the weaklistener object to true in the 
		 * addEventListener method or your handlers and potentially setup objects may 
		 * not be garbage collected.</p>
		 * 
		 * @param eventHandler
		 *  A reference to the event handler that should be called if the event named in the TestCase.asyncHandler() 
		 *  method fires before the timeout is reached. The handler is expected to have the follow signature:
		 *  <p><code>
		 *  public function handleEvent( event:Event, passThroughData:Object ):void {
		 *  }</code></p>
		 * 
		 * <p>
		 * The first parameter is the original event object.
		 * The second parameter is a generic object that can optionally be provided by the developer when starting
		 * a new asynchronous operation.
		 * 
		 * @param timeout
		 *  The number of milliseconds to wait for the event declared in the addEventListener method to occur before
		 *  determining that this mehtod has timed-out.
		 * 
		 * @param passThroughData
		 * 	A generic object that is optionally provided by the developer when starting a new asynchronous operation.
		 *  This generic object is passed to the eventHandler function if it is called.
		 * 
		 * @param timeoutHandler
		 * 	A reference to the event handler that should be called if the event named in the addEventListener 
		 *  method does not fire before the timeout is reached. The handler is expected to have the follow signature:
		 *  <p><code>
		 *  public function handleTimeoutEvent( passThroughData:Object ):void {
		 *  }</code></p>
		 *  <p>
		 *  The parameter is a generic object that will receive any data provided to the passThroughData parameter of this method.</p>
		 */
		public function asyncHandler( eventHandler:Function, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):Function { 
			var asyncHandler:AsyncHandler = new AsyncHandler( this, eventHandler, timeout, passThroughData, timeoutHandler )
			asyncHandler.addEventListener( AsyncHandler.EVENT_FIRED, handleAsyncEventFired, false, 0, true );
			asyncHandler.addEventListener( AsyncHandler.TIMER_EXPIRED, handleAsyncTimeOut, false, 0, true );

			pendingAsyncCalls.push( asyncHandler );

			return asyncHandler.handleEvent;
		}

		public function asyncResponder( responder:*, timeout:int, passThroughData:Object = null, timeoutHandler:Function = null ):IResponder { 

			if ( !( ( responder is IResponder ) || ( responder is ITestResponder ) ) ) {
				throw new Error( "Object provided to responder parameter of asyncResponder is not a IResponder or ITestResponder" );
			}

			var asyncResponder:AsyncTestResponder = new AsyncTestResponder( responder );

			var asyncHandler:AsyncHandler = new AsyncHandler( this, handleAsyncTestResponderEvent, timeout, passThroughData, timeoutHandler )
			asyncHandler.addEventListener( AsyncHandler.EVENT_FIRED, handleAsyncEventFired, false, 0, true );
			asyncHandler.addEventListener( AsyncHandler.TIMER_EXPIRED, handleAsyncTimeOut, false, 0, true );

			pendingAsyncCalls.push( asyncHandler );

			asyncResponder.addEventListener( AsyncResponseEvent.RESPONDER_FIRED, asyncHandler.handleEvent, false, 0, true ); 

			return asyncResponder;
		}

		protected function handleAsyncTestResponderEvent( event:AsyncResponseEvent, passThroughData:Object=null ):void {
			var originalResponder:* = event.originalResponder;
			var isTestResponder:Boolean = false;
			
			if ( originalResponder is ITestResponder ) {
				isTestResponder = true;
			}
			
			if ( event.status == 'result' ) {
				if ( isTestResponder ) {
					originalResponder.result( event.data, passThroughData );
				} else {
					originalResponder.result( event.data );					
				}
			} else {
				if ( isTestResponder ) {
					originalResponder.fault( event.data, passThroughData );
				} else {
					originalResponder.fault( event.data );					
				}
			}
		}
//------------------------------------------------------------------------------


		/**
		 * @private
		 */
		protected var _sorter:Sort;

		/** 
		 * Allows the developer to control the order that the methods are run by specifying a 
		 * Sort to be used by the internal collection
		 */
		public function get sorter():Sort {
			return _sorter;
		}

		/**
		 * @private
		 */
		public function set sorter( value:Sort ):void {
			if ( _sorter != value ) {
				_sorter = value;
				if ( testCollection ) {
					testCollection.sort = sorter;
					testCollection.refresh();
					cursor.seek( CursorBookmark.FIRST ); //needed when applying a sorter or filter to ensure cursor is valid
				}
			}
		}

		/**
		 * @private
		 */
		protected var _filter:Function = defaultFilterFunction;

		/** 
		 * Allows the developer to control which methods are executed by passing a filter function.
		 * 
		 * A function that the view will use to eliminate items that do not match the function's criteria. A 
		 * filterFunction is expected to have the following signature:
		 * 
		 * f(item:Object):Boolean
		 * 
		 * where the return value is true if the specified item should remain in the view. 
		 */
		public function get filter():Function {
			return _filter;
		}

		/**
		 * @private
		 */
		public function set filter( value:Function ):void {
			if ( _filter != value ) {
				_filter = value;
				if ( testCollection ) {
					testCollection.filterFunction = filter;
					testCollection.refresh();
					cursor.seek( CursorBookmark.FIRST ); //needed when applying a sorter or filter to ensure cursor is valid
				}
			}
		}

		/** 
		 * A default implementation of the filterFunction which includes all methods beginning with 'test'. 
		 * The developer can provide their own fitler function or override this through inheritance. 
		 */
		protected function defaultFilterFunction( item:Object ):Boolean {
			if ( ( /^test.*/.test( item.@name ) ) ) {
				return true;
			}
			
			//Also check if it has a 'Test' metadata and include those items
			if ( item.hasOwnProperty( 'metadata' ) ) {
				var metaList:XMLList = item.metadata.(@name=='Test');
				
				if ( metaList.length() > 0 ) {
					return true;
				}
			}

			return false;
		}

		/** 
		 * A generic function that can be used with asynchronous code when we choose to wait until something occurs,
		 * but do not actually need to test anything when complete. This is often used to wait until asynchronous setup
		 * is complete before continuing.  
		 */
		protected function pendUntilComplete( event:Event, passThroughData:Object ):void {
		}

		/**
		 * Event dispatching logic - Need as we no longer extend EventDispatcher
		 **/
	    private var dispatcher:EventDispatcher;
	               
	    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
	        dispatcher.addEventListener(type, listener, useCapture, priority);
	    }
	           
	    public function dispatchEvent(evt:Event):Boolean{
	        return dispatcher.dispatchEvent(evt);
	    }
	    
	    public function hasEventListener(type:String):Boolean{
	        return dispatcher.hasEventListener(type);
	    }
	    
	    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
	        dispatcher.removeEventListener(type, listener, useCapture);
	    }
	                   
	    public function willTrigger(type:String):Boolean {
	        return dispatcher.willTrigger(type);
	    }
        /**
        * Constructor.
        */
		public function TestCase() {
			dispatcher = new EventDispatcher(this);

			if (!sorter) {
				var sort:Sort = new Sort();
				sort.fields = [ new SortField( "@name" ) ];
				sorter = sort;
			}

			testCollection = buildTestCollection();
			testCollection.sort = sorter;
			testCollection.filterFunction = filter;
			testCollection.refresh();
			
			cursor = testCollection.createCursor();
		}
	}
}

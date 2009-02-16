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
	
	import net.digitalprimates.fluint.assertion.Assert;
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
	import net.digitalprimates.fluint.utils.MetaDataInformation;
	
	/** This class is designed to wrap suites and cases. It will keep state around their execution and dispatch
	 *  messages as test methods, cases and suites complete. 
	 * 
	 **/
	public class TestWrapper extends EventDispatcher implements ITestCaseRunner {
		private var testObject:Object;
		private var typeInfo:XML;
		
		private var beforeClassArray:Array = new Array();
		private var beforeArray:Array = new Array();
		private var afterClassArray:Array = new Array();
		private var afterArray:Array = new Array();

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
         //not sure I want this public long term, but... it is what it is for now
		public var methodBodyExecuting:Boolean = false;

        /**
         * @private
         */
		protected var setupTearDownFailed:Boolean = false;

        /**
         * @private
         */
        //don't really want this public. just until I can write tests against TestWrapper instead of just async
		public var registeredMethod:Function;

        /**
         * @private
         */
		protected var tickCountOnStart:Number;

        /**
         * @private
         */
		public function runSetup():void {
			methodBodyExecuting = true;
			for ( var i:int=0; i<beforeArray.length; i++ ) {
				executeMethodWhileProtected( beforeArray[ i ] );	
			}
			 
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
			for ( var i:int=0; i<afterArray.length; i++ ) {
				executeMethodWhileProtected( afterArray[ i ] );	
			}
			
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
					protect( Assert.fail, "Asynchronous Event Received out of Order" ); 
				}
			} else {
				//We received an event, but we were not waiting for one, failure
				protect( Assert.fail, "Unexpected Asynchronous Event Occurred" ); 
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
				protect( Assert.fail, "Timeout Occurred before expected event" );
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

		private function isSetupOrTearDownMethod( method:Function ):Boolean {
			var i:int;
			for ( i=0; i<beforeArray.length; i++ ) {
				if ( beforeArray[ i ] == method ) {
					return true;
				}
			}

			for ( i=0; i<afterArray.length; i++ ) {
				if ( afterArray[ i ] == method ) {
					return true;
				}
			}
			
			return false;
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
					if ( isSetupOrTearDownMethod( registeredMethod ) ) {
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
					protect( Assert.fail, "Incorrect Property Change Event Received" );
				}
	    	} else {
				protect( Assert.fail, "Event Received out of Order" ); 
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
		private function getMethodNameFromNode( node:XML ):String {
			return ( node.@name );
		}

        /**
         * @private
         */
		private function getMethodFromNode( node:XML ):Function {
			return ( testObject[ node.@name ] as Function );
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

				return new TestMethod( getMethodFromNode( methodNode ), 
										getMethodNameFromNode( methodNode ), 
										MetaDataInformation.getArgsFromFromNode( methodNode, "Test" ) );
			} 

			return null;			
		}
		
        /**
         * @private
         */
		private function buildTestCollection( methods:XMLList ):XMLListCollection {
			var testMethods:XMLListCollection;

			testMethods = new XMLListCollection( methods );
			
			return testMethods;
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
		
		public function get objectUnderTest():* {
			return testObject;
		}

		private function getOrderValueFromMethod( method:XML, metadata:String ):int {
			var order:int = 0;
	
			var orderString:String = MetaDataInformation.getArgValueFromMetaDataNode( method, metadata, "Order" );
			if ( orderString ) {
				order = int( orderString );
			}
	
			return order;
		}
	
		private function orderMetaDataSortFunction( aNode:XML, bNode:XML, fields:Object ):int {
			var field:String;
			var a:int;
			var b:int; 

			if ( fields && fields[ 0 ] ) {
				//Work around for a view update bug
				if ( fields[ 0 ] is SortField ) {
					field = fields[ 0 ].name;	
				} else {
					field = fields[ 0 ];	
				}
			} else {
				//if we don't know what field... well then, it all looks equal to me
				return 0;
			}
			
			a = getOrderValueFromMethod( aNode, field );
			b = getOrderValueFromMethod( bNode, field );

			if (a < b)
				return -1;
			if (a > b)
				return 1;

			return 0;
		}

		private function filterOutIgnore( method:XML ):Boolean {
			return !( MetaDataInformation.nodeHasMetaData( method, "Ignore" ) );
		}

		public function TestWrapper( testObject:Object ) {
			if (!sorter) {
				var sort:Sort = new Sort();

				var testField:SortField = new SortField( "Test" );
				sort.compareFunction = orderMetaDataSortFunction;
				sort.fields = [ testField ];
				
				sorter = sort;
			}

			this.testObject = testObject;
			TestWrapperLocator.getInstance().registerRunnerForTest( testObject, this );

			typeInfo = describeType( testObject );

			var methodList:XMLList;			
			methodList = MetaDataInformation.getMethodsList( typeInfo );
			
			var beforeClassList:XMLList = MetaDataInformation.getMethodsDecoratedBy( methodList, "BeforeClass" );
			var afterClassList:XMLList = MetaDataInformation.getMethodsDecoratedBy( methodList, "AfterClass" );

			//need to sort these two by any potential order in the metadata
			var beforeList:XMLList = MetaDataInformation.getMethodsDecoratedBy( methodList, "Before" );
			var beginSort:Sort = new Sort();
			var beginField:SortField = new SortField( "Before" );
			beginSort.compareFunction = orderMetaDataSortFunction;
			beginSort.fields = [ beginField ];

			var beginCollection:XMLListCollection = new XMLListCollection( beforeList );
			beginCollection.sort = beginSort;
			beginCollection.refresh();

			var afterList:XMLList = MetaDataInformation.getMethodsDecoratedBy( methodList, "After" );
			var afterSort:Sort = new Sort();
			var afterField:SortField = new SortField( "After" );
			afterSort.compareFunction = orderMetaDataSortFunction;
			afterSort.fields = [ afterField ];

			var afterCollection:XMLListCollection = new XMLListCollection( afterList );
			afterCollection.sort = afterSort;
			afterCollection.refresh();

			var i:int = 0;
			
			for ( i=0; i<beginCollection.length; i++ ) {
				beforeArray.push( getMethodFromNode( beginCollection.getItemAt( i ) as XML ) );
			}

			for ( i=0; i<afterCollection.length; i++ ) {
				afterArray.push( getMethodFromNode( afterCollection.getItemAt( i ) as XML ) );
			}

			//Need to also sort filters... performance shouldn't really matter with the scale of nodes we are looking at, but there might
			//be a usecase I am not thinking of right now
			var filterList:XMLList = MetaDataInformation.getMethodsDecoratedBy( methodList, "Filter" );
			var sortList:XMLList = MetaDataInformation.getMethodsDecoratedBy( methodList, "Sort" );

			//Tests to run will be this list, minus the Ignore list, minus any removed by any filter functions
			var testList:XMLList = MetaDataInformation.getMethodsDecoratedBy( methodList, "Test" );
			var ignoreList:XMLList = MetaDataInformation.getMethodsDecoratedBy( methodList, "Ignore" );

			testCollection = buildTestCollection( testList );
			testCollection.sort = sorter;
			testCollection.filterFunction = filter;
			testCollection.refresh();
			
			cursor = testCollection.createCursor();
		}
	}
}
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
package net.digitalprimates.flex2.uint.ui {
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.core.UIComponent;
	
	import net.digitalprimates.flex2.uint.monitor.TestCaseResult;
	import net.digitalprimates.flex2.uint.monitor.TestMonitor;
	import net.digitalprimates.flex2.uint.monitor.TestSuiteResult;
	import net.digitalprimates.flex2.uint.tests.TestCase;
	import net.digitalprimates.flex2.uint.tests.TestMethod;
	import net.digitalprimates.flex2.uint.tests.TestSuite;
	import net.digitalprimates.flex2.uint.utils.ClassSortUtils;

	/**
	 * The TestRunner class is responsible for ensuring every TestCase in every 
	 * TestSuite is executed and the results are aggragated 
	 */
	[Event(name="testsComplete",type="flash.events.Event")]
	public class TestRunner extends UIComponent {
		public static const TESTS_COMPLETE:String = "testsComplete";
		
        /** @private */
		protected var testMonitor:TestMonitor = TestMonitor.getInstance(); 

        /** @private */
		protected var schedulerTimer:Timer;

        /** @private */
		protected var testProgression:ArrayCollection;
        
		/** @private */
		protected var progressCursor:IViewCursor;

        /** @private */
		protected var testSuiteCollection:ArrayCollection;
        
		/** @private */
		protected var cursor:IViewCursor;

        /** @private */
		protected var testCompleted:Boolean = true;

		/** 
		 * Convenience method for returning TestMonitor.xmlResults().
		 */
		public function get xmlResults():XML {
			return testMonitor.xmlResults;
		}

		/** 
		 * Returns the next test suite in the sequence.
		 */
		public function getNextTestSuite():TestSuite {
			var testSuite:TestSuite;
			if ( !cursor.afterLast && !cursor.beforeFirst ) {
				testSuite = cursor.current as TestSuite;
				cursor.moveNext();
				return testSuite;
			} 
			this.dispatchEvent(new Event(TESTS_COMPLETE));
			return null;			
		}

		/** 
		 * Handles timer events allowing us to act like a mini-round-robin 
		 * scheduler and ensure we don't recurse too deep in the stack. 
		 * Each TestMethod starts anew. 
		 * 
		 * @param event Event broadcast by the schedulerTimer.
		 */
		protected function handleTimerTick( event:TimerEvent ):void {
			//Here we check to see if we are ready for the next test method to be executed.
			//This allows us to manage the stack depth by always starting a new test on a fresh stack.
			if ( testCompleted ) {
				testCompleted = false;
				setupSuiteCaseAndMethodProperties();
				progressCursor.seek( CursorBookmark.FIRST );
				handleTestProcess( null );
			}
		}

		/** 
		 * Starts the testingProcess.
		 * 
		 * It can accept an ArrayCollection of TestSuites, an Array of TestSuites, a single 
		 * TestSuite, or a single TestCase
		 * 
		 * @param value An Object that can be a TestCase, a TestSuite, or an array of TestSuites.
		 */ 
		public function startTests( value:Object ):void {
			if ( value is Array ) {
				testSuiteCollection = new ArrayCollection( value as Array );
			} else if ( value is TestSuite ) {
				testSuiteCollection = new ArrayCollection( new Array( value ) );
			} else if ( value is TestCase ) {
				var suite:TestSuite = new TestSuite();
				suite.addTestCase( value as TestCase );
				testSuiteCollection = new ArrayCollection( new Array( suite ) );
			} else {
				throw new Error( "No Test or TestSuite Provided" );				
			}

			var sort:Sort = new Sort();
			sort.compareFunction = ClassSortUtils.testClassCompare;

			testSuiteCollection.sort = sort;
			testSuiteCollection.refresh();
			
			cursor = testSuiteCollection.createCursor();

			testMonitor.totalTestCount = getTestCount();

			schedulerTimer.start();
		}

		/** 
		 * Returns a count of all tests in the suites and test cases 
		 */
		public function getTestCount():int {
			var testCount:int = 0;

			for ( var i:int; i<testSuiteCollection.length; i++ ) {
				testCount += testSuiteCollection.getItemAt( i ).getTestCount();
			}
			
			return testCount;
		}

        /** @private */
		protected function setupSuiteCaseAndMethodProperties():void {
			if ( !testMonitor.testSuite ) {
				while ( ( testMonitor.testSuite = getNextTestSuite() ) != null ) {
					while ( ( testMonitor.testCase = testMonitor.testSuite.getNextTestCase() ) != null ) {
						while ( ( testMonitor.testMethod = testMonitor.testCase.getNextTestMethod() ) != null ) {
							return;
						}
					}
				}
				return;
			}

			while ( ( testMonitor.testMethod = testMonitor.testCase.getNextTestMethod() ) == null ) {
				while ( ( testMonitor.testCase = testMonitor.testSuite.getNextTestCase() ) == null ) {
					testMonitor.testSuite = getNextTestSuite();
					if ( !testMonitor.testSuite ) {
						//we are all done
						schedulerTimer.stop();
						return;
					}					
				}
			}
		}

		/**
		 * Starts running the setup phase of a given test method 
		 */
		protected function runSetup():void {
			testMonitor.testCase.addEventListener( TestCase.TEST_COMPLETE, handleTestProcess, false, 0, true );
			testMonitor.testCase.runSetup();
		}

		/**
		 * Starts running the method phase of a given test method 
		 */
		protected function runTestMethod():void {
			testMonitor.testCase.addEventListener( TestCase.TEST_COMPLETE, handleTestProcess, false, 0, true );
			testMonitor.testCase.runTestMethod( testMonitor.testMethod.method );
		}

		/**
		 * Starts running the teardown phase of a given test method 
		 */
		protected function runTearDown():void {
			testMonitor.testCase.addEventListener( TestCase.TEST_COMPLETE, handleTestProcess, false, 0, true );
			testMonitor.testCase.runTearDown();
		}

		/**
		 * Advances through the three phases, setIp, method and tearDown of each test.
		 * 
		 * @param event Broadcast in different phases of the test process.
		 */
		protected function handleTestProcess( event:Event ):void {
			var f:Function;

			if ( testMonitor.testCase ) {
				testMonitor.testCase.removeEventListener( TestCase.TEST_COMPLETE, handleTestProcess, false );
			}

			//get the current function to call
			f = progressCursor.current as Function;

			//move to the next function
			progressCursor.moveNext();

			//execute the function
			if ( ( f != null ) && ( testMonitor.testCase ) ) {
				f();
			}
			
			if ( progressCursor.afterLast && !testMonitor.testCase.hasPendingAsync) {
                //restart the process
                testCompleted = true;
            }
		}

        /** @private */
		override protected function createChildren():void {
			super.createChildren();
			
			var testEnvironment:TestEnvironment = TestEnvironment.getInstance(); 
			this.addChild( testEnvironment );
		}

        /**
         * Constructor.
         */
		public function TestRunner() {
			this.width = 0;
			this.height = 0;
			this.visible = false;
			
			var progressionArray:Array = [ runSetup, runTestMethod, runTearDown ];
			testProgression = new ArrayCollection( progressionArray );
			progressCursor = testProgression.createCursor();
			
			schedulerTimer = new Timer( 5, 0 );
			schedulerTimer.addEventListener(TimerEvent.TIMER, handleTimerTick );
		}
	}
}
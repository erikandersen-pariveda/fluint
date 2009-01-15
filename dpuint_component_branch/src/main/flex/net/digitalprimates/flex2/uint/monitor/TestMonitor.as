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
package net.digitalprimates.flex2.uint.monitor {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import net.digitalprimates.flex2.uint.tests.TestCase;
	import net.digitalprimates.flex2.uint.tests.TestMethod;
	import net.digitalprimates.flex2.uint.tests.TestSuite;

	/** 
	 * The TestMonitor class is a singleton that contains references to 
	 * all SuitesResults, CaseResults and MethodResults in the system.
	 * 
	 * TestCase calls methods within this class to report the results of 
	 * individual test methods. The UI monitors the contents of this class 
	 * to show a visualization to the user. 
	 */
	public class TestMonitor extends EventDispatcher {
		/** 
		 * A dictionary that maps TestSuites to TestSuiteResults.
		 */
		protected var testSuiteDictionary:Dictionary = new Dictionary( true );

		/** 
		 * A dictionary that maps TestCases to TestCaseResults.
		 */
		protected var testCaseDictionary:Dictionary = new Dictionary( true );

		/** 
		 * A dictionary that maps Functions to TestMethodResults.
		 */
		protected var testMethodDictionary:Dictionary = new Dictionary( true );
		
        /** @private */
		protected var _testSuite:TestSuite;
        
        /** @private */
		protected var _testCase:TestCase;

        /** @private */
		protected var _testMethod:TestMethod;
		
		/** @private */
		protected var lastTestSuite:TestSuite;

        /** @private */
		protected var lastTestCase:TestCase;

		[Bindable]
		/** 
		 * A collection of all testSuites being run by this interface.
		 */
		public var testSuiteCollection:ArrayCollection;

		[Bindable]
		/** 
		 * A total test count of all methods in all testcases in all testSuites.
         * 
         * @default 0
		 */
		public var totalTestCount:int = 0;

		[Bindable]
		/** 
		 * A total error count of all methods in all testcases in all testSuites. 
         * 
         * @default 0
		 */
		public var totalErrorCount:int = 0;

		[Bindable]
		/** 
		 * A total failure count of all methods in all testcases in all testSuites.
         * 
         * @default 0
		 */
		public var totalFailureCount:int = 0;

        /** @private */
		private static var instance:TestMonitor;
		
		/**
		 * Returns the single instance of the class. This is a singleton class. 
		 */		
		public static function getInstance():TestMonitor {
			if ( !instance ) {
				instance = new TestMonitor();
			}

			return instance;
		}
		
		/**
		 * Creates a new instance of the TestSuiteResult class. 
		 * Adds it to the internal mappings and to the testSuiteCollection.
		 * 
		 * @param testSuite The TestSuite which is about to be run.
		 * @return An instance of the TestSuiteResult class.
		 */		
		public function createTestSuiteResult( testSuite:TestSuite ):TestSuiteResult {
			var testSuiteResult:TestSuiteResult = new TestSuiteResult( testSuite );

			testSuiteDictionary[ testSuite ] = testSuiteResult;
			testSuiteCollection.addItem( testSuiteResult );
			
			return testSuiteResult;
		}
		
		/**
		 * Returns the instance of the TestSuiteResult based on the TestSuite.
		 * 
		 * @param testSuite A TestSuite which has been run.
		 * @return An instance of the TestSuiteResult class.
		 */		
		public function getTestSuiteResult( testSuite:TestSuite ):TestSuiteResult {
			return testSuiteDictionary[ testSuite ];		
		}

		/**
		 * Creates a new instance of the TestCaseResult class. 
		 * 
		 * Adds it to the internal mappings and to the appropriate TestSuiteResult 
		 * instance.
		 * 
		 * @param testSuite The TestSuite which is about to be run.
		 * @param testCase The TestCase which is about to be run.
		 * @return An instance of the TestCaseResult class.
		 */		
		public function createTestCaseResult( testSuite:TestSuite, testCase:TestCase ):TestCaseResult {
			var testCaseResult:TestCaseResult = new TestCaseResult( testCase );

			testCaseDictionary[ testCase ] = testCaseResult;
			
			var testSuiteResult:TestSuiteResult = getTestSuiteResult( testSuite );
			testSuiteResult.addTestCaseResult( testCaseResult );	
			
			return testCaseResult
		}

		/**
		 * Returns the instance of the TestCaseResult based on the TestCase.
		 * 
		 * @param testCase A TestCase which has been run.
		 * @return An instance of the TestCaseResult class.
		 */		
		public function getTestCaseResult( testCase:TestCase ):TestCaseResult {
			return testCaseDictionary[ testCase ];
		}

		/**
		 * Creates a new instance of the TestMethodResult class. 
		 * 
		 * Adds it to the internal mappings and to the appropriate TestCaseResult 
		 * instance.
		 * 
		 * @param testCase The TestCase which is about to be run.
		 * @param testMethod The TestMethod which is about to be run.
		 * @return An instance of the TestMethodResult class.
		 */		
		public function createTestMethodResult( testCase:TestCase, testMethod:TestMethod ):TestMethodResult {
			var testMethodResult:TestMethodResult = new TestMethodResult( testMethod );

			testMethodDictionary[ testMethod ] = testMethodResult;
			
			var testCaseResult:TestCaseResult = getTestCaseResult( testCase );
			testCaseResult.addTestMethodResult( testMethodResult );
			
			return testMethodResult;
		}

		/**
		 * Returns the instance of the TestMethodResult based on the actual method.
		 * 
		 * @param method A method which has been tested.
		 * @return An instance of the TestMethodResult class.
		 */		
		public function getTestMethodResult( method:Function ):TestMethodResult {
			var testMethodResult:TestMethodResult;

			for ( var testMethod:* in testMethodDictionary ) {				
				if ( testMethod.method == method ) {
					testMethodResult = testMethodDictionary[ testMethod ];
					break;
				}
			}

			return testMethodResult;
		}

		[Bindable('xmlResultsChanged')]
		/** 
		 * Returns an XML representation of all the tests in this system. 
		 * 
		 * It does so by querying each TestSuiteResult's xmlResults. This 
		 * data is intended to be consumed by external applications such 
		 * as CruiseControl 
		 */
		public function get xmlResults():XML {
			var tmpXML:XML = <testsuites/>
			var resultXML:XML;
			
			tmpXML.@status = ( totalFailureCount == 0 );
			tmpXML.@failureCount = totalFailureCount;
			tmpXML.@testCount = totalTestCount;
			//tmpXML.@endTime = getTimer()-mx.core.Application.application.startTime;

			for ( var i:int=0; i<testSuiteCollection.length; i++ ) {
				resultXML = ( testSuiteCollection.getItemAt( i ) as TestSuiteResult ).xmlResults;
				tmpXML.appendChild( resultXML );
			}
			
			return tmpXML;
		}

		/** 
		 * Monitors the testSuiteCollection for changes and updates the 
		 * totalFailureCount property.
		 */
		protected function handleCollectionChanged( event:Event ):void {
			var failureCount:int = 0;

			for ( var i:int=0; i<testSuiteCollection.length; i++ ) {
				failureCount += testSuiteCollection.getItemAt( i ).numberOfFailures;
			}
			
			if ( totalFailureCount > 0 ) {
				//trace("break here");
			}
			
			totalFailureCount = failureCount;
			
			//Notify any listeners to the XMLResults that they need to update
			dispatchEvent( new Event( 'xmlResultsChanged' ) );
		}
		
        /** 
		 * The current testSuite.
		 */
		public function get testSuite():TestSuite {
			return _testSuite;
		}

        /** @private */
		public function set testSuite( value:TestSuite ):void {
			if ( _testSuite != value ) {
				lastTestSuite = _testSuite;
				_testSuite = value;

				if ( value ) {
					createTestSuiteResult( value );
				}
				
				if ( lastTestSuite ) {
					var testSuiteResult:TestSuiteResult;
					testSuiteResult = getTestSuiteResult( lastTestSuite );
					
					if ( testSuiteResult ) {
						testSuiteResult.executed = true;
					}
				}
			}
		}

		/** 
		 * The current Test Case.
		 */
		public function get testCase():TestCase {
			return _testCase;
		}

        /** @private */
		public function set testCase( value:TestCase ):void {
			if ( _testCase != value ) {
				lastTestCase = _testCase;
				_testCase = value;

				if ( value ) {
					createTestCaseResult( _testSuite, value );
				}

				if ( lastTestCase ) {
					var testCaseResult:TestCaseResult = getTestCaseResult( lastTestCase );
					if ( testCaseResult ) {
						testCaseResult.executed = true;
					}
				}

			}
		}

		/** 
		 * The current test method. 
		 */
		public function get testMethod():TestMethod {
			return _testMethod;
		}

        /**
         * @private
         */
		public function set testMethod( value:TestMethod ):void {
			if ( _testMethod != value ) {
				_testMethod = value;

				if ( value != null ) {
					createTestMethodResult( _testCase, value );
				}
			}
		}

        /**
         * Constructor.
         */
		public function TestMonitor() {
			testSuiteCollection = new ArrayCollection();
			testSuiteCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChanged, false, 0, true );
		}
	}
}
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
package net.digitalprimates.fluint.monitor
{
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.PropertyChangeEvent;
	
	import net.digitalprimates.fluint.tests.TestSuite;
	import net.digitalprimates.fluint.ui.events.DisplayPropertyUpdateEvent;
	import net.digitalprimates.fluint.utils.ResultDisplayUtils;
	
	/** 
	 * This class contains result information about the execution of a test suite. 
	 * The TestMonitor class uses instances of this class to maintain state and 
	 * display information for each TestSuite. 
	 */  
	public class TestSuiteResult extends EventDispatcher implements ITestResultContainer
	{
        /**
         * @private
         */
		protected var _children:ArrayCollection = new ArrayCollection();

		/** 
		 * A human readable name for this class derived from the class name and path. 
		 */
		protected var displayName:String;

        /**
         * @private
         */
		protected var _status:Boolean = true;

        /**
         * @private
         */
		private var _executed:Boolean = false;

		/** 
		 * Boolean value that indicates if this case has been executed yet. 
		 */
		[Bindable('propertyChanged')]
		public function get executed():Boolean {
			return _executed;
		}
		
        /**
         * @private
         */
		public function set executed( value:Boolean ):void {
			var propertyChangedEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'executed', _executed, value );
			var dispPropertyEvent:DisplayPropertyUpdateEvent = DisplayPropertyUpdateEvent.createUpdateEvent( this, 'executed', _executed, value, null, null, this );
			_executed = value;
			dispatchEvent( propertyChangedEvent );
			dispatchEvent( dispPropertyEvent );
		}

		/** 
		 * A count of the number of failures in the TestCases represented by the 
		 * children of this class 
		 */
		public function get numberOfFailures():int {
			var count:int = 0;

			for ( var i:int; i<children.length; i++ ) {
				count += children[i].numberOfFailures;
			}

			return count;
		}

		/** 
		 * An ArrayCollection that holds instances of the TestCaseResult class. 
		 */
		[Bindable('propertyChanged')]
		public function get children():ArrayCollection {
			return _children;
		}

        /**
         * @private
         */
		public function set children( value:ArrayCollection ):void {
			var propertyChangedEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'children', _children, value );
			_children = value;
			dispatchEvent( propertyChangedEvent );
		}

		/** 
		 * Returns an XML representation of this TestSuiteResult and children 
		 * to be consumed by external applications such as CruiseControl.
		 */
		public function get xmlResults():XML {
			var result:XML = <testsuite/>;
			var methodList:XMLList = new XMLList();
			
			result.@name = displayName;
			result.@errors = '';
			result.@failures = '';
			result.@tests = '';
			result.@time = '';

			for ( var i:int; i<children.length; i++ ) {
				methodList += children[i].xmlResults;
			}

			result.appendChild( <properties/> );
			if ( methodList.length() ) {
				result.appendChild( methodList );
			}

			return result;
		}

		[Bindable('propertyChanged')]
		/** 
		 * Returns a single pass or fail status for all TestCases represented 
		 * by the children of this class. 
		 */
		public function get status():Boolean {
			return _status;
		}

		public function set status( value:Boolean ):void {
			if ( value !=  _status ) {
				var propertyChangedEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, 'status', _status, value );
				var dispPropertyEvent:DisplayPropertyUpdateEvent = DisplayPropertyUpdateEvent.createUpdateEvent( this, 'status', _status, value, null, null, this );

				_status = value;
				dispatchEvent( propertyChangedEvent );
				dispatchEvent( dispPropertyEvent );
			}
		}

		/** 
		 * Adds an instance of the TestCaseResult class as a child of this class 
		 * 
		 * @param testCaseResult
		 */
		public function addTestCaseResult( testCaseResult:TestCaseResult ):void {
			children.addItem( testCaseResult );

			testCaseResult.addEventListener( DisplayPropertyUpdateEvent.DISPLAY_PROPERTY_UPDATE, handleDisplayPropertyUpdate, false, 0, true );
		}

		protected function handleDisplayPropertyUpdate( event:DisplayPropertyUpdateEvent ):void {
			event.suiteResult = this;
			dispatchEvent( event ); 
		}

		protected function recalculateStatus():void {
			var newStatus:Boolean = status;

			if ( newStatus ) {
				for ( var i:int; i<children.length; i++ ) {
					newStatus &&= Boolean( children[i].status );
					if ( !newStatus ) {
						break;
					} 
				}
			}

			status = newStatus;
		}

		/** 
		 * Change handler that watches children for a change in their status 
		 * 
		 * @param event
		 */
		protected function handleTestCasesChange( event:CollectionEvent ):void {
			recalculateStatus();
		}

		/** 
		 * Provides a human readable representation of this class, including 
		 * name and status.
		 * 
		 * @inheritDoc
		 */
		override public function toString():String {
			return ResultDisplayUtils.toString( displayName, status, executed );
		}

		/** 
		 * Constructor.
		 * 
		 * @param testSuite The TestSuite represented by this TestCaseResult class.
		 */
		public function TestSuiteResult( testSuite:TestSuite ) {
			displayName = ResultDisplayUtils.createSimpleName( testSuite );
			children.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleTestCasesChange );
		}
	}
}
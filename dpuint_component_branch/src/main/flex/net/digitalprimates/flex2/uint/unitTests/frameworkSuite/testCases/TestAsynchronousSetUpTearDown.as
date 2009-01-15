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
package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import net.digitalprimates.flex2.uint.sequence.SequenceAction;
	import net.digitalprimates.flex2.uint.sequence.SequenceRunner;
	import net.digitalprimates.flex2.uint.sequence.SequenceWaiter;
	import net.digitalprimates.flex2.uint.tests.TestCase;

    /**
     * @private
     */
	public class TestAsynchronousSetUpTearDown extends TestCase {
		protected var simpleValueOne:Number;
		protected var simpleValueTwo:Number;
		protected var simpleValueThree:Number;

		protected var timer1:Timer;
		protected var timer2:Timer;

		protected var unitializedBySetup:Object;

		protected static var SHORT_TIME:int = 50;
		protected static var LONG_TIME:int = 1000;

		override protected function setUp():void {
			super.setUp();

            timer1 = new Timer( SHORT_TIME, 5 );
            timer2 = new Timer( SHORT_TIME + 250, 10 );
            
            timer1.start();
            timer2.start();

            trace("Setup");
            var sequence : SequenceRunner = new SequenceRunner(this);
            
            sequence.addStep(new SequenceWaiter(timer1, TimerEvent.TIMER_COMPLETE, 100000, handleSetupFailure));
            sequence.addStep(new SequenceAction(handleAsyncSetupCompleteOne));
            
            sequence.addStep(new SequenceWaiter(timer2, TimerEvent.TIMER_COMPLETE, 100000, handleSetupFailure));
            sequence.addStep(new SequenceAction(handleAsyncSetupCompleteTwo));
            
            sequence.addAssertHandler(function() {
                trace("Inside assert handler");
            }, null);
            sequence.run();
			
			simpleValueThree = 3;
		}
		
		
		protected function handleAsyncSetupCompleteOne():void {
		    trace("Setup one");
		    
			simpleValueOne = 1;
			
			if ( unitializedBySetup ) {
				fail("variable unitializedBySetup was initialized. Test ran before setup was complete");
			}
		}

		protected function handleAsyncSetupCompleteTwo():void {
		    trace("Setup two");
		    
			simpleValueTwo = 2;
			
			if ( unitializedBySetup ) {
				fail("variable unitializedBySetup was initialized. Test ran before setup was complete");
			}
		}
		
		protected function handleSetupFailure( passThroughData:Object ):void {
			fail("Setup did not finish in requisite amount of time");
		}
		
		override protected function tearDown():void {
			super.tearDown();

			simpleValueOne = -1;
			simpleValueTwo = -1;
			simpleValueThree = -1;

			unitializedBySetup = null;
		}
		
		/**We are only testing setup and teardown, we don't really care what happens here**/
	    public function testEnsureSetupComplete() : void {
	        trace("Running test");
	        
	    	assertEquals( 1, simpleValueOne );
	    	assertEquals( 2, simpleValueTwo );
	    	assertEquals( 3, simpleValueThree );
	    	unitializedBySetup = new Object();
	    }
	}
}
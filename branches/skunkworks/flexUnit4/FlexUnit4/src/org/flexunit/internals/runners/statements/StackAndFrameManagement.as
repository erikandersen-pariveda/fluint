/**
 * Copyright (c) 2009 Digital Primates IT Consulting Group
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
 * 
 * @author     Michael Labriola <labriola@digitalprimates.net>
 * @version    
 **/ 

/**
 * This class allows us to break execution across frames and ensure we don't have a stack overflow
 * it does this by starting a timer when it is asked to evaluate itself. When the timer fires, which
 * will be the following frame, we resume the execution. One might argue (with validity) that we 
 * shouldn't do this on each test, but rather take a more green threaded approach and look at how
 * much time we have taken so far. This would make things run much faster and may be considered for
 * a future version
 **/
package org.flexunit.internals.runners.statements {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;

	public class StackAndFrameManagement implements IAsyncStatement {
		protected var parentToken:AsyncTestToken;		
		protected var myToken:AsyncTestToken;
		protected var timer:Timer;
		protected var statement:IAsyncStatement;

		public function StackAndFrameManagement( statement:IAsyncStatement ) {
			super();
			
			this.statement = statement;
			
			timer = new Timer( 1, 1 );
			//This timer must *NOT* have a weak reference. Sometimes things run fast enough
			//that this class will be eligible for garbage collection in between the frames
			//which causes the tests to cease, keeping this strong prevents collection until
			//we are ready
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete, false, 0, false );
			
			myToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			myToken.addNotificationMethod( handleNextExecuteComplete );
		}

		public function evaluate( previousToken:AsyncTestToken ):void {
			parentToken = previousToken;
			timer.start();
		}

		protected function handleTimerComplete( event:TimerEvent ):void {
			timer.removeEventListener( TimerEvent.TIMER_COMPLETE, handleTimerComplete, false );
			statement.evaluate( myToken );
		}

		public function handleNextExecuteComplete( result:ChildResult ):void {
			parentToken.sendResult( result.error );
		}

		public function toString():String {
			return "Stack Management Base";
		}
	}
}

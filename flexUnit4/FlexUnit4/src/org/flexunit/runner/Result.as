package org.flexunit.runner {
	import org.flexunit.runner.notification.RunListener;
	import org.flexunit.internals.namespaces.classInternal;
	
	use namespace classInternal;

	/**
	 * A <code>Result</code> collects and summarizes information from running multiple
	 * tests. Since tests are expected to run correctly, successful tests are only noted in
	 * the count of tests that ran.
	 */
	public class Result {
		classInternal var _runCount:int = 0;
		classInternal var _ignoreCount:int = 0;
		classInternal var _runTime:Number = 0;
		classInternal var _startTime:Number;

		private var _failures:Array = new Array()
		
		/**
		 * @return the number of tests that failed during the run
		 */
		public function get failureCount():int {
			return failures.length;
		}

		/**
		 * @return the {@link Failure}s describing tests that failed and the problems they encountered
		 */
		public function get failures():Array {
			return _failures;
		}

		/**
		 * @return the number of tests ignored during the run
		 */
		public function get ignoreCount():int {
			return _ignoreCount;
		}

		/**
		 * @return the number of tests run
		 */
		public function get runCount():int {
			return _runCount;
		}

		/**
		 * @return the number of milliseconds it took to run the entire suite to run
		 */
		public function get runTime():Number {
			return _runTime;
		}

		/**
		 * @return <code>true</code> if all tests succeeded
		 */
		public function get successful():Boolean {
			return ( failureCount == 0 );
		}
		
		/**
		 * Internal use only.
		 */
		public function createListener():RunListener {
			var listener:Listener = new Listener();;
			listener.result = this;
			return listener;
		}

		public function Result() {
		}
	}
}

import flash.utils.getTimer;
import org.flexunit.runner.notification.RunListener;
import org.flexunit.runner.Description;
import org.flexunit.runner.Result;
import org.flexunit.runner.notification.Failure;
import org.flexunit.internals.namespaces.classInternal;

use namespace classInternal;

class Listener extends RunListener {
	private var fIgnoreDuringExecution:Boolean = false;
	
	override public function testRunStarted( description:Description ):void {
		result._startTime = getTimer();
	}

	override public function testRunFinished( result:Result ):void {
		var endTime:Number = getTimer();
		result._runTime += endTime - result._startTime;
	}

	override public function testFinished( description:Description ):void {
		if (!fIgnoreDuringExecution) {
			result._runCount++;
		}
		
		fIgnoreDuringExecution = false;
	}

	override public function testFailure( failure:Failure ):void {
		result.failures.push( failure );
	}

	override public function testIgnored( description:Description ):void {
		result._ignoreCount++;
		fIgnoreDuringExecution = false;
	}
}
/**
 * Copyright (c) 2008 Digital Primates IT Consulting Group
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
package net.digitalprimates.fluint.sequence
{
	import flash.events.IEventDispatcher;

	public class SequenceCaller implements ISequenceAction
	{
        /**
         * @private
         */
		protected var _thisObject:Object;

        /**
         * @private
         */
		protected var _args:Array;

        /**
         * @private
         */
		protected var _method:Function;

        /**
         * @private
         */
		protected var _argsFunction:Function;

        /**
         * The object where the method lives.  If the method is an anonymous function, this is null.
         */
        public function get thisObject():Object {
            return _thisObject;
        }

		/** 
		 * <p>
		 * A method to be executed when this step occurs </p>
		 * 
		 */
		public function get method():Function {
			return _method;
		}
		/** 
		 * <p>
		 * An array that contains the arguments to the method that will be called</p>
		 * 
		 */
		public function get args():Array {
			return _args;
		}

		/** 
		 * <p>
		 * Function that returns an array of arguments to be passed to the method. When using the args array, each item is evaluated at the time when the step is created. Using the argsFunction, the function is called just before
		 * method invocation, providing a set of arguments that are evaluated during step execution.</p>
		 * 
		 */
		public function get argsFunction():Function {
			return _argsFunction;
		}
		/**
		 * Invokes the function specified in the constructor.
		 */
		public function execute():void {
			var arguments:Array;
			
			if ( args ) {
				arguments = args;
			} else if ( argsFunction != null ) {
				arguments = argsFunction();
			} 
			
			if ( arguments && ( arguments.length > 0 ) ) {
				method.apply( thisObject, arguments );
			} else {
				method.apply( thisObject );
			}
		}

		/**
		 * Constructor.
		 *  
		 * @param thisObject The object where the function lives; null if method is an anonymous function
		 * @param method Method that will be executed when this step is executed.
  		 * @param args Optional parameter that contains an array of arguments that will be passed to this method.
  		 * @param argsFunction Optional function that returns an of arguments to be passed to method. 
 * 		 */
		public function SequenceCaller( thisObject:Object, method:Function, args:Array=null, argsFunction:Function=null ) {
			_thisObject = thisObject;
			_method = method;
			_args = args;
			_argsFunction = argsFunction;
		}
	}
}
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
package net.digitalprimates.fluint.sequence {
	import mx.events.FlexEvent;
	
	import net.digitalprimates.fluint.utils.LoggerUtils;
	
	/** 
	 * The sequence setter class tells the TestCase instance to set properties on 
	 * the target.
	 */	 
	public class SequenceSetter implements ISequenceAction {
        /**
         * @private
         */
		protected var _targetSelector:TargetSelector;

        /**
         * @private
         */
		protected var _props:Object;
		
		private var _propertiesChanged:Object = new Object();

		/** 
		 * The object where the properties/value pairs defined 
		 * in the props object will be set. 
		 */
		public function get target():Object {
			return _targetSelector.target;
		}

		/** 
		 * <p>
		 * A generic object that contains name/value pairs that should be set on the target.</p>
		 * 
		 * <p>
		 * For example, if the target were a TextInput, a props defined like this: </p>
		 * 
		 * <p><code>
		 * {text:'blah',enabled:false}</code></p>
		 * 
		 * <p>
		 * Would set the text property to 'blah' and the enabled property to false.
		 */
		public function get props():Object {
			return _props;
		}
		
		public function set props(value:Object):void {
            _props = value;
        }
		
		public function get propertiesChanged():Object {
		    return _propertiesChanged;
		}

		/**
		 * Sets the name/value pairs defined in the props object to the target.
		 */
		public function execute():void {
			if ( props && target) {
			    //Set all requested values on this object
				for ( var prop:String in props ) {
					trace("[Sequence] Setting [" + prop + "] to '" + props[prop] + "' on " + LoggerUtils.friendlyName(target));
						
				    // If property isn't different, no FlexEvent will be dispatched
					if (target[prop] == props[prop])
					{
            			target.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));						  
					}
					else
					{
					  _propertiesChanged[ prop ] = props[ prop ];
					  target[ prop ] = props[ prop ];
					}
				}  
			}
		}

		/**
		 * Constructor.
		 *  
		 * @param target The object where the properties will be set.
		 * @param props Contains the property/value pairs to be set on the target.
		 */
		public function SequenceSetter( target:Object, props:Object ) {
			_targetSelector = TargetSelectorFactory.determineSelector(target);
			_props = props;
		}
	}
}
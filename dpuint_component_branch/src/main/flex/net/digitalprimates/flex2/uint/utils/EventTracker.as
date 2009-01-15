package net.digitalprimates.flex2.uint.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.utils.Dictionary;
	
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;
	
	/**
	 * Records which events were fired on registered components.
	 * 
	 * This is mainly used to make assertions that the framework simulates the correct events for user actions.
	 */
	public class EventTracker
	{
		private var _eventMap : Object = new Object();
		
		/** Array of events to listen to. */
		private var _events : Array = [FlexEvent.DATA_CHANGE,
                                       FlexEvent.VALUE_COMMIT,
                                       FlexEvent.ENTER, // ENTER KEY
                                       TextEvent.TEXT_INPUT,
                                    
                                       MouseEvent.CLICK,
                                       MouseEvent.MOUSE_DOWN,
                                       MouseEvent.MOUSE_UP,
                                       
                                       KeyboardEvent.KEY_DOWN,
                                       KeyboardEvent.KEY_UP,
                                    
                                       Event.CHANGE,
                                       Event.SELECT];
                                       
        /** Most popups have the Application as their parent, so we need to register these events on Application.application. */                                       
        private var _applicationEvents : Array = [CloseEvent.CLOSE];
		
		/** 
		 * Key is an EventDispatcher, value is an Array of Objects representing events registered where each object has the following properties:
		 * 
		 * name        = String of the event name
		 * functionRef = function reference to the event listener that was registered 
		 */
		private var _listeners : Dictionary = new Dictionary();
		
		private static var _instance : EventTracker = new EventTracker();
		
		public static function get instance() : EventTracker {
			return _instance;
		}
		
		/**
		 * Clears all recorded events and removes all existing event listeners.
		 * 
		 * <p>If used for testing, it is expected that you would call reset before each test case.</p>
		 */
		public function reset() : void 
		{
			unregisterEvents();
			
			_listeners = new Dictionary();
			_eventMap = new Object();
		}
		
		private function unregisterEvents() : void {
            for (var key : Object in _listeners) {
                var component : EventDispatcher = key as EventDispatcher;
                    
                for each(var listener : Object in _listeners[component]) {
                    component.removeEventListener(listener.name, listener.functionRef, false);
                    component.removeEventListener(listener.name, listener.functionRef, true);
                }
            }
		}
		
		public function EventTracker() 
        {
          if (_instance == null) 
          {
            _instance = this;
          } 
          else
          {
            throw new Error("EventTracker meant to be built through factory method, instance()");
          }
        }
		
		/**
		 * A map of all the events fired with the key being the short id of the component and the value being a String Array of
		 * all events fired in the order they were fired.
		 */
		public function get eventMap() : Object 
		{
			return _eventMap;
		}
		
		/**
		 * Adds event listeners for all the events in the <code>_events</code> array.
		 * 
		 * <p>Typically, you would add this call to the <code>init</code> method of the outermost component.  Since all events triggered
		 *    by Fluint are set to bubble, the outermost element will catch all events. Here is an example:</p>
		 * 
		 * <p>
		 * <code>
		 * <mx:VBox size="100%" height="100%" init="EventTracker.instance.recordEvents(event)">
		 * ...
		 * </mx:VBox>
		 * </code>
		 * </p>
		 * 
		 */
		public function recordEvents(initEvent : Event) : void
        {
            _listeners[initEvent.target] = new Array();
                                   
            registerEvents(_events, initEvent.target as EventDispatcher);
            registerEvents(_applicationEvents, Application.application.systemManager);
        }
        
        private function registerEvents(events : Array, target : EventDispatcher) : void 
        {
            for each(var eventName : String in events) {
                var listener : Function = eventListenerGenerator(eventName);
                target.addEventListener(eventName, listener);
                
                if (!_listeners[target]) {
                    _listeners[target] = new Array();
                }
                _listeners[target].push({name: eventName, functionRef: listener});
            }
        }
        
        private function eventListenerGenerator(eventChangeValue : String) : Function 
        {
                return function(e : Event) : void {
                    if (e.type == CloseEvent.CLOSE) {
                        trace("Close found");
                    }
                    
                    if (!e.target.hasOwnProperty("id")) {
                        throw new Error("Expecting target element to have id. [" + e.target + "]");
                    }
                    
                    var key : Object;
                    if (e.target["id"] && e.target["id"] != "") {
                        key = e.target["id"];
                    } else {
                        key = e.target;
                    }
                    
                    if (!_eventMap[key]) {
                        _eventMap[key] = new Array();
                    }
                    _eventMap[key].push(eventChangeValue);    
                    
                    trace("Event '" + eventChangeValue + "' fired on '" + e.target["id"] + "'");
                };
            };
	}
}
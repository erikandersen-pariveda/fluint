package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
    import flash.events.Event;
    
    import mx.events.IndexChangedEvent;
    
    import net.digitalprimates.flex2.uint.tests.ComponentTestCase;
    import net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases.mxml.SelectableControlSet;
    import net.digitalprimates.flex2.uint.utils.EventTracker;

    public class TestSelectableComponentsTestCase extends ComponentTestCase
    {
        private var controls : SelectableControlSet;
        
        // TODO Should also be receiving valueCommit events
        //      Have to modify EventTracker to register on all components at startup since valueCommit events don't bubble
        private var expectedEvents : Array = ["change"];
        
        public function TestSelectableComponentsTestCase()
        {
            super(function():SelectableControlSet {
                EventTracker.instance.reset();
                return new SelectableControlSet();
            });
        }
        
        override protected function uiComponentReady():void {
            this.controls = uiComponent as SelectableControlSet;
        }
        
        public function testSelectElementOfListByIndex() : void {
            selectByIndex(2, controls.simpleList);
            
            assertFinished(function() {
               assertEquals(controls.simpleList.selectedIndex, 2);
               assertObjectEquals(controls.simpleList.selectedItem, controls.numbers[2]);
               assertObjectEquals(expectedEvents, EventTracker.instance.eventMap["simpleList"]); 
            });
        }
        
        public function testSelectElementOfListByDirectValue() : void {
            select(controls.numbers[0], controls.simpleList);
            
            assertFinished(function() {
               assertEquals(IndexChangedEvent.CHANGE, Event.CHANGE);
               assertEquals(controls.simpleList.selectedIndex, 0);
               assertObjectEquals(controls.simpleList.selectedItem, controls.numbers[0]);
               assertObjectEquals(EventTracker.instance.eventMap["simpleList"], expectedEvents); 
            });
        }
        
        /**
         * This tests whether you can pass in a different, but EQUAL object in as the select value.
         * 
         * When your dataProvider is a <mx:Array> of <mx:Object>s, Flex adds an annoying extra property 'mx_internal_uid' to each 
         * object, making the literal object different than the object in dataProvider.  This test proves we can ignore that one 
         * property.
         */
        public function testSelectElementOfListByLiteralValue() : void {
            // Elements in the dataprovider have some extra properties
            assertObjectNotEquals({label:"One", data:1}, controls.numbers[0]);
            
            select({label:"One", data:1}, controls.simpleList);
            
            assertFinished(function() {
               assertObjectEquals(controls.simpleList.selectedItem, controls.numbers[0]);
               assertEquals(controls.simpleList.selectedIndex, 0);
               assertObjectEquals(EventTracker.instance.eventMap["simpleList"], expectedEvents);
            });
        }
        
        public function testSelectElementOfListByLabel() : void {
            select("One", controls.simpleList);
            
            assertFinished(function() {
               assertObjectEquals(controls.simpleList.selectedItem, controls.numbers[0]);
               assertEquals(controls.simpleList.selectedIndex, 0);
               assertObjectEquals(EventTracker.instance.eventMap["simpleList"], expectedEvents);
            });
        }
    }
}
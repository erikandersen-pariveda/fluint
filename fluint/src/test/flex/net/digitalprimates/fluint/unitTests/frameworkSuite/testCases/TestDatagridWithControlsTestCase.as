package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.utils.Dictionary;
	
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import net.digitalprimates.fluint.tests.ComponentTestCase;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.mxml.DatagridWithControls;
	import net.digitalprimates.fluint.utils.EventTracker;

    /**
     * Tests accessing controls inside a datagrid.
     */
	public class TestDatagridWithControlsTestCase extends ComponentTestCase
	{
        private var datagridWithControls : DatagridWithControls;		
		
		public function TestDatagridWithControlsTestCase()
		{
			super(function():UIComponent {
		      EventTracker.instance.reset();
			  return new DatagridWithControls();
			});
		}
		
		override protected function uiComponentReady() : void
		{
			this.datagridWithControls = uiComponent as DatagridWithControls;
		}
		
		public function testClickButton() : void {
			clickOn(elementInCell("aButton", 0, 0, datagridWithControls.dataGrid));
			
			assertFinished(function() {
				assertObjectEquals(EventTracker.instance.eventMap["aButton"], [MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP, MouseEvent.CLICK]);
			});
		}
		
		public function testTypeIntoText() : void {
            typeInto("Hello World", elementInCell("aTextInput", 0, 4, datagridWithControls.dataGrid));
            
            assertFinished(function() {
                assertObjectEquals(EventTracker.instance.eventMap['aTextInput'], [KeyboardEvent.KEY_DOWN, KeyboardEvent.KEY_UP, TextEvent.TEXT_INPUT, Event.CHANGE]);
            });
        }
	}
}
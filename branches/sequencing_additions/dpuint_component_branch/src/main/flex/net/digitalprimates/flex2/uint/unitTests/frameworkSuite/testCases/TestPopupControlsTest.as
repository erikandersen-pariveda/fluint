package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.core.UIComponent;
    import mx.events.CloseEvent;
    
    import net.digitalprimates.flex2.uint.tests.ComponentTestCase;
    import net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases.mxml.PopupControlSet;
    import net.digitalprimates.flex2.uint.utils.ArrayUtils;
    import net.digitalprimates.flex2.uint.utils.EventTracker;

    public class TestPopupControlsTest extends ComponentTestCase
    {
        private var popups : PopupControlSet;
        
        public function TestPopupControlsTest()
        {
            super(function() : UIComponent {
                EventTracker.instance.reset();
                return new PopupControlSet();
            });
        }
        
        override protected function uiComponentReady(): void 
        {
           popups = uiComponent as PopupControlSet; 
        }
        
        private function findClosedPopupWithMessage(message : String) : Alert 
        {
            var matches : Array = ArrayUtils.matchOnIncludes({text: message}, new ArrayCollection(closedPopups));
            if (matches.length > 1) 
            {
                fail("Expected to find --at most-- one popup with message [" + message + "], found " + matches.length);
            } 
            else if (matches.length == 1) 
            {
                return matches[0];
            }
            return null;    
        }
        
        public function testDefaultNoClose() : void 
        {
            clickOn(popups.defaultPopup);
            waitForPopup("Hello World", 1000, false);
            
            assertFinished(function() {
               assertNotNull("Pop up should have been closed by now.", popUpWithMessage("Hello World")); 
               assertEquals(EventTracker.instance.eventMap[popUpWithMessage("Hello World")], null);
            });
        }
        
        public function testDefault() : void 
        {
            clickOn(popups.defaultPopup);
            waitForPopup("Hello World");
            
            assertFinished(function() {
               assertNull("Pop up should have been closed by now.", popUpWithMessage("Hello World"));
               
               var closedAlert : Alert = findClosedPopupWithMessage("Hello World");
               assertObjectEquals(EventTracker.instance.eventMap[closedAlert], [CloseEvent.CLOSE]); 
            });
        }
        
        // This should fail as we never create a popup with text 'Hello Mars'
        public function testDefaultNoMatch() : void 
        {
            clickOn(popups.defaultPopup);
            waitForPopup("Hello Mars");

            assertFails(function() {
               play(); 
            });            
            assertNull(popUpWithMessage("Hello Mars")); 
        }
        
        public function testYesNo() : void 
        {
            clickOn(popups.yesNoPopup);
            waitForPopup("Yes and No");
            
            assertFinished(function() {
               trace("Inside assert handler for yesNoPopup");
               assertNull("Should not have been closed yet.", findClosedPopupWithMessage("Yes and No"));
               assertNotNull("Should not close by default yes/no alerts.", popUpWithMessage("Yes and No"));
            });
        }
        
        
    }
}
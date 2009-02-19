package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
    import net.digitalprimates.fluint.assertion.AssertionFailedError;
    import net.digitalprimates.fluint.tests.ComponentTestCase;
    import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.mxml.ButtonsControlSet;
    import net.digitalprimates.fluint.utils.EventTracker;

    public class TestButtonComponentsTestCase extends ComponentTestCase
    {
        private var controls : ButtonsControlSet;
        
        public function TestButtonComponentsTestCase()
        {
            super(function():ButtonsControlSet {
                EventTracker.instance.reset();
                return new ButtonsControlSet();
            });
        }
        
        override protected function uiComponentReady():void {
            this.controls = uiComponent as ButtonsControlSet;
        }
        
        public function testRegularButton() : void {
            clickOn(this.controls.button);
            
            assertFinished(function() {
               assertObjectEquals(EventTracker.instance.eventMap["button"], ["mouseDown", "mouseUp", "click"]);
               assertFalse(controls.button.selected);
               assertNull(controls.button.selectedField); 
            });
        }
        
        public function testToggledButton() : void {
            assertTrue(this.controls.toggledButton.toggle);
            
            clickOn(this.controls.toggledButton);
            
            assertFinished(function() {
               assertObjectEquals(EventTracker.instance.eventMap["toggledButton"], ["mouseDown", "mouseUp", "click"]);
               assertTrue(controls.toggledButton.selected);
               assertNull(controls.toggledButton.selectedField); 
            });
        }
        
        public function testClickDisabledButton() : void {
            assertFalse(controls.disabledButton.enabled);
            
            clickOn(controls.disabledButton);
            
            assertFails(function() {
                play();    
            }, "Should have failed when clicking a disabled button."); 
        }
        
        public function testClickInvisibleButton() : void {
            assertFalse(this.controls.invisibleButton.visible);
            
            clickOn(this.controls.invisibleButton);
            
            assertFails(function() {
                play();
            }, "Should have failed when clicking an invisibleButton button."); 
        }
        
         public function testLinkButton() : void {
            clickOn(this.controls.linkButton);
            
            assertFinished(function() {
               assertObjectEquals(EventTracker.instance.eventMap["linkButton"], ["mouseDown", "mouseUp", "click"]);
               assertFalse(controls.linkButton.selected);
               assertNull(controls.linkButton.selectedField); 
            });
        }
        
        public function testCheckUncheckedBox() : void {
            clickOn(this.controls.checkBox);
            
            assertFinished(function() {
               assertObjectEquals(EventTracker.instance.eventMap["checkBox"], ["mouseDown", "mouseUp", "click"]);
               assertTrue(controls.checkBox.selected);
               assertNull(controls.checkBox.selectedField); 
            });
        }
        
        public function testUncheckCheckBox() : void {
            clickOn(this.controls.checkBoxInitiallyChecked);
            
            assertFinished(function() {
               assertObjectEquals(EventTracker.instance.eventMap["checkBoxInitiallyChecked"], ["mouseDown", "mouseUp", "click"]);
               assertFalse(controls.checkBox.selected);
               assertNull(controls.checkBox.selectedField); 
            });
        }
    }
}
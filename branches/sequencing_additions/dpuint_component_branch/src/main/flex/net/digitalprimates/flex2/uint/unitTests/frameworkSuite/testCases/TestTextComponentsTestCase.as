package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
    import net.digitalprimates.flex2.uint.assertion.AssertionFailedError;
    import net.digitalprimates.flex2.uint.tests.ComponentTestCase;
    import net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases.mxml.TextControlSet;
    import net.digitalprimates.flex2.uint.utils.EventTracker;

    public class TestTextComponentsTestCase extends ComponentTestCase
    {
        private var controls : TextControlSet;
        
        public function TestTextComponentsTestCase()
        {
            super(function():TextControlSet {
                EventTracker.instance.reset();
                return new TextControlSet();
            });
        }
        
        override protected function uiComponentReady():void {
            this.controls = uiComponent as TextControlSet;
        }
        
        public function testTypeIntoTextField() : void {
            typeInto("Hello World", controls.textInput);
            
            assertFinished(function() {
                assertEquals(controls.textInput.text, "Hello World");
                assertObjectEquals(EventTracker.instance.eventMap["textInput"], ["keyDown", "keyUp", "textInput", "change"]);
            });
        }
        
        public function testTypeButDoNotChangeValue() : void {
            assertEquals("Control already has a value.", "Hello World!", controls.textInputWithInitialValue.text);
            typeInto("Hello World!", controls.textInputWithInitialValue);
            
            assertFinished(function() {
                assertEquals("Hello World!", controls.textInputWithInitialValue.text);
                assertObjectEquals(EventTracker.instance.eventMap["textInputWithInitialValue"], ["keyDown", "keyUp", "textInput"]);
            });    
        }
        
        public function testTypeIntoDisabledTextInput() : void {
            assertFalse(controls.disabledTextInput.enabled);
            typeInto("Hello!", controls.disabledTextInput);
            
            assertFails(function() {
                play();    
            });
            
            assertNull(EventTracker.instance.eventMap["disabledTextInput"]);
            assertEmpty(controls.disabledTextInput);
        }
        
        public function testTypeIntoInvisibleTextInput() : void {
            var executionSucceeded : Boolean = false;
            assertFalse(this.controls.invisibleTextInput.visible);
            
            typeInto("Hello!", this.controls.invisibleTextInput);
            
            assertFails(function() {
                play();
            });
            
            assertNull(EventTracker.instance.eventMap["invisibleTextInput"]);
            assertEmpty(controls.invisibleTextInput); 
        }
    }
}
package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
    import flash.display.DisplayObject;
    
    import net.digitalprimates.fluint.tests.ComponentTestCase;
    import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.mxml.ComponentToFindStuffIn;

    public class ComponentFinderTest extends ComponentTestCase
    {
        private var component : ComponentToFindStuffIn;
        
        public function ComponentFinderTest()
        {
            super(function() {return new ComponentToFindStuffIn();}, false);
            
            // includeByName("testFindByTextOnAPopup");
            includeByName("testFindButtonInControlBar");
        }
        
        override protected function uiComponentReady() : void
        {
            this.component = uiComponent as ComponentToFindStuffIn;
        }
        
        public function testFindById() : void
        {
            var textElement : DisplayObject = componentFinder.withId("aTextElement");
            assertNotNull(textElement);
            assertEquals("Fluint", textElement["text"]);
        }
        
        public function testFindByName() : void
        {
            var textElement : DisplayObject = componentFinder.withName("aNamedTextElement");
            assertNotNull(textElement);
            assertEquals("Fluint", textElement["text"]);
        }
        
        public function testFindByTextInText() : void
        {
            var element : DisplayObject = componentFinder.withText("Hello World");
            assertEquals(component.helloWorldTextElement, element);
            assertEquals("Hello World", element["text"]);
        }
        
        public function testFindByTextInLabel() : void
        {
            var element : DisplayObject = componentFinder.withText("Hello World on a Button");
            assertEquals(component.helloWorldButton, element);
            assertEquals("Hello World on a Button", element["label"]);
        }
        
        private function testFindByTextOnAPopup(popupContainer : Object) : void
        {
            clickOn(popupContainer);
            
            waitUntil(allTrue(function() {
                assertEquals("Should find the button on the root first!", component.helloWorldButton, componentFinder.withText("Hello World on a Button"));
                assertNotNull("Can't find button on popup.", componentFinder.withText("New Button on Popup"));
            }));

            play();            
        }
        
        public function testFindByTextOnAPopupWhoseParentIsSelf() : void
        {
            testFindByTextOnAPopup(component.popupCreatorOnSelf);
        }
        
        public function testFindByTextOnAPopupWhoseParentIsApplication() : void
        {
            testFindByTextOnAPopup(component.popupCreatorOnApplication);
        }
        
        public function testFindByTextOnAModalPopupWhoseParentIsSelf() : void
        {
            testFindByTextOnAPopup(component.modalPopupCreatorOnSelf);
        }
        
        public function testFindByTextOnAModalPopupWhoseParentIsApplication() : void
        {
            testFindByTextOnAPopup(component.modalPopupCreatorOnApplication);
        }
        
        public function testFindButtonInControlBar() : void
        {
            assertEquals(component.buttonInControlBar, componentFinder.withText("Button In Control Bar"));
        }
        
        public function testFindByProperties() : void
        {
            var textElement : DisplayObject = componentFinder.withAny({text: "Fluint"});
            assertNotNull(textElement);
            assertEquals("Fluint", textElement["text"]);
        }
        
    }
}
package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
	import mx.core.UIComponent;
	
	import net.digitalprimates.fluint.tests.ComponentTestCase;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.mxml.NullReferences;

	public class SelectByFunctionTestCase extends ComponentTestCase
	{
		private var nullReferences : NullReferences;
		
		public function SelectByFunctionTestCase()
		{
			super(function():UIComponent {
				return new NullReferences();
			});
		}
		
		override protected function uiComponentReady() : void {
            this.nullReferences = uiComponent as NullReferences;
        }
		
		public function testAssertions() : void {
			assertFinished(function():void {
				assertNull(nullReferences.textFieldOnClick);
			});
		}
		
		public function testPopulateOnClick() : void {
            clickOn(nullReferences.button);
            
            assertFinished(function():void {
                assertNotNull(nullReferences.textFieldOnClick);
            });		
		}
		
		public function testSelectByReference() : void {
			clickOn(nullReferences.button);
			
			typeInto("Hello World!", function():UIComponent {
				return nullReferences.textFieldOnClick;
			});
			
			assertFinished(function():void {
                assertNotNull(nullReferences.textFieldOnClick);
                assertEquals("Hello World!", nullReferences.textFieldOnClick.text);
            }); 
		}
		
		// Look ahead bugs
		
		/**
		 * This fails in playback as the function reference will continue to return null <em>until</em> the button is clicked.
		 */
		public function testSelectByReferenceWithLookAheadEvent() : void {
			clickOn(nullReferences.button);
			typeInto("Hello World from child component.", function() {
			  return nullReferences.childNullReferences.textField}
			);
			
			play();
		}
	}
}
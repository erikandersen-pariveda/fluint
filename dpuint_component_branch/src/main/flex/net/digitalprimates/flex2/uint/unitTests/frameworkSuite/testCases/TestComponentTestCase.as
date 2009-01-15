package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
  import mx.core.UIComponent;
  
  import net.digitalprimates.flex2.uint.tests.ComponentTestCase;
  import net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases.mxml.SimpleMXMLLoginComponent;
  
  public class TestComponentTestCase extends ComponentTestCase
  {
    private var loginScreen:SimpleMXMLLoginComponent;
    
    public function TestComponentTestCase()
    {
      super(function():UIComponent {
        return new SimpleMXMLLoginComponent();
      });
    }
    
    override protected function uiComponentReady() : void {
      this.loginScreen = uiComponent as SimpleMXMLLoginComponent;
    }
    
    // -- Test asserts
    
    public function testInitialState() : void {
      assertFinished(function():void {
        assertVisible(loginScreen.usernameTI);
        assertVisible(loginScreen.passwordTI);
        
        assertValid(loginScreen.usernameTI);
        assertValid(loginScreen.passwordTI);
        
        assertEnabled(loginScreen.loginBtn);
        assertEnabled(loginScreen.cancelBtn);
      });
    }
    
    public function testInvalidName() : void {
      typeInto("123456789", loginScreen.usernameTI);
      
      assertFinished(function():void {
        assertInvalid(loginScreen.usernameTI);
      });
    }
    
    public function testInvalidPassword() : void {
      typeInto("12345", loginScreen.passwordTI);
      
      assertFinished(function():void {
        assertInvalid(loginScreen.passwordTI);
      });
    }
    
    // --- Typing, clicking, waiting, intermediate assertions
    
    public function testVirginLogin() : void {
      clickOn(loginScreen.loginBtn);
      
      assertFinished(function():void {
        assertInvalid(loginScreen.passwordTI);
        assertInvalid(loginScreen.usernameTI);
      });
    }
    
    public function testLogin() : void {
      loginScreen.addEventListener("loginRequested", function(e) {
      	trace("loginRequested event occurred: " + e);
      });
    	
      typeInto("username", loginScreen.usernameTI);
      typeInto("password", loginScreen.passwordTI);
      
      assertState(function():void {
        assertValid(loginScreen.usernameTI);
        assertValid(loginScreen.passwordTI);
      });
      
      clickOn(loginScreen.loginBtn);
      
      assertState(function():void {
        assertValid(loginScreen.usernameTI);
        assertValid(loginScreen.passwordTI);
      });
      
      waitFor(loginScreen, "loginRequested");
     
      play(); 
    }
    
    public function testCancelClearsFields() : void {
      typeInto("username", loginScreen.usernameTI);
      typeInto("password", password);
      
      assertState(function():void {
        assertValid(loginScreen.usernameTI);
        assertValid(loginScreen.passwordTI);
      });
      
      clickOn(loginScreen.cancelBtn);
      
      waitUntil(allTrue(function() {
        assertEmpty(loginScreen.username);
        assertEmpty(loginScreen.password);
      }));
      
      clickOn(loginScreen.cancelBtn);
      
      play();
    }
    
    function get password() : Function
    { 
        return function() { return loginScreen.passwordTI;};
    }
    
    

  }
}
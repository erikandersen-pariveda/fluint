package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
  import flash.utils.describeType;
  
  import mx.controls.Alert;
  import mx.core.UIComponent;
  
  import net.digitalprimates.fluint.tests.ComponentTestCase;
  import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.mxml.SimpleMXMLLoginComponent;
  
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
      typeInto("username", loginScreen.usernameTI);
      typeInto("password", loginScreen.passwordTI);
      

        assertValid(loginScreen.usernameTI);
        assertValid(loginScreen.passwordTI);

      
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
      typeInto("password", loginScreen.passwordTI);
      
      assertState(function():void {
        assertValid(loginScreen.usernameTI);
        assertValid(loginScreen.passwordTI);
      });
      
      clickOn(loginScreen.cancelBtn);
      
      waitUntil(function():Boolean {
        return loginScreen.username == "" && loginScreen.password == "";
      });
      
      assertFinished(function():void {
        assertEmpty(loginScreen.usernameTI);
        assertEmpty(loginScreen.passwordTI);
      });
    }

  }
}
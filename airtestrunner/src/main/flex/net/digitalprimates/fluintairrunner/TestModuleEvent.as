package net.digitalprimates.fluintairrunner
{
   import flash.events.Event;

   public class TestModuleEvent extends Event
   {
      public static const TEST_MODULES_READY : String = "testModulesReady";
      
      public var suites : Array;
      
      public function TestModuleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         super(type, bubbles, cancelable);
      }
      
   }
}
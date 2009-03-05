package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
   import mx.rpc.AsyncToken;
   import mx.rpc.Fault;
   import mx.rpc.Responder;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   
   import net.digitalprimates.fluint.tests.TestCase;
   import net.digitalprimates.fluint.stubs.RemoteObjectStub;

   public class RemoteObjectStubTest extends TestCase
   {
      private var _stub : RemoteObjectStub;
      
      override protected function setUp() : void
      {
         _stub = new RemoteObjectStub("someDummyDestination");
      }
      
      override protected function tearDown() : void
      {
         _stub = null;
      }
      
      public function testMethodResultWithService() : void
      {
          var result : Function = 
            function (event : ResultEvent, passThroughData : *) : void
            {
               assertEquals("GOAL!", event.result);
            };
         
         _stub.result("method1", null, "GOAL!");
         _stub.addEventListener(ResultEvent.RESULT, asyncHandler(result, 2000));
         
         _stub.method1();
      }
      
      public function testMethodResultWithToken() : void
      {
         var result : Function = 
            function (event : ResultEvent) : void
            {
               assertEquals("GOAL!", event.result);
            };
         
         var fault : Function = 
            function (event : FaultEvent) : void
            {
               fail("NO FAULTS SHOULD BE THROWN DURING THIS TEST!");
            };
         
         _stub.result("method1", null, "GOAL!");
         
         var token : AsyncToken = _stub.method1();
         token.addResponder(asyncResponder(new Responder(result, fault), 2000));
      }
      
      public function testMethodFaultWithService() : void
      {
         var expected : Fault = new Fault("0", "EPOCH FAIL", "some details");
         
         var fault : Function = 
            function (event : FaultEvent, passThroughData : *) : void
            {
               assertEquals(expected, event.fault);
            };
         
         _stub.result("method1", null, expected);
         _stub.addEventListener(FaultEvent.FAULT, asyncHandler(fault, 2000));
         
         _stub.method1();
      }
      
      public function testMethodFaultWithToken() : void
      {
         var expected : Fault = new Fault("0", "EPOCH FAIL", "some details");
         
         var result : Function = 
            function (event : ResultEvent) : void
            {
               fail("NO RESULTS SHOULD BE AVAILABLE DURING THIS TEST!");
            };
         
         var fault : Function = 
            function (event : FaultEvent) : void
            {
               assertEquals(expected, event.fault);
            };
         
         _stub.result("method1", null, expected);
         
         var token : AsyncToken = _stub.method1();
         token.addResponder(asyncResponder(new Responder(result, fault), 2000));
      }
      
      public function testMethodResultWithNoParams() : void
      {
         var expected : Object = {passed: true};
         
         var result : Function =
            function (event : ResultEvent, passThroughData : * ) : void
            {
               assertEquals(expected, event.result);
            };
         
         _stub.result("emptyMethod", null, expected);
         _stub.addEventListener(ResultEvent.RESULT, asyncHandler(result, 2000));
         _stub.emptyMethod();
      }
      
      public function testMethodResultWithParams() : void
      {
         var params : Array = [{query: "some query string"}, "param2", ["blah"]];
         var expected : Object = {passed: true};
         
         var result : Function =
            function (event : ResultEvent, passThroughData : * ) : void
            {
               assertEquals(expected, event.result);
            };
         
         _stub.result("methodWithParams", params, expected);
         _stub.addEventListener(ResultEvent.RESULT, asyncHandler(result, 2000));
         _stub.methodWithParams(params);
      }
   }
}
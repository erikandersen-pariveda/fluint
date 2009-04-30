package net.digitalprimates.fluint.unitTests.frameworkSuite.testCases
{
   import mx.rpc.AsyncToken;
   import mx.rpc.Fault;
   import mx.rpc.Responder;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   
   import net.digitalprimates.fluint.tests.TestCase;
   import net.digitalprimates.fluint.stubs.HTTPServiceStub;

   public class HTTPServiceStubTest extends TestCase
   {
      private var _stub : HTTPServiceStub;
      
      override protected function setUp() : void
      {
         _stub = new HTTPServiceStub("http://someurl.com");
         _stub.delay = 500;
      }
      
      override protected function tearDown() : void
      {
         _stub = null;
      }
      
      public function testSendWithResultWithService() : void
      {
         var result : Function = 
            function (event : ResultEvent, passThroughData : *) : void
            {
               assertEquals("GOAL!", event.result);
            };
         
         _stub.result(null, "GOAL!");
         _stub.addEventListener(ResultEvent.RESULT, asyncHandler(result, 2000));
         
         _stub.send();
      }
      
      public function testSendWithResultWithToken() : void
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
         
         _stub.result(null, "GOAL!");
         
         var token : AsyncToken = _stub.send();
         token.addResponder(asyncResponder(new Responder(result, fault), 2000));
      }
      
      public function testSendWithFaultWithService() : void
      {
         var expected : Fault = new Fault("0", "EPOCH FAIL", "some details");
         
         var fault : Function = 
            function (event : FaultEvent, passThroughData : *) : void
            {
               assertEquals(expected, event.fault);
            };
         
         _stub.result(null, expected);
         _stub.addEventListener(FaultEvent.FAULT, asyncHandler(fault, 2000));
         
         _stub.send();
      }
      
      public function testSendWithFaultWithToken() : void
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
         
         _stub.result(null, expected);
         
         var token : AsyncToken = _stub.send();
         token.addResponder(asyncResponder(new Responder(result, fault), 2000));
      }
      
      public function testSetResultDataWithNullParameters() : void
      {
         var expected : Object = {passed: true};
         
         var result : Function =
            function (event : ResultEvent, passThroughData : * ) : void
            {
               assertEquals(expected, event.result);
            };
         
         _stub.result(null, expected);
         _stub.addEventListener(ResultEvent.RESULT, asyncHandler(result, 2000));
         _stub.send();
      }
      
      public function testSetResultDataWithNonNullParameters() : void
      {
         var params : Object = {query: "some query string"};
         var expected : Object = {passed: true};
         
         var result : Function =
            function (event : ResultEvent, passThroughData : * ) : void
            {
               assertEquals(expected, event.result);
            };
         
         _stub.result(params, expected);
         _stub.addEventListener(ResultEvent.RESULT, asyncHandler(result, 2000));
         _stub.send(params);
      }
   }
}
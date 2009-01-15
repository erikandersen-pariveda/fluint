package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
    import net.digitalprimates.flex2.uint.sequence.SequenceAction;
    import net.digitalprimates.flex2.uint.tests.TestCase;

    public class TestSequenceAction extends TestCase
    {
        private var functionCalled : Boolean;
        private var args : Array;
        
        private function noArgs() : void 
        {
            this.functionCalled = true;
            this.args = arguments;
        }
        
        private function oneArgument(firstName : String) : void 
        {
            this.functionCalled = true;
            this.args = arguments;
        }
        
        private function arrayArgument(people : Array) : void
        {
            this.args = arguments;
            this.functionCalled = true;
        }
        
        public function testFunctionWithNoArgs() : void 
        {
            var action : SequenceAction = new SequenceAction(noArgs, this);
            action.execute();
            
            assertTrue(functionCalled);
            assertObjectEquals(args, []);
        }
        
        public function testFunctionWithOneArg() : void 
        {
            var action : SequenceAction = new SequenceAction(oneArgument, this, ["Hello World"]);
            action.execute();
            
            assertTrue(functionCalled);
            assertObjectEquals(args, ["Hello World"]);
        }
        
        public function testFunctionWithArrayArg() : void 
        {
            var action : SequenceAction = new SequenceAction(arrayArgument, this, [[1, 2, 3]]);
            action.execute();
            
            assertTrue(functionCalled);
            assertObjectEquals(args, [[1, 2, 3]]);
        }
    }
}
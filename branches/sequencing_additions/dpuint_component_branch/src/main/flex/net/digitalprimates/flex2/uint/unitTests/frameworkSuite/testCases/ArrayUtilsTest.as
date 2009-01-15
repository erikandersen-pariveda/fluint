package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
    import mx.collections.ArrayCollection;
    import mx.utils.ArrayUtil;
    
    import net.digitalprimates.flex2.uint.tests.TestCase;
    import net.digitalprimates.flex2.uint.utils.ArrayUtils;

    public class ArrayUtilsTest extends TestCase
    {
        private var source : ArrayCollection = new ArrayCollection(
                              [{label: "Hello", data: 1},
                               {label: "Another String", data: 2},
                               {label: "Yet Another String", data: 1, age: 21}]); 
        
        
        public function testIncludesExactMatch() : void {
            var matched : Array = ArrayUtils.matchOnIncludes({label: "Hello", data: 1}, source);
            
            assertEquals(1, matched.length);
            assertObjectEquals(matched[0], {label: "Hello", data: 1});
        }
        
        public function testIncludesNoMatch() : void {
            var matched : Array = ArrayUtils.matchOnIncludes({label: "Hi There", data: 1}, source);
            assertEquals(0, matched.length);
        }
        
        public function testExclusiveIncludesNoMatch() : void {
            assertFails(function() {
                ArrayUtils.exclusiveMatchOnIncludes({label: "Hi There", data: 1}, source);    
            });
        }
        
        public function testExclusiveIncludesExactMatch() : void {
            var matched : Object = ArrayUtils.exclusiveMatchOnIncludes({label: "Hello", data: 1}, source);
            assertObjectEquals(matched, {label: "Hello", data: 1});
        }
        
        public function testIncludesMatchOnPartial() : void {
            var matched : Array = ArrayUtils.matchOnIncludes({label: "Hello"}, source);
            
            assertEquals(1, matched.length);
            assertObjectEquals(matched[0], {label: "Hello", data:1});
        }
        
        public function testIncludesMultipleMatchOnPartial() : void {
            var objects : Array = [{label: "Hello", data: 1},
                                   {label: "Another String", data: 2},
                                   {label: "Yet Another String", data: 2, age: 21},
                                   {label: "Hello", data: 4}]; 
            
            var matched : Array = ArrayUtils.matchOnIncludes({label: "Hello"}, new ArrayCollection(objects));
            
            assertObjectEquals(matched, [{label: "Hello", data:1}, {label:"Hello", data:4}]);
        }
        
        public function testMatchWithSpecifiedIncludes() : void {
            var matched : Array = ArrayUtils.matchOnIncludes({label: "Hello", data: 1, age: 21, pet: "dog"}, source, ["label", "data"]);
            
            assertEquals(1, matched.length);
            assertObjectEquals(matched[0], {label: "Hello", data: 1});       
        }
        
        public function testNoMatchWithSpecifiedIncludes(): void {
            var matched : Array = ArrayUtils.matchOnIncludes({label: "Hello", data: 1, age: 21, pet: "dog"}, source, ["label", "data", "age"]);
            
            assertEquals(0, matched.length);
        }
    }
}
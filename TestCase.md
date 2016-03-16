## Test Case ##
A TestCase is a collection of TestMethods that share a common test environment. Each TestCase has a `setUp()` and a `tearDown()` method which can be overridden to create a specific environment for your TestMethods. So, for example, if you wanted to write a series of TestMethods to test the Flex Timer class, they could all exist in a single TestCase. In the `setUp()` method you would create a Timer instance to test with. In the `tearDown()` method, you would stop that timer and remove references so it can be garbage collected. If your TestCase has two TestMethods, the fluint framework would execute the TestCase in the following way:
```
setUp();
testMethod1();
tearDown();
setUp();
testMethod2();
tearDown();
```
The `setUp()` is executed before each of your TestMethods? and the `tearDown()` is run after each TestMethod. All TestMethods in your TestCase need to begin with a lower case ‘test’, so `testTimer` and `testEvent` are valid TestMethods, but `TestOne` and `firstTest` are not. There is no formal limit on the number of methods that can be contained in a single TestCase.
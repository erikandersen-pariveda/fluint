Before diving too much further into this process, we should discuss some terminology.
In fluint, we deal with test suites, test cases and test methods. These are represented by the classes named TestSuite, TestCase and TestMethod in the fluint framework.

For our purposes:
## Test Method ##
A TestMethod is the smallest unit of the testing framework. A test method exercises code and checks an outcome.  At the end of the test method we generally make an assertion, stating that we expect the outcome to be in a specific state. We might expect a value to be true or false, null or not null, perhaps even equal to another variable. If the assertion is valid, the test passes. If the assertion does not logically work (we specify it should be false but it is really true), the test fails.

Though a single test method may setup several conditions, exercise several pieces of code, or even wait for an asynchronous event, it should ultimately make only a single assertion. This is a point of contention and many disagree, but a single assertion per method ensures the best granularity in resolving test failures, among other benefits.

When using Fluint, your tests must either begin with the letters 'test', for example:

```
public function testMe():void {}
public function testYou():void {}
```

are both valid names for test methods or your methods can be decorated by a piece of [Test](Test.md) metadata. For example:
```
[Test]
public function fails2():void {}
```

The first method allows a very simple way to quickly create tests. The second method allows you to control your tests in more granular detail and provide additional information about why they exist. For example:

```
[Test(description="Test is supposed to Fail",issueID="0012443")]
public function fails2():void {}
```

The [Test](Test.md) metadata allows you to embed descriptions of the test as well as other useful information for reporting, such as the issueID or bug number that this test addresses. Fluint does not dictate what information can be present in the test metadata. It simply preserves all attributes that you specify within the Test metadata tag.

## Test Case ##
A TestCase is a collection of [TestMethods](TestMethod.md) that share a common test environment. Each TestCase has a `setUp()` and `tearDown()` method which can be overridden to create a specific environment for your [TestMethods](TestMethod.md). So, for example, if you wanted to write a series of [TestMethods](TestMethod.md) to test the Flex Timer class, they could all exist in a single TestCase. In the `setUp()` method you would create a Timer instance to test with. In the `tearDown()` method, you would stop that timer and remove references so it can be garbage collected. If your TestCase has two [TestMethods](TestMethod.md), the fluint framework would execute the TestCase in the following way:
```
setUp();
testMethod1();
tearDown();
setUp();
testMethod2();
tearDown();
```
The `setUp()` method is executed before each of your [TestMethods](TestMethod.md) and the `tearDown()` method is run after each TestMethod. All [TestMethods](TestMethod.md) in your TestCase need to begin with a lower case ‘test’, so `testTimer` and `testEvent` are valid [TestMethods](TestMethod.md), but `TestOne` and `oneTest` are not. There is no formal limit on the number of methods that can be contained in a single TestCase.

## Test Suite ##
Finally, a TestSuite is a collection of [TestCases](TestCase.md). Fluint itself has a FrameworkSuite which contains [TestCases](TestCase.md) pertaining to different aspects of the library, such as asynchronous tests or UIComponent tests. Each of those [TestCases](TestCase.md) then contains [TestMethods](TestMethod.md) which share a common setup to be executed.


[Previous](GettingStarted.md) | [Next](TestRunners.md)
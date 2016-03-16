## The Basics ##
Your tests need to act independently of each other, so the point of ordering your tests in a custom way is not to ensure that test A sets up some state that test B needs. If this is the reason you are reading this section, please reconsider. Tests need to be independent of each other and generally independent of order.

Why then would we include the capability to manipulate order? Well, because there are other valid reasons to do so. If you have many tests of increasing complexity, it makes sense to order these so that, in the event a simple test fails, you don’t waste time running the more complicated versions.

You may also have hundreds of test methods in your TestCase or hundreds of TestCases and you wish to decide when to run these in a way that we have not even begun to consider.

This framework provides the ability to manipulate both the order and selection criteria for tests on each level (Suite, TestCase, Method) using standard Flex filter functions and sorts.

## Sorting ##
The TestRunner, TestSuite and TestCase classes all have a public property called `sorter` which can be set to an instance of the Flex framework Sort class. You can define different sort criteria for each individual TestCase in the system, or choose to have them all sort the same way.

The default sorters choose an alphabetical approach; however, this is likely to change in the future, so please do not rely on this feature when naming your tests.

## Filtering ##
The TestRunner, TestSuite and TestCase classes all also have a public property named `filter` which can be set to any function that uses the following signature:
```
        f(item:Object):Boolean
```

If the function returns true, the relevant item is kept. If it returns false, the item will not be counted in the testing. The TestRunner and TestSuite filter functions currently always return true. The TestCase filter function returns true for any method that begins with the letters ‘test’ or that is immediately proceeded by the [Test](Test.md) metadata.

If you do not wish to provide a filter function, or wish to manipulate this filtering through inheritance, the `defaultFilterFunction` is also defined in each of these classes in the following method:
```
        protected function defaultFilterFunction( item:Object ):Boolean;
```

This method can be overridden in a subclass to manipulate the filtering instead of providing a new filter.

## Why ##
Using these features you can actually make a very dynamic test environment where tests are removed or added based on other factors and features. I am not sure you want to, but we simply provided the interface to maximize potential damage.


[Previous](Cairngorm.md) [Next](ContinuousIntegration.md)
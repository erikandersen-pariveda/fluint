## Flex Test Runner ##
Before we proceed, we need a way to run tests. If you are running your tests on your development machine, you may want a user interface that reports errors and failures visually. If the tests are running on a server in an automated build environment, the user interface may not matter and an XML style output may be significantly more helpful.

Fluint does not prescribe a user interface, but rather provides a series of components which can be used together in either a Flex or AIR project to provide as much of a user interface as required. Further, there are AIR specific components which can be used for advanced features such as automated test running on file change or XML file output compatible with automated build systems.

There is a very simple SampleTestRunner available for download with this project. This sample test runner uses several of these components to create a tree-based test browser and a visual progress bar which can be clicked to dive down for further information on a test success or failure.

If you have downloaded the source code available with this project, the sample test runner is found in `samples/src/test/flex/FlexTestRunner.mxml`.

If you are using this project as a library:
  1. Create a new Flex project;
  1. Copy the `FlexTestRunner.mxml` file into that project;
  1. Be sure the fluint.swc from the downloads tab is in the libs folder of the project
  1. Build your Flex project.

This sample test runner runs the tests created for the framework out of the library project. Other pages in this Wiki will explain how to create your own tests.

## AIR Test Runner ##

If you have downloaded the source code available with this project, the AIR sample test runner is found in `samples/src/test/flex/AirTestModule.mxml`.

The AIR test runner is targeted for the desktop as opposed to the web browser. The advantage of using this test runner is that you can write the results to an XML file wherever you might like on your drive. This is very useful when running in an automated build environment.

Unlike the FlexTestRunner discussed above, the AIR test runner loads its tests dynamically via Flex modules. Your tests are created in independent modules and built into SWF files. The AIR test runner then loads the tests from those modules and executes them.

More information on this concept is available in the automated build system section of the Wiki.

[Previous](Terminology.md) | [Next](BasicTest.md)
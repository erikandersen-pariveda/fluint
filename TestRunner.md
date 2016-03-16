## Test Runner ##
Finally, we need a way to run tests. If you are running your tests on your development machine, you may want a user interface that reports errors and failures visually. If the tests are running on a server in an automated build environment, the user interface may not matter and an XML style output may be significantly more helpful.

Fluint does not prescribe a user interface, but rather provides a series of components which can be used together in either a Flex or AIR project to provide as much of a user interface as required. Further, there are AIR specific components which can be used for advanced features such as automated test running on file change or XML file output compatible with automated build systems.

There is a very simple SampleTestRunner available for download with this project. This sample test runner uses several of these components to create a tree based test browser and a visual progress bar which can be clicked to dive down for further information on a test success or failure.

To use this sample test runner, you need to follow the following steps:
  1. Create a new Flex or AIR project
  1. Copy the `FlexTestRunner.mxml` from `samples/src/test/flex` into that project
  1. Go to the project’s properties, and then the Flex Build Path option
  1. Click on the Library Path tab
  1. Click the Add Project Button
  1. Choose the library project you created with the download code
  1. Build your flex project.

This sample test runner runs the tests created for the framework our of the library project. Other pages in this wiki will explain how to create your own tests.
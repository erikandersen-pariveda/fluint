# Introduction #

To execute a suite of tests using fluint via a continuous integration build, it is recommended that the fluint AIR runner is used. Currently, an Ant wrapper for the tool is available; Maven support is being worked on for the flex-mojos plugin, but as of this publishing, is not available.

# Tools #

## AIR Runner Command Line ##

If the current Ant wrapper is not sufficient for your build's needs or you are not using Ant, the AIR runner can be called via the command-line by using the arguments below.  Each argument should be prefixed with a single dash.  For example:

```
./FluintAIRRunner -headless -failOnError -reportDir='/project/target/reports' -fileSet='/project/target/test-classes/AIRRunner.swf'
```

Arguments:

  * headless - Optional - Execute the runner minimized and have it close after it has completed its run.
  * failOnError - Optional - Cause the runner to exit with an error code of 1, for failure, rather than 0, for success.
  * reportDir - Required - Default: 'app-storage:/' - Absolute/relative path to the directory in which the test result report file, named `TEST-AllTests.xml`, will be written. Argument should be wrapped in single quotes.
  * fileSet - Required - Comma-delimited list of absolute/relative paths to SWF files, or directories containing SWF files, which are modules implementing the `ITestSuiteModule` interface. Argument should be wrapped in single quotes.

**NOTE:** All relative paths are taken from the directory in which the FluintAIRTestRunner application is executed.

## fluint Ant Task ##

For more information on the Ant wrapper for the fluint AIR runner, see [AntTasks](AntTasks.md).

# Considerations #

Although fluint provides facilities to interop with the continuous integration process, there a few considerations that should be taken into account for fluint's solution:

  * If the AIR runner immediately exits upon execution when the `headless` argument is provided, check the paths passed in the `fileSet` argument.  This behavior is indicative that the AIR runner cannot find module SWFs to load which contain test suites written for fluint.

  * The exit codes used by the AIR runner may have different meaning based on the OS in which the runner is executed.  The Ant wrapper assumes 0 for success and 1 for failure.  Currently, these are the only exit codes supported, so it is recommended that any build script calling the AIR runner directly, write custom handlers for these exit codes.

  * In an effort to support tests written for the Flex SDK as well as the AIR SDK extensions, the test runner provided for the CI process by fluint is written in AIR. Consequently, there a some classes in the SDK which may cause failed tests because they are not supported in AIR.  Below is a list of known classes which may result in failures/errors in your tests:

> `ExternalInterface`

  * AIR has the behavior of running a single instance for each application, rather than spawning a new instance per invocation, regardless of the mechanism used to launch the application. Consequently, more than one simultaneous request to invoke the AIR runner will result in each request being executed but the runner closing after the first request to execute has completed.  The test result report for the first execution should be generated correctly however.  This being said, it is suggested that any CI server using the runner be configured to execute all Flex builds sequentially.  We realize this is a huge disadvantage when it comes to running numerous builds concurrently, and are currently working on a better solution.

[Previous](Order.md)
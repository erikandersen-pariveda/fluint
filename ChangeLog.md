# 1.1.1 #

  * [Issue #34](https://code.google.com/p/fluint/issues/detail?id=#34) - Assets are not located in net/digitalprimates/fluint folder
  * [Issue #35](https://code.google.com/p/fluint/issues/detail?id=#35) - Can't find `TestResponder`
  * [Issue #37](https://code.google.com/p/fluint/issues/detail?id=#37) - Air Test Runner needs better error handling
  * Added new target to ant build for building the airtestrunner as an .airi file (target => "airtestrunner-intermediary")
  * Added flex builder metadata files to the samples project

# 1.1.0 #

## fluint Library ##
  * Separated the notion of failures and errors
  * Updated the XML output to be compatible with reporting tasks/plugins in Ant and Maven as well as most continuous integration servers
  * Added icons to the tree in the visual test runner to look more familiar
  * Added Ant build script

## fluint AIR Test Runner ##
  * Added support for relative paths
  * Added better error handling for modules which cannot be executed as ITestSuiteModule
  * Added return codes on exit for better integration with Ant
  * Integrated [LogBook](http://code.google.com/p/cimlogbook/) for debugging on channel `_fluint`
  * Added Ant build script

## fluint Ant Tasks ##
  * Added support for the attributes failonerror and workingDir to support build failure and relative paths
  * Added support to run the AIR Test Runner truly headless via the xvfb attribute on Linux-based OSes with X-Windows installed
  * Added Ant build script

# 1.0.0 #

  * Initial import of libary, airtestrunner, and anttasks
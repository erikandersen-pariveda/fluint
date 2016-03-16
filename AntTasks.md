## Introduction ##
The combination of the AIRTestRunner and the provided Ant Tasks are a powerful way to use Fluint with an automated build system. If you have not yet done so, be sure to synchronize the source for these projects.

The full source for both the AIRTestRunner and the ANT Tasks are available in the directory repository.

However, should you prefer, both of these items are also available as a JAR and AIR file respectively from the downloads page.

## Requirements: ##
  * The [FluintAIRTestRunner](http://code.google.com/p/fluint/downloads/list) application.
  * [Ant](http://ant.apache.org/) 1.7.x or later.

## How to use the fluint Ant task : `<fluint>` ##

Place `FluintAnt.jar` in your system class path, or Ant `/lib` directory, so Ant can make it available.  At runtime you can import it into the Ant script by using the `<path>` directive, if copied to a non-classpath folder:

```
<path id="libraries">
   <fileset dir="PATH_TO_DIR_WHERE_THE_FLUINT_JAR_WAS_COPIED">
      <include name="**/*.jar"/>
   </fileset>
</path>
```

Import and define the fluint Ant tag in your build script with the classname `net.digitalprimates.ant.tasks.fluint.Fluint` (the `classpathref` attribute is optional if the `FluintAnt.jar` file was already available on the classpath).

```
<taskdef name="fluint"
   classname="net.digitalprimates.ant.tasks.fluint.Fluint"
   classpathref="libraries" />
```

Now that the Ant task has been defined in your build file you can call it like so:
```
<fluint
   debug="true"
   headless="true"
   failonerror="false"
   workingDir="PATH_TO_LAUNCH_FLUINT_AIRTESTRUNNER_WITHIN"
   testRunner="PATH_TO_FLUINT_AIRTESTRUNNER_EXECUTABLE"
   outputDir="PATH_TO_REPORTING_DIR">

   <fileset dir="C:\temp\test">
      <include name="**/*.swf"/>
   </fileset>
</fluint>
```

The attributes of the `<fluint>` task are listed below:

  * debug="true|false" - Default: **false**. Return debug information to the console

  * headless="true|false" - Default: **false**. To run the AIR application in a headless (no UI) mode, or to launch and run the AIR application as a full application.

**Note:** this does not mean this can be launched from a truly headless server. Fluint will still instantiate visual objects, just not waste the time showing you a tree and progress bar. Further, the application will close immediately upon completion of the tests.

  * xvfb="true|false" - Default: **false**.  Launches the executable provided in the _testRunner_ property using the `xvfb-run` command available in X Windows under Linux for true headless execution of the AIR application.  This property will only work when used in conjunction with **headless="true"**. The resulting call is structured as below:
```
xvfb-run -a <path_to_test_runner> <arguments_to_test_runner>
```

  * failonerror="true|false" - Default: **true**. Causes the Ant build to fail if the Test Suite(s) executed contain failures or errors.

  * testRunner="" - The path to your installed copy of the fluint AIRTestRunner executable (i.e. - `/Applications/FluintAIRTestRunner/Contents/MacOS/FluintAIRTestRunner` or `C:\Program Files\FluintAIRTestRunner\FluintAIRTestRunner.exe`).

  * workingDir="" - Default: **Ant script's `basedir` property**. Directory from which the Fluint AIR runner should be executed and all relative paths for `outputDir` and `fileset` will be based.

  * outputDir="" - The location where the test runner should write the test results. A file named fluintResults.xml will be created by default that contains the results of the latest testing session.

  * fileset - A fileset of all .swf files to load for testing (compiled as `mx:Modules` implementing `ITestSuiteModule`).

**Note:** If you provide directories as opposed to files for the fileset option, the AIR testrunner will recurse those directories looking for `.swf` files to load as modules.

# Sample Test Module #

The following source shows a sample module which will run the framework test suite:

```
<?xml version="1.0" encoding="utf-8"?>
<mx:Module xmlns:mx="http://www.adobe.com/2006/mxml" implements="net.digitalprimates.fluint.modules.ITestSuiteModule">
   <mx:Script>
   <![CDATA[
      import net.digitalprimates.fluint.unitTests.frameworkSuite.FrameworkSuite;
      
      public function getTestSuites() : Array 
      {
         var suiteArray : Array = new Array();
         suiteArray.push(new FrameworkSuite());
         return suiteArray;
      }
   ]]>
   </mx:Script>
</mx:Module>
```

The module must implement the `net.digitalprimates.fluint.modules.ITestSuiteModule` interface, which simply requires that it has a `getTestSuites()` method which returns an
array of `TestSuite` instances.

A sample of this code can be found under `tags/release-1.1.0` in the [Source](http://code.google.com/p/fluint/source/browse/) tab at `samples/src/test/flex/AirTestModule.mxml`.
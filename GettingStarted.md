## Installing the Library Project using the SWC ##
If you prefer, you can download the SWC library version from the [downloads](http://code.google.com/p/fluint/downloads/list) page.

### If you are using Flex 3: ###
Create a new Flex project and copy the `fluint.swc` file into the libs folder of that Flex project.

### If you are using Flex 2: ###
Create a new Flex project. Create a folder named libs in that project and copy the `fluint.swc` file into the new folder.

Next, you will need to add this folder to your build path. Do this by:

  * Project properties->Flex Build Path.
  * Click the Library Path Tab.
  * Click the Add SWC Folder button.
  * Browse to the libs folder and click OK.
  * Click OK on the properties panel to close it.

This new Flex project, created with either the source code or the SWC library, will hold your tests and your test runner.

## Installing the Library Project using the Source files ##
Fluint is a combation of projects. Clicking on the [Source](http://code.google.com/p/fluint/source/checkout) tab above will provide directions for synchronizing directly with the SVN repository.  If you'd like to ensure continual access to the latest version of fluint, check out the `trunk`, otherwise use the latest release under `tags`.

Checking out `/tags/release-1.1.1` of the repository will checkout all of the projects associated with the latest stable version of fluint.  Each of the projects is described below:

  * `fluint` - Library project used to build fluint.swc
  * `airtestrunner` - AIR project designed to run tests via the command line as well as an automated build environment.
  * `anttasks` - Apache Ant tasks that facilitate the running of the `airtesrunner`
  * `samples` - Sample Flex project with an example test runners for Flex and AIR.  More samples will follow containing the examples from this wiki.

Once you've obtained the source code, you can build it in one of two possible ways:

  1. Import all projects into Flex Builder
    1. Click File -> Import -> Other
    1. Under the General section choose the "Existing Projects into Workspace" option.
    1. Under "Select root directory:" browse to the location containing the working copy of the `trunk` and click "Choose".
    1. Click "Finish" and all the above projects should now be available in Flex Builder and be linked together.
  1. Run the Ant build
    1. If you have Apache Ant 1.7 or greater installed, open a command prompt and change directory to your working copy of the `trunk`.
    1. Edit the `build.xml` file such that the `<property>` tags under the "User defined properties" section are correct for your system.  At a minimum if you are only build the fluint library, you will only need the `flex.home` property.
    1. To build all of the project, type `ant`.  To build only the fluint library, type `ant fluint`.  To build only the airtestrunner, type `ant airtestrunner`.  To build only the Ant tasks, type `ant anttasks`.
    1. If you chose to build all of the projects, you should see `fluint.zip` in your current directory which contains all of the artifacts from the above projects as well as their documentation.  Otherwise, you should be able to find the desired artifact under the `target` folder for the respective project that you built.

**NOTE:** The Ant build is useful, if you require a special build of fluint that is not provided in the Downloads section.

[Previous](Introduction.md) | [Next](Terminology.md)
## What it's all about? ##

Fluint (named dpUInt during its pre-release stage) was created by [Digital Primates](http://www.digitalprimates.net) to push testing with Flex and ActionScript past basic unit testing and into the world of integration testing. It provides full support for unit testing in the tradition of [FlexUnit](http://code.google.com/p/as3flexunitlib/), but goes further with richer asynchronous support and support for integration-level testing.

## Why not just use FlexUnit? ##
[FlexUnit](http://code.google.com/p/as3flexunitlib/) is an excellent tool for creating unit tests for Flex, but its support for asynchronous testing was too limited to handle the level of integration we desired. Our goal was to test instances of UIComponent subclasses which, in Flex, are almost all asynchronous internally. By default, FlexUnit doesn’t have support for asynchronous setup or teardown nor the ability to pend on multiple asynchronous events.

## Is this an extension of FlexUnit? ##
Initially, we tried to extend FlexUnit to accomplish our goals, but ultimately decided that the approach FlexUnit was built upon was just too different than our goal. We therefore rebuilt the unit testing portion to couple more appropriately with our vision of the next level. We still have many projects on FlexUnit and think it is a great tool, but we hope to gather some community input and opinions and, hopefully, position fluint as the way to accomplish integration testing with Flex.


Take a look at the following pages to learn more about this project:

  * [Getting Started](GettingStarted.md)
  * [Terminology](Terminology.md)
  * [The Test Runners](TestRunners.md)
  * [Writing a Basic Test](BasicTest.md)
  * [Writing an Asynchronous Test](AsyncTest.md)
  * [Using Asynchronous Startup](AsyncSetup.md)
  * [Testing with Sequences](Sequences.md)
  * [Testing with Cairngorm](Cairngorm.md)
  * [Controlling the Order and Selection of Tests](Order.md)
  * [Build Automation and Continuous Integration](ContinuousIntegration.md)

And then... The project still needs a lot of additional documentation as this just scratches the surface of testing. Our intent is to help maintain this project and site but also to gain community involvement to flesh out the edges and propose features that will make this a great way to test. So, please, get the source and start playing.
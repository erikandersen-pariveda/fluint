package org.flexunit.runners.model {
	import org.flexunit.runner.IRunner;
	
	/**
	 * An IRunnerBuilder is a strategy for constructing IRunners for classes. 
	 * 
	 * Only writers of custom runners should use <code>IRunnerBuilder</code>s.  A custom runner class with a constructor taking
	 * an <code>IRunnerBuilder</code> parameter will be passed the instance of <code>IRunnerBuilder</code> used to build that runner itself.  
	 * For example,
	 * imagine a custom IRunner that builds suites based on a list of classes in a text file:
	 * 
	 * <pre>
	 * \@RunWith(TextFileSuite.class)
	 * \@SuiteSpecFile("mysuite.txt")
	 * class MySuite {}
	 * </pre>
	 * 
	 * The implementation of TextFileSuite might include:
	 * 
	 * <pre>
	 * public TextFileSuite(Class testClass, IRunnerBuilder builder) {
	 *   // ...
	 *   for (String className : readClassNames())
	 *     addRunner(builder.runnerForClass(Class.forName(className)));
	 *   // ...
	 * }
	 * </pre>
	 * 
	 * @see org.flexunit.runners.Suite
	 */
	public interface IRunnerBuilder {
		function safeRunnerForClass( testClass:Class ):IRunner;
		function runners( parent:Class, children:Array ):Array;
		function runnerForClass( testClass:Class ):IRunner;
	}
}
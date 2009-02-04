package net.digitalprimates.fluint.tests
{
	import flash.utils.Dictionary;
	
	public class TestWrapperLocator {

		private var d:Dictionary = new Dictionary( true );

		public function registerRunnerForTest( test:Object, runner:ITestCaseRunner ):void {
			d[ test ] = runner;
		}	
		
		public function getRunnerForTest( test:Object ):ITestCaseRunner {
			return d[ test ] as ITestCaseRunner;
		} 	

		private static var instance:TestWrapperLocator;

		/**
		 * Returns the single instance of the class. This is a singleton class. 
		 */		
		public static function getInstance():TestWrapperLocator {
			if ( !instance ) {
				instance = new TestWrapperLocator();
			}

			return instance;
		}
	}
}
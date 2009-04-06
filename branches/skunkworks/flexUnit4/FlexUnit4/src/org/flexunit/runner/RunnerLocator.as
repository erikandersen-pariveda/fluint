package org.flexunit.runner
{
	import flash.utils.Dictionary;
	
	public class RunnerLocator {

		private var d:Dictionary = new Dictionary( true );

		public function registerRunnerForTest( test:Object, runner:IRunner ):void {
			d[ test ] = runner;
		}	
		
		public function getRunnerForTest( test:Object ):IRunner {
			return d[ test ] as IRunner;
		} 	

		private static var instance:RunnerLocator;

		/**
		 * Returns the single instance of the class. This is a singleton class. 
		 */		
		public static function getInstance():RunnerLocator {
			if ( !instance ) {
				instance = new RunnerLocator();
			}

			return instance;
		}
	}
}
package org.flexunit.runners {
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import org.flexunit.runner.Description;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runner.notification.RunNotifier;
	import org.flexunit.runners.model.IRunnerBuilder;
	import org.flexunit.token.AsyncTestToken;
	
//TODO: How do references to older JUnits compare to older FlexUnits?	
	/**
 	* Using <code>Suite</code> as a runner allows you to manually
 	* build a suite containing tests from many classes. It is the JUnit 4 equivalent of the JUnit 3.8.x
 	* static {@link junit.framework.Test} <code>suite()</code> method. To use it, annotate a class
 	* with <code>@RunWith(Suite.class)</code> and <code>@SuiteClasses(TestClass1.class, ...)</code>.
 	* When you run this class, it will run all the tests in all the suite classes.
 	*/
	public class Suite extends ParentRunner {
		private var _runners:Array;
			
		override protected function get children():Array {
			return _runners;
		}

		override protected function describeChild( child:* ):Description {
			return IRunner( child ).description;
		}

		override protected function runChild( child:*, notifier:RunNotifier, childRunnerToken:AsyncTestToken ):void {
			IRunner( child ).run( notifier, childRunnerToken );
		}


		private static function getSuiteClasses( suite:Class ):Array {
			var typeInfo:XML = describeType( suite );
			var factory:XML = typeInfo.factory[ 0 ];

			var variables:XMLList = factory.variable;
			var className:String;
			var classRef:Class;

			var classArray:Array = new Array();

			for ( var i:int=0; i<variables.length(); i++ ) {
				try {
					className = variables[ i ].@type;
					classRef = getDefinitionByName( className ) as Class;
					classArray.push( classRef ); 
				} catch ( e:Error ) {
					//Not sure who we should inform here yet. We will need someway of capturing the idea that this
					//is a missing class, but not sure where or how to promote that up the chain....if it is even possible
					//that we could have a missing class, given the way we are linking it
				}
			}
			
			
			/***
			  <variable name="two" type="suite.cases::TestTwo"/>
			  <variable name="one" type="suite.cases::TestOne"/>

  			SuiteClasses annotation= klass.getAnnotation(SuiteClasses.class);
			if (annotation == null)
				throw new InitializationError(String.format("class '%s' must have a SuiteClasses annotation", klass.getName()));
			return annotation.value();
			 **/
			 //this needs to return the suiteclasses
			 return classArray;
		}

		/** This will either be passed a builder, followed by an array of classes... (when there is not root class)
		 *  Or it will be passed a root class and a builder.
		 * 
		 * So, the two signatures we are supporting are:
		 * 
		 * Suite( builder:IRunnerBuilder, classes:Array )
		 * Suite( testClass:Class, builder:IRunnerBuilder )
		 ***/ 
		public function Suite( arg1:*, arg2:* ) {
			var builder:IRunnerBuilder;
			var testClass:Class;
			var classArray:Array;
			var runnners:Array;
			var error:Boolean = false;
			
			if ( arg1 is IRunnerBuilder && arg2 is Array ) {
				builder = arg1 as IRunnerBuilder;
				classArray = arg2 as Array;
			} else if ( arg1 is Class && arg2 is IRunnerBuilder ) {
				testClass = arg1 as Class;
				builder = arg2 as IRunnerBuilder;
				classArray = getSuiteClasses(testClass);
			} else {
				error = true;
			}

			super( testClass );
			
			if ( !error ) {
				_runners = builder.runners( testClass, classArray );
			} else {
				throw new Error("Incorrectly formed arguments passed to suite class");
			}
		}
	}
}
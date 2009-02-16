package net.digitalprimates.fluint.utils {
	import flash.utils.*;

	public class TestClassInformation {
		private var record:XML;
		private var isTypeClass:Boolean; 
		private var runnerTypeCode:String;
		private var factoryName:String;
		
		public static var FLUINT1:String = "Fluint1";
		public static var FLEXUNIT1:String = "FlexUnit1";
		public static var FLEXUNIT4:String = "FlexUnit4";
		public static var EXTERNAL:String = "External";

		public function get isClass():Boolean {
			return isTypeClass;
		}
		
		public function get isInstance():Boolean {
			return !isTypeClass;
		}
		
		public function get runnerType():String {
			return runnerTypeCode;
		}

		public function get externalFactoryName():String {
			return factoryName;
		}
		
		private function deriveRunnerTypeCode():void {
			var code:String;

			factoryName = MetaDataInformation.getArgValueFromDescription( record, "TestRunnerFactory", "factory" );
			
			if ( !factoryName ) {
				//If the user didn't specify the runner key, check the default key
				factoryName = MetaDataInformation.getArgValueFromDescription( record, "TestRunnerFactory", "" );
			}
			
			if ( factoryName ) {
				runnerTypeCode = EXTERNAL
				return;
			}
			
			/** If we don't have metaData, then we will look at the class which our test case extends
			 *  If we can figure out that it was an older FlexUnit of Fluint test then we will use that
			 *  testRunner. If, however, we don't have metaData or a known superclass, then we assume
			 *  that this one is a FlexUnit4 test based entirely on metaData markup
			 **/

			if ( MetaDataInformation.classImplements( record, "flexunit.framework::Test" ) ) {
				//this is an original flexUnitTest
				code = FLEXUNIT1;
			} else if ( MetaDataInformation.classExtends( record, "net.digitalprimates.fluint.tests::TestCase" ) ) {
				code = FLUINT1;
			} else if ( MetaDataInformation.classExtends( record, "net.digitalprimates.fluint.tests::TestSuite" ) ) {
				code = FLUINT1;
			} else {
				code = FLEXUNIT4;
			}
			
			runnerTypeCode = code;
		}

		public function TestClassInformation( suiteOrCase:* ) {
			//I would much prefer to use the DescribeTypeCachehere, but you need to be careful
			//It caches the first look it gets at the class, so if I pass TestAssert as one case and (new TestAssert() ) as the next
			//the record I get both time is the same... this can lead to erroneous assumptions in the code below
			record = describeType( suiteOrCase );
			isTypeClass = MetaDataInformation.isClass( record ); 
			
			deriveRunnerTypeCode();
		}
	}
}
package org.flexunit.internals.runners {
	import flash.events.EventDispatcher;
	
	import flexunit.framework.Test;
	import flexunit.framework.TestCase;
	import flexunit.framework.TestListener;
	import flexunit.framework.TestResult;
	import flexunit.framework.TestSuite;
	
	import org.flexunit.runner.Description;
	import org.flexunit.runner.IDescribable;
	import org.flexunit.runner.IRunner;
	import org.flexunit.runner.manipulation.Filter;
	import org.flexunit.runner.manipulation.IFilterable;
	import org.flexunit.runner.notification.RunNotifier;
	import org.flexunit.token.AsyncTestToken;

	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	
	public class FlexUnit38ClassRunner extends EventDispatcher implements IRunner, IFilterable {

		private var test:Test;
		
		public function FlexUnit38ClassRunner( klassOrTest:* ) {
			
			super();

			if ( klassOrTest is Test ) {
				this.test = new TestSuite( klassOrTest );
				//in this case, we need to make a suite
			} else {
				this.test = test;
			}
		}

		public static function getClassFromTest( test:Test ):Class {
			var name:String = getQualifiedClassName( test );
			return getDefinitionByName( name ) as Class;		
		}

		public function run( notifier:RunNotifier, previousToken:AsyncTestToken ):void {
			var result:TestResult = new TestResult();
			result.addListener(createAdaptingListener(notifier));
			test.runWithResult(result);
			trace("All Done");
		}
	
		public static function createAdaptingListener( notifier:RunNotifier ):TestListener {
			return new OldTestClassAdaptingListener(notifier);
		}
		
		public function get description():Description {
			return makeDescription( test );
		}
	
		private function makeDescription( test:Test ):Description {
			if ( test is TestCase ) {
				var tc:TestCase = TestCase( test );
				//return null;
				return Description.createTestDescription(getClassFromTest( tc ), tc.className );
			} else if ( test is TestSuite ) {
				var ts:TestSuite = TestSuite( test );
				var name:String = ts.className == null ? "" : ts.className;
				var description:Description = Description.createSuiteDescription(name);
				var n:int = ts.testCount();
				var tests:Array = ts.getTests();
				for ( var i:int = 0; i < n; i++)
					description.addChild( makeDescription( tests[i] ));
				return description;
			} else if (test is IDescribable) {
				var adapter:IDescribable = IDescribable( test );
				return adapter.description;
//// not currently supporting this as the old flex unit didn't have it
/* 			} else if (test is TestDecorator) {
				TestDecorator decorator= (TestDecorator) test;
				return makeDescription(decorator.getTest());
 */			} else {
				// This is the best we can do in this case
				return Description.createSuiteDescription( test.className );
			}
		}
	
		public function filter( filter:Filter ):void {
			if ( test is IFilterable ) {
				var adapter:IFilterable = IFilterable( test );
				adapter.filter(filter);
			}
		}
	
/* 		public void sort(Sorter sorter) {
			if (fTest instanceof Sortable) {
				Sortable adapter= (Sortable) fTest;
				adapter.sort(sorter);
			}
		}		
 */	}
}
import flexunit.framework.TestListener;
import org.flexunit.runner.notification.RunNotifier;
import flexunit.framework.Test;
import org.flexunit.runner.Description;
import org.flexunit.runner.notification.Failure;
import flexunit.framework.TestCase;
import org.flexunit.runner.IDescribable;
import flexunit.framework.AssertionFailedError;
import org.flexunit.internals.runners.FlexUnit38ClassRunner;	

class OldTestClassAdaptingListener implements TestListener {
	private var notifier:RunNotifier;

	public function OldTestClassAdaptingListener( notifier:RunNotifier ) {
		this.notifier = notifier;
	}

	public function endTest( test:Test ):void {
		notifier.fireTestFinished(asDescription(test));
	}

	public function startTest( test:Test ):void {
		notifier.fireTestStarted(asDescription(test));
	}

	// Implement junit.framework.TestListener
	public function addError( test:Test, error:Error ):void {
		var failure:Failure = new Failure(asDescription(test), error );
		notifier.fireTestFailure(failure);
	}

	private function asDescription( test:Test ):Description {
		if (test is IDescribable) {
			var facade:IDescribable = test as IDescribable;
			return facade.description;
		}

		return Description.createTestDescription( FlexUnit38ClassRunner.getClassFromTest( test ), getName(test));
	}



	private function getName( test:Test ):String {
		if ( test is TestCase )
			return TestCase( test ).methodName;
		else
			return test.toString();
	}

	public function addFailure( test : Test, error : AssertionFailedError ) : void {
		addError( test, error );
	}
}
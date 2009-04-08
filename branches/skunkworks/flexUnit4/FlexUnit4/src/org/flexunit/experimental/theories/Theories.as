package org.flexunit.experimental.theories {
	import flex.lang.reflect.Field;
	import flex.lang.reflect.Klass;
	
	import org.flexunit.experimental.runners.statements.TheoryAnchor;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.runners.BlockFlexUnit4ClassRunner;
	import org.flexunit.runners.model.FrameworkMethod;
	
	public class Theories extends BlockFlexUnit4ClassRunner {
		public function Theories( klass:Class ) {
			super( klass );
		}

		override protected function collectInitializationErrors( errors:Array ):void {
			super.collectInitializationErrors(errors);
	
			validateDataPointFields(errors);
		}

		private function validateDataPointFields( errors:Array ):void {
			var klassInfo:Klass = new Klass( testClass.asClass );

			for ( var i:int=0; i<klassInfo.fields.length; i++ ) {
				if ( !( klassInfo.fields[ i ] as Field ).isStatic ) {
					errors.push( new Error("DataPoint field " + ( klassInfo.fields[ i ] as Field ).name + " must be static") );
				}
			}
		}
		
		override protected function validateTestMethods( errors:Array ):void {
			var method:FrameworkMethod;
			var methods:Array = computeTestMethods();

			for ( var i:int=0; i<methods.length; i++ ) {
				method = methods[ i ];
				method.validatePublicVoid( false, errors );
			}
		}
		
		private function removeFromArray( array:Array, removeElements:Array ):void {
			for ( var i:int=0; i<array.length; i++ ) {
				for ( var j:int=0; j<removeElements.length; j++ ) {
					if ( array[ i ] == removeElements[ j ] ) {
						array.splice( i, 1 );
					}
				}
			}
		}
	
		override protected function computeTestMethods():Array {
			var testMethods:Array = super.computeTestMethods();
			var theoryMethods:Array = testClass.getMetaDataMethods( "Theory" );
			
			removeFromArray( testMethods, theoryMethods );
			testMethods = testMethods.concat( theoryMethods );

			return testMethods;
		}

		override protected function methodBlock( method:FrameworkMethod ):IAsyncStatement {
			return new TheoryAnchor( method, testClass );
		}
	}
}
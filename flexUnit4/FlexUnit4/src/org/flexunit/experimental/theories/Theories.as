package org.flexunit.experimental.theories {
	import flash.utils.describeType;
	
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
			var typeInfo:XML = describeType( this.testClass.asClass );
			var factory:XML = typeInfo.factory[ 0 ];

			var instanceVariables:XMLList = factory.variable;

			var className:String;
			var classRef:Class;

			var classArray:Array = new Array();

			for ( var i:int=0; i<instanceVariables.length(); i++ ) {
				className = instanceVariables[ i ].@type;
				errors.push( new Error("DataPoint field " + className + " must be static") );
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
			return new TheoryAnchor(method);
		}
	}
}
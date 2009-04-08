package org.flexunit.experimental.theories.internals {
	import flex.lang.reflect.Constructor;
	import flex.lang.reflect.Method;
	
	import org.flexunit.experimental.theories.IParameterSupplier;
	import org.flexunit.experimental.theories.IPotentialAssignment;
	import org.flexunit.experimental.theories.ParameterSignature;
	import org.flexunit.experimental.theories.internals.error.CouldNotGenerateValueException;
	import org.flexunit.runners.model.TestClass;
	

	public class Assignments {
		public var assigned:Array;
		public var unassigned:Array;		
		public var testClass:TestClass;

		public function Assignments( assigned:Array, unassigned:Array, testClass:TestClass ) {
			this.assigned = assigned;
			this.unassigned = unassigned;
			this.testClass = testClass;
		}
		
		public static function allUnassigned( method:Method, testClass:TestClass ):Assignments {
			var signatures:Array;
			var constructor:Constructor = testClass.klassInfo.constructor;

			signatures = ParameterSignature.signaturesByContructor( constructor );
			signatures = signatures.concat( ParameterSignature.signaturesByMethod( method ) );
			return new Assignments( new Array(), signatures, testClass );
		}

		public function get complete():Boolean {
			return unassigned.length == 0;
		}
	
		public function nextUnassigned():ParameterSignature {
			return unassigned[ 0 ];
		}
	
		public function assignNext( source:IPotentialAssignment ):Assignments {
			var assigned:Array = assigned.slice();
			assigned.push(source);
	
			return new Assignments(assigned, unassigned.slice(1,unassigned.length), testClass);
		}
	
		public function getActualValues( start:int, stop:int, nullsOk:Boolean ):Array{
			var values:Array = new Array(stop - start); //Object[stop - start];
			for (var i:int= start; i < stop; i++) {
				var value:Object= assigned[i].getValue();
				if (value == null && !nullsOk)
					throw new CouldNotGenerateValueException();
				values[i - start]= value;
			}
			return values;
		}
	
		public function potentialsForNextUnassigned():Array  {
			var unassigned:ParameterSignature = nextUnassigned();
			return getSupplier(unassigned).getValueSources(unassigned);
		}
	
		public function getSupplier( unassigned:ParameterSignature ):IParameterSupplier {
			var supplier:IParameterSupplier = getAnnotatedSupplier(unassigned);
			if (supplier != null)
				return supplier;
	
			return new AllMembersSupplier(testClass);
		}
	
		public function getAnnotatedSupplier( unassigned:ParameterSignature ):IParameterSupplier {
/* 			var supplier:Boolean = unassigned.findDeepAnnotation( "ParametersSuppliedBy" );
			if ( supplier == null)
 				return null;
 */
			//fix me 	return annotation.value().newInstance();
			return null;
		}
	
		public function getConstructorArguments( nullsOk:Boolean ):Array {
			return getActualValues(0, getConstructorParameterCount(), nullsOk);
		}
	
		public function getMethodArguments( nullsOk:Boolean ):Array {
			return getActualValues(getConstructorParameterCount(),assigned.length, nullsOk);
		}
	
		public function getAllArguments( nullsOk:Boolean ):Array {
			return getActualValues(0, assigned.length, nullsOk);
		}
	
		private function getConstructorParameterCount():int {
			var constructor:Constructor = testClass.klassInfo.constructor;
			var signatures:Array = ParameterSignature.signaturesByContructor( constructor );
			var constructorParameterCount:int = signatures.length;
			return constructorParameterCount;
		}
	
		public function getArgumentStrings( nullsOk:Boolean ):Array {
			var values:Array = new Array( assigned.length );
			for (var i:int = 0; i < values.length; i++) {
				values[i]= assigned[ i ].getDescription();
			}
			return values;
		}
 	}
}
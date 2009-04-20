package org.flexunit.experimental.theories.internals
{
	import flex.lang.reflect.Field;
	
	import org.flexunit.experimental.theories.IParameterSupplier;
	import org.flexunit.experimental.theories.ParameterSignature;
	import org.flexunit.experimental.theories.PotentialAssignment;
	import org.flexunit.runners.model.FrameworkMethod;
	import org.flexunit.runners.model.TestClass;

	public class AllMembersSupplier implements IParameterSupplier {
		private var testClass:TestClass;

		public function AllMembersSupplier( testClass:TestClass ) {
			this.testClass = testClass;
		}
		
		public function getValueSources( sig:ParameterSignature ):Array {
			var list:Array = new Array();

			addFields(sig, list);
			addSinglePointMethods(sig, list);
			addMultiPointMethods(sig, list);
	
			return list;
		}

		private function addFields( sig:ParameterSignature, list:Array ):void {
			var fields:Array = testClass.klassInfo.fields;
			var field:Field;

			for ( var i:int=0; i<fields.length; i++ ) {
				field = fields[ i ] as Field;

				if ( field.isStatic ) {					
					if (sig.canAcceptArrayType(field)
							&& field.hasMetaData( "DataPoints" ) ) {
						addArrayValues(field.name, list, getStaticFieldValue(field));
					} else if (sig.canAcceptType(field.type) && field.hasMetaData( "DataPoint" ) ) {
						list.push(PotentialAssignment
								.forValue(field.name, getStaticFieldValue(field)));
					}
				}
			}
		}

		private function addSinglePointMethods( sig:ParameterSignature, list:Array ):void {
			var dataPointMethod:FrameworkMethod;
			var methods:Array = testClass.getMetaDataMethods( "DataPoint" );
			var type:Class;
			
			for ( var i:int=0; i<methods.length; i++ ) {
				dataPointMethod = methods[ i ] as FrameworkMethod;
				type = sig.type;
				
				if ( dataPointMethod.producesType( type ) ) {
					list.push( new MethodParameterValue( dataPointMethod ) );
				}
			}
		}
	
		private function addMultiPointMethods( sig:ParameterSignature, list:Array ):void {
			var dataPointsMethod:FrameworkMethod;
			var methods:Array = testClass.getMetaDataMethods( "DataPoints" );
			var type:Class;

			for ( var i:int=0; i<methods.length; i++ ) {
				dataPointsMethod = methods[ i ] as FrameworkMethod;

				try {
					if ( sig.canAcceptArrayTypeMethod(dataPointsMethod) ) {
						addArrayValues( dataPointsMethod.name, list, dataPointsMethod.invokeExplosively(null) );
					}
				} catch ( e:Error ) {
					// ignore and move on
				}
			}
		}

		private function addArrayValues( name:String, list:Array, array:Object ):void {
			for (var i:int=0; i < (array as Array).length; i++)
				list.push( PotentialAssignment.forValue( name + "[" + i + "]", array[i] ) );
		}
	
		private function getStaticFieldValue( field:Field ):Object {
			try {
				return field.getObj(null);
			} catch ( e:TypeError ) {
				throw new Error(
						"unexpected: field from getClass doesn't exist on object");
			}
			return null; 
		}
	}
}

import org.flexunit.experimental.theories.internals.error.CouldNotGenerateValueException;
import org.flexunit.experimental.theories.IPotentialAssignment;
import org.flexunit.runners.model.FrameworkMethod;

class MethodParameterValue implements IPotentialAssignment {
	private var method:FrameworkMethod

	public function MethodParameterValue( dataPointMethod:FrameworkMethod ) {
		method = dataPointMethod;
	}

	public function getValue():Object {
		try {
			return method.invokeExplosively( null );
		} catch ( e:TypeError ) {
			throw new Error(
					"unexpected: argument length is checked");
		} catch (e:Error) {
			throw new CouldNotGenerateValueException();
			// do nothing, just look for more values
		}
		
		return null;
	}

	public function getDescription():String  {
		return method.name;
	}
}
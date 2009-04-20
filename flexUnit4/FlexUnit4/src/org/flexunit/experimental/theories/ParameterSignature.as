package org.flexunit.experimental.theories {
	import flex.lang.reflect.Constructor;
	import flex.lang.reflect.Field;
	import flex.lang.reflect.Method;
	
	import org.flexunit.runners.model.FrameworkMethod;
	
	public class ParameterSignature {

		private var _type:Class;
		private var _metaDataList:XMLList;

 		public static function signaturesByMethod( method:Method ):Array {
 			//trace("yo");
			return signatures( method.parameterTypes, method.metadata );
		}
	
		public static function signaturesByContructor( constructor:Constructor ):Array {
			return signatures( constructor.parameterTypes, null );
		}
	
		private static function signatures( parameterTypes:Array, metadataList:XMLList ):Array {
			var sigs:Array = new Array();
			for ( var i:int= 0; i < parameterTypes.length; i++) {
				sigs.push( new ParameterSignature( parameterTypes[i], metadataList ) );
			}
			return sigs;
		}
	
		public function canAcceptType( candidate:Class ):Boolean {
			return ( type == candidate );
		}
	
		public function get type():Class {
			return _type;
		}
	
		public function canAcceptArrayType( field:Field ):Boolean {
			return ( field.type == Array ) && canAcceptType( field.elementType ); 
		}

		public function canAcceptArrayTypeMethod( frameworkMethod:FrameworkMethod ):Boolean {
			return ( frameworkMethod.producesType( Array ) && canAcceptType( frameworkMethod.method.elementType ) );
		}

		public function hasMetadata( type:String ):Boolean {
			return getAnnotation(type) != null;
		}

 		public function findDeepAnnotation( type:String ):XML {
			var metaDataList2:XMLList = _metaDataList.copy();
			return privateFindDeepAnnotation( metaDataList2, type, 3);
		}
	
		private function privateFindDeepAnnotation( metaDataList:XMLList, type:String, depth:int ):XML {
			if (depth == 0)
				return null;

			//just return these for now... not sure how this will apply yet
			return getAnnotation( type );

/* 			for (Annotation each : annotations) {
				if (annotationType.isInstance(each))
					return annotationType.cast(each);
				Annotation candidate= findDeepAnnotation(each.annotationType()
						.getAnnotations(), annotationType, depth - 1);
				if (candidate != null)
					return annotationType.cast(candidate);
			}
			//not really getting this yet
 */	
			return null;
		}

		public function getAnnotation( type:String ):XML {
			for ( var i:int=0;i<_metaDataList.length(); i++ ) {
				if ( _metaDataList[ i ].@name == type ) {
					return _metaDataList[ i ];
				}
			}

			return null;
		}

		public function ParameterSignature( type:Class, metaDataList:XMLList ) {
			this._type= type;
			this._metaDataList = metaDataList;
		}
	}
}
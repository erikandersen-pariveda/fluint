package org.flexunit.experimental.theories {
	public class ParameterSignature {

/* 		public static function signaturesByMethod( method:XML ):Array {
			return signatures(method.getParameterTypes(), method
					.getParameterAnnotations());
		}
	
		public static function signaturesByContructor( constructor:Function ):Array {
			return signatures(constructor.getParameterTypes(), constructor.getParameterAnnotations());
		}
	
		private static function signatures( parameterTypes:Array, parameterAnnotations:Array ):Array {
			var sigs:Array = new Array();
			for ( var i:int= 0; i < parameterTypes.length; i++) {
				sigs.push(new ParameterSignature(parameterTypes[i],parameterAnnotations[i]));
			}
			return sigs;
		}
	
		private var type:Class;
	
		private var annotations:Array;
	
		public function ParameterSignature( type:Class, annotations:Array ) {
			this.type= type;
			this.annotations= annotations;
		}
	
		public function canAcceptType( candidate:Class ):Boolean {
			return ( type is candidate );
		}
	
		public function getType():Class {
			return type;
		}
	
		public function getAnnotations():Array {
			return annotations;
		}
	
		public function canAcceptArrayType( type:Class ):Boolean {
			return type.isArray() && canAcceptType(type.getComponentType());
		}
	
		public function hasAnnotation( type:Class ):Boolean {
			return getAnnotation(type) != null;
		}
	
		public function findDeepAnnotationForClass( annotationType:Class ):* {
			var annotations2:Array = annotations;
			return findDeepAnnotation(annotations2, annotationType, 3);
		}
	
		private function findDeepAnnotation( annotations:Array, annotationType:Class, depth:int ):* {
			if (depth == 0)
				return null;
 			for (Annotation each : annotations) {
				if (annotationType.isInstance(each))
					return annotationType.cast(each);
				Annotation candidate= findDeepAnnotation(each.annotationType()
						.getAnnotations(), annotationType, depth - 1);
				if (candidate != null)
					return annotationType.cast(candidate);
			}
	 
			return null;
		}
	
		public function getAnnotation( annotationType:Class ):* {
 			for (Annotation each : getAnnotations())
				if (annotationType.isInstance(each))
					return annotationType.cast(each); 
			return null;
		} */
	}
}
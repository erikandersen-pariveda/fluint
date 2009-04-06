package org.flexunit.utils {
	public class ClassNameUtil {
		import flash.utils.getQualifiedClassName;

		public static function getLoggerFriendlyClassName( instance:Object ):String {
			var periodReplace:RegExp = /\./g;
			var colonReplace:RegExp = /::/g;

			var fullname:String = getQualifiedClassName( instance );
			fullname = fullname.replace( periodReplace, "_" );
			fullname = fullname.replace( colonReplace, "_" );

			return fullname;
		}

		public function ClassNameUtil() {
		}
	}
}
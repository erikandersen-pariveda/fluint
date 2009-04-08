package flex.lang.reflect {
	import org.flexunit.utils.MetadataTools;
	
	public class Field {
		private var _fieldXML:XML;
		private var _definedBy:Class;
		private var _elementType:Class;

		private var _name:String;
		public function get name():String {
			return _name;
		}

		private var _isStatic:Boolean;
		public function get isStatic():Boolean {
			return _isStatic;
		}
		
		public function getObj( obj:Object ):Object {
			if ( obj == null ) {
				return _definedBy[ name ];
			} else {
				return obj[ name ];				
			}
		}
		
		public function get elementType():Class {
			if ( _elementType ) {
				return _elementType;
			}
			
			if ( ( type == Array ) && ( hasMetaData( "ArrayElementType" ) ) ) {
				//we are an array at least, so let's go further;
				var meta:String = getMetaData( "ArrayElementType" );
				
				try {
					_elementType = Klass.getClassFromName( meta );
				} catch ( error:Error ) {
					trace("Cannot find specified ArrayElementType("+meta+") in SWF");
				}
					
			}
			
			return _elementType;
		}

		public function hasMetaData( name:String ):Boolean {
			return MetadataTools.nodeHasMetaData( _fieldXML, name );
		}
		
		public function getMetaData( name:String, key:String="" ):String {
			return MetadataTools.getArgValueFromMetaDataNode( _fieldXML, name, key );
		}

		private var _type:Class;
		public function get type():Class {
			if (!_type) {
				_type = Klass.getClassFromName( _fieldXML.@type );
			}
			return _type;
		}

		public function Field( fieldXML:XML, isStatic:Boolean, definedBy:Class ) {
			_fieldXML = fieldXML;
			_name = fieldXML.@name;		
			_isStatic = isStatic;	
			_definedBy = definedBy;
		}

	}
}
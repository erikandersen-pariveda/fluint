package net.digitalprimates.fluint.utils
{
	public class MetaDataInformation
	{
		public static function isClass( description:XML ):Boolean {
			var baseType:String = description.@base;
			
			return ( baseType == "Class" );
		}

		public static function isInstance( description:XML ):Boolean {
			var baseType:String = description.@base;
			
			return ( baseType != "Class" );
		}

		public static function classExtends( description:XML, className:String ):Boolean {
			if ( isClass( description ) ) {
				return classExtendsFromNode( description.factory[ 0 ], className );
			} else {
				return classExtendsFromNode( description, className );
			}
		}
		
		public static function classImplements( description:XML, interfaceName:String ):Boolean {
			if ( isClass( description ) ) {
				return classImpementsNode( description.factory[ 0 ], interfaceName );
			} else {
				return classImpementsNode( description, interfaceName );
			}
		}
		
		
		public static function getMetaData( description:XML, metadata:String, key:String ):String {
			if ( isClass( description ) ) {
				return getMetaDataFromNode( description.factory[ 0 ], metadata, key );
			} else {
				return getMetaDataFromNode( description, metadata, key );
			}
		}
		
		public static function getMethodsList( description:XML ):XMLList {
			return description.method;
		} 

		public static function getMethodsDecoratedBy( methodList:XMLList, metadata:String ):XMLList {
			var narrowedMethodList:XMLList = methodList.metadata.(@name==metadata);
			var parentNodes:XMLList = new XMLList();
			
			for ( var i:int=0; i<narrowedMethodList.length(); i++ ) {
				parentNodes += narrowedMethodList[ i ].parent();
			}
	
			return parentNodes;
		} 
		
		public static function classExtendsFromNode( node:XML, className:String ):Boolean {
			var extendsList:XMLList;
			var doesExtend:Boolean = false;
			
			if ( node && node.extendsClass ) {
				extendsList = node.extendsClass.(@type==className);
				doesExtend = ( extendsList && ( extendsList.length() > 0 ) ); 	
			}
			
			return doesExtend;
		}

		public static function classImpementsNode( node:XML, interfaceName:String ):Boolean {
			var implementsList:XMLList;
			var doesImplement:Boolean = false;
			
			if ( node && node.implementsInterface ) {
				implementsList = node.implementsInterface.(@type==interfaceName);
				doesImplement = ( implementsList && ( implementsList.length() > 0 ) ); 	
			}
			
			return doesImplement;
		}
		
		public static function getMetaDataFromNode( node:XML, metadata:String, key:String ):String {
			var value:String;
			var metaNodes:XMLList;
			var arg:XMLList;

			if ( node && node.metadata && ( node.metadata.length() > 0 ) ) {
				metaNodes = node.metadata;
				
				if ( metaNodes.arg ) {
					arg = metaNodes.arg.(@key==key);
					
					if ( String( arg.@value ).length > 0 ) {
						value = arg.@value;
					}
				}
			}
			
			return value;
		}
	}
}
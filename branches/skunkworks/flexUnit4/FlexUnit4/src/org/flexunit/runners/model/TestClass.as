package org.flexunit.runners.model {
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import mx.collections.IViewCursor;
	
	import org.flexunit.runner.manipulation.MethodSorter;
	import org.flexunit.utils.MetadataTools;

	/**
	 * Wraps a class to be run, providing method validation and annotation searching
	 */
	public class TestClass {
		private var klass:Class;
		private var typeInfo:XML
		private var metaDataDictionary:Dictionary = new Dictionary( false );

	//TODO: I'm guessing JDK should be replaced with something else
		/**
		 * Creates a {@code TestClass} wrapping {@code klass}. Each time this
		 * constructor executes, the class is scanned for annotations, which can be
		 * an expensive process (we hope in future JDK's it will not be.) Therefore,
		 * try to share instances of {@code TestClass} where possible.
		 */
		public function TestClass( klass:Class ) {
			this.klass = klass;
			
			typeInfo = describeType( klass ); 

			var methodList:XMLList = new XMLList();			
			if ( XMLList( typeInfo.factory ).length() > 0 ) {
				methodList = MetadataTools.getMethodsList( typeInfo.factory[ 0 ] );
			}

			var staticMethodList:XMLList = new XMLList();			
			if ( XMLList( typeInfo.factory ).length() > 0 ) {
				staticMethodList = MetadataTools.getMethodsList( typeInfo );
			}
			
			//Ensures that the Order argument of the Test, Begin, After and BeforeClass and AfterClass are respected
			var sorter:MethodSorter = new MethodSorter( methodList );
			sorter.sort();
			var cursor:IViewCursor = sorter.createCursor();
			 
			var method:XML;
			while (!cursor.afterLast ) {
				method = cursor.current as XML;
				addToMetaDataDictionary( new FrameworkMethod( method ) );
				cursor.moveNext();
			}

			sorter = new MethodSorter( staticMethodList );
			sorter.sort();
			cursor = sorter.createCursor();			

			while (!cursor.afterLast ) {
				method = cursor.current as XML;
				addToMetaDataDictionary( new FrameworkMethod( method, true ) );
				cursor.moveNext();
			}
		}
		
		private function addToMetaDataDictionary( testMethod:FrameworkMethod ):void {
			var metaDataList:XMLList = testMethod.metadata;
			var metaTag:String;
			var entry:Array;
			
			if ( metaDataList ) {
				for ( var i:int=0; i<metaDataList.length(); i++ ) {
					metaTag = metaDataList[ i ].@name;
					
					entry = metaDataDictionary[ metaTag ];
					
					if ( !entry ) {
						metaDataDictionary[ metaTag ] = new Array();
						entry = metaDataDictionary[ metaTag ]
					}
					
					entry.push( testMethod );
				}
			}
		}
		
		/**
		 * Returns the underlying class.
		 */
		public function get asClass():Class {
			return klass;
		}

		/**
		 * Returns the class's name.
		 */
		public function get name():String {
			if (!typeInfo) {
				return "null";
			}

			return typeInfo.@name;
		}

		/**
		 * Returns the metadata on this class
		 */
		public function get metadata():XMLList {
			return MetadataTools.nodeMetaData( typeInfo );	
		}
		
		/**
		 * Returns, efficiently, all the non-overridden methods in this class and
		 * its superclasses that contain the metadata tag {@code metaTag}.
		 */
		public function getMetaDataMethods( metaTag:String ):Array {
			var methodArray:Array;
			methodArray = metaDataDictionary[ metaTag ];
			
			if ( !methodArray ) {
				methodArray = new Array();
			}
			
			return methodArray;
		} 
	}
}
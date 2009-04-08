package org.flexunit.runner.manipulation {
	import flex.lang.reflect.Method;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	
	import org.flexunit.utils.MetadataTools;
	
	public class MethodSorter {
		private function getOrderValueFromMethod( method:Method ):int {
			var order:int = 0;
			
			var metaDataList:XMLList = method.metadata;
			var metaData:XML;
			
			for ( var i:int=0; i<metaDataList.length(); i++ ) {
				metaData = metaDataList[ i ];

				var orderString:String = MetadataTools.getArgValueFromMetaDataNode( method.methodXML, metaData.@name, "order" );
				if ( orderString ) {
					order = int( orderString );
					break;
				}
			} 
	
			return order;
		}
	
		private function orderMethodSortFunction( aMethod:Method, bMethod:Method, fields:Object ):int {
			var field:String;
			var a:int;
			var b:int; 

			if ( !aMethod.metadata && !bMethod.metadata ) {
				return 0;
			}
			
			if ( !aMethod.metadata ) {
				return -1;
			}
			
			if ( !bMethod.metadata ) {
				return 1;
			}
			
			a = getOrderValueFromMethod( aMethod );
			b = getOrderValueFromMethod( bMethod );

			if (a < b)
				return -1;
			if (a > b)
				return 1;

			return 0;
		}
		
	    public function createCursor():IViewCursor {
        	return collection.createCursor();
	    }

	    public function get length():int {
	    	return collection.length;
	    }
		

		public function sort():void {
			collection.sort = sorter;
			collection.refresh();
		}

		private var collection:ArrayCollection;
		private var sorter:Sort;
		public function MethodSorter( methodList:Array ) {
			
			collection = new ArrayCollection( methodList );

			sorter = new Sort();
			sorter.compareFunction = orderMethodSortFunction;
		}
	}
}
package org.flexunit.runner.manipulation {
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.XMLListCollection;
	
	import org.flexunit.utils.MetadataTools;
	
	public class MethodSorter {
		private function getOrderValueFromMethod( method:XML ):int {
			var order:int = 0;
			
			var metaDataList:XMLList = method.metadata;
			var metaData:XML;
			
			for ( var i:int=0; i<metaDataList.length(); i++ ) {
				metaData = metaDataList[ i ];

				var orderString:String = MetadataTools.getArgValueFromMetaDataNode( method, metaData.@name, "order" );
				if ( orderString ) {
					order = int( orderString );
					break;
				}
			} 
	
			return order;
		}
	
		private function orderMetaDataSortFunction( aNode:XML, bNode:XML, fields:Object ):int {
			var field:String;
			var a:int;
			var b:int; 

			a = getOrderValueFromMethod( aNode );
			b = getOrderValueFromMethod( bNode );

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

		private var collection:XMLListCollection;
		private var sorter:Sort;
		public function MethodSorter( methodList:XMLList ) {
			
			collection = new XMLListCollection( methodList );

			sorter = new Sort();
			sorter.compareFunction = orderMetaDataSortFunction;
		}
	}
}
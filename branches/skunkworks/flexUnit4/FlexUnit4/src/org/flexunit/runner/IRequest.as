package org.flexunit.runner {
	import mx.collections.Sort;
	
	public interface IRequest {
		function get sort():Sort;
		function set sort( value:Sort ):void;

		function get iRunner():IRunner;
		
		function filterWith( filterOrDescription:* ):Request;
	}
}
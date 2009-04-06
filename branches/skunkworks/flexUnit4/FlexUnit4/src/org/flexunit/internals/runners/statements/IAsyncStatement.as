package org.flexunit.internals.runners.statements {
	
	import org.flexunit.token.AsyncTestToken;

	public interface IAsyncStatement {
		function execute( parentToken:AsyncTestToken ):void;
	}
}
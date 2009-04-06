package org.flexunit.internals.runners.statements {
	import flash.utils.*;
	
	import org.flexunit.internals.runners.model.MultipleFailureException;
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;
	
	public class StatementSequencer extends AsyncStatementBase implements IAsyncStatement {
		protected var queue:Array;
		protected var errors:Array;

		public function StatementSequencer( queue:Array=null ) {
			super();
			
			if (!queue) {
				queue = new Array();
			}			

			this.queue = queue.slice();
			this.errors = new Array();		

			myToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			myToken.addNotificationMethod( handleChildExecuteComplete );
		}
		
		public function addStep( child:IAsyncStatement ):void {
			if ( child ) {
				queue.push( child );
			}
		}
		
		protected function executeStep( child:* ):void {
			if ( child is IAsyncStatement ) {
				child.execute( myToken );
			}
		}
		
		public function execute( parentToken:AsyncTestToken ):void {
			this.parentToken = parentToken;
			handleChildExecuteComplete( null );
		}

		public function handleChildExecuteComplete( result:ChildResult ):void {
			var step:*;
			
			if ( result && result.error ) {
				errors.push( result.error );
			}
			
			if ( queue.length > 0 ) {
				step = queue.shift();	
				
				//trace("Sequence Executing Next Step " + step  );
				executeStep( step );
				//trace("Sequence Done Executing Step " + step );
			} else {
				//trace("Sequence Sending Complete " + this );
				sendComplete(); 
			}
		}

		override protected function sendComplete( error:Error=null ):void {
			var sendError:Error;

			if ( error ) {
				errors.push( error );
			}

			if (errors.length == 1)
				sendError = errors[ 0 ];
			else if ( errors.length > 1 ) {
				sendError = new MultipleFailureException(errors);
			}

			super.sendComplete( sendError );
		}

		override public function toString():String {
			return "Sequencer";
		}
	}
}
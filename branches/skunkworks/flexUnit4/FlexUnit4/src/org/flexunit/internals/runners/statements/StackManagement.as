package org.flexunit.internals.runners.statements {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;

	public class StackManagement implements IAsyncStatement {
		protected var parentToken:AsyncTestToken;		
		protected var myToken:AsyncTestToken;
		protected var timer:Timer;
		protected var statement:IAsyncStatement;

		public function StackManagement( statement:IAsyncStatement ) {
			super();
			
			this.statement = statement;
			timer = new Timer( 1, 1 );
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete, false, 0, true );
			
			myToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			myToken.addNotificationMethod( handleNextExecuteComplete );
		}

		public function execute( previousToken:AsyncTestToken ):void {
			parentToken = previousToken;
			timer.start();
		}

		protected function handleTimerComplete( event:TimerEvent ):void {
			statement.execute( myToken );
		}

		public function handleNextExecuteComplete( result:ChildResult ):void {
			parentToken.sendResult( result.error );
		}

		public function toString():String {
			return "Stack Management Base";
		}
		
	}
}

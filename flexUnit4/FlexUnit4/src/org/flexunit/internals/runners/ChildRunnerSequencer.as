package org.flexunit.internals.runners {
	import flash.events.IEventDispatcher;
	
	import org.flexunit.internals.events.ExecutionCompleteEvent;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.internals.runners.statements.StatementSequencer;
	import org.flexunit.runner.notification.RunNotifier;
	
	public class ChildRunnerSequencer extends StatementSequencer implements IAsyncStatement {
		public static const COMPLETE:String = "complete";
		private var runChild:Function;
		private var notifier:RunNotifier;
		private var parent:IEventDispatcher;

		public function ChildRunnerSequencer( children:Array, runChild:Function, notifier:RunNotifier ) {
			super( children );
			this.runChild = runChild;
			this.notifier = notifier;
			this.parent = parent;
		}
		
		override protected function executeStep( child:* ):void {
			runChild( child, notifier, myToken );
		}
		
		override public function toString():String {
			return "ChildRunnerSequence";
		}
	}
}
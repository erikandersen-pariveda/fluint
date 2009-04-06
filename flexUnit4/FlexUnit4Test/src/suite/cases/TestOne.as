package suite.cases {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.errors.ItemPendingError;
	
	import org.flexunit.async.Async;
	
	public class TestOne {
		private var timer:Timer;

 		[Before(async,Order=1)]
		public function tunBefore():void {
			trace("TestOne:Running before 1");
			timer = new Timer( 200, 1 );
			
		}

 		[Before(Order=2)]
		public function tunBefore2():void {
			trace("TestOne:Running before 2");
		}

 		[Test(async,Order=2,timeout="1000")]
		public function testOne2():void {
			trace("TestOne:Running test 2");
			//Async.failOnEvent( this, timer, TimerEvent.TIMER_COMPLETE );
			//Async.proceedOnEvent( this, timer, TimerEvent.TIMER_COMPLETE );
			Async.handleEvent( this, timer, TimerEvent.TIMER_COMPLETE, handleTimerComplete );
			timer.start();
		}

		protected function handleTimerComplete( event:TimerEvent, passThroughData:Object ):void {
			timer.reset();
			Async.handleEvent( this, timer, TimerEvent.TIMER_COMPLETE, handleTimerComplete );
			timer.start();
			trace("here, yo");
		}

		[Test(expected="mx.collections.errors.ItemPendingError",Order=1)]
		public function testOne1():void {
			trace("TestOne:Running test 1");
			throw new ItemPendingError( "Error" );
			//throw new RangeError( "Error" );
			//Assert.assertTrue( false );
			
		}

		[Test(Order=3)]
		public function testOne3():void {
			trace("TestOne:Running test 3");
		}
		
 		[After(Order=1)]
		public function runAfter():void {
			trace("TestOne:Running After 1");
		}

 		[After(Order=2)]
		public function runAfter2():void {
			trace("TestOne:Running After 2");
		}

 	}
}

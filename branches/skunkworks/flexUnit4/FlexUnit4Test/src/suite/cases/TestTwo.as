package suite.cases {
	public class TestTwo {
		[Before(Order=2)]
		public function beginHere():void {
			trace("TestTwo:Running Begin 2");
		}

		[Before(Order=1)]
		public function beginAlsoHereToo():void {
			trace("TestTwo:Running Begin 1");
		}

		[Before(Order=3)]
		public function beginAlsoHere():void {
			trace("TestTwo:Running Begin 3");
		}

		[Test(Order=1)]
		public function testTwo1():void {
			trace("TestTwo:Running Test 1");
		}

		[Test(Order=2)]
		public function testTwo2():void {
			trace("TestTwo:Running Test 2");
		}

		[Ignore][Test]
		public function testTwo3():void {
			trace("TestTwo:Ignored Test 3");
		}

		[After(Order=9)]
		public function afterHere():void {
			trace("TestTwo:Running After");	
		}

	}
}

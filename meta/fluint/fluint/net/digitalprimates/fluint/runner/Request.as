package net.digitalprimates.fluint.runner
{
	import net.digitalprimates.fluint.tests.ITestCaseRunner;
	
	public class Request
	{
		public static function aClass( clazz:Class ):Request {
			return new Request();
		}
		
		public static function classes( ...argumentsArray ):Request {
			return new Request();
		}
		
		public static function method( clazz:Class, methodName:String ):Request {
			return new Request();
		}
	}
}
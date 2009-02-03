package net.digitalprimates.fluint.assertion
{
	public class Assert
	{
		/**
		 * Asserts that the two provided values are equal
		 */
		public static function assertEquals(... rest):void
		{
			if ( rest.length == 3 )
				failNotEquals( rest[0], rest[1], rest[2] );
			else
				failNotEquals( "", rest[0], rest[1] );
		}
	
        /**
         * @private
         */
		public static function failNotEquals( message:String, expected:Object, actual:Object ):void
		{
			if ( expected != actual )
			   failWithUserMessage( message, "expected:<" + expected + "> but was:<" + actual + ">" );
		}
	
		/**
		 * Asserts that the provided values are strictly equal.
		 */
		public static function assertStrictlyEquals(... rest):void
		{
			if ( rest.length == 3 )
				failNotStrictlyEquals( rest[0], rest[1], rest[2] );
			else
				failNotStrictlyEquals( "", rest[0], rest[1] );
		}
	
        /**
         * @private
         */
		public static function failNotStrictlyEquals( message:String, expected:Object, actual:Object ):void
		{
			if ( expected !== actual )
			   failWithUserMessage( message, "expected:<" + expected + "> but was:<" + actual + ">" );
		}
	
		/**
		 * Asserts that the provided argument evaluates to true.
		 */
		public static function assertTrue(... rest):void
		{
			if ( rest.length == 2 )
				failNotTrue( rest[0], rest[1] );
			else
				failNotTrue( "", rest[0] );
		}
	
        /**
         * @private
         */
		public static function failNotTrue( message:String, condition:Boolean ):void
		{
			if ( !condition )
			   failWithUserMessage( message, "expected true but was false" );
		}
	
		/**
		 * Asserts that the provided argument evaluates to false.
		 */
		public static function assertFalse(... rest):void
		{
			if ( rest.length == 2 )
				failTrue( rest[0], rest[1] );
			else
				failTrue( "", rest[0] );
		}
	
        /**
         * @private
         */
		public static function failTrue( message:String, condition:Boolean ):void
		{
			if ( condition )
			   failWithUserMessage( message, "expected false but was true" );
		}
	
		/**
		 * Asserts that the provided argument evaluates to null.
		 */
		public static function assertNull(... rest):void
		{
			if ( rest.length == 2 )
				failNotNull( rest[0], rest[1] );
			else
				failNotNull( "", rest[0] );
		}
	
        /**
         * @private
         */
		public static function failNull( message:String, object:Object ):void
		{
			if ( object == null )
			   failWithUserMessage( message, "object was null: " + object );
		}
	
		/**
		 * Asserts that the provided argument does not evaluate to null.
		 */
		public static function assertNotNull(... rest):void
		{
			if ( rest.length == 2 )
				failNull( rest[0], rest[1] );
			else
				failNull( "", rest[0] );
		}
	
        /**
         * @private
         */
		public static function failNotNull( message:String, object:Object ):void
		{
			if ( object != null )
			   failWithUserMessage( message, "object was not null: " + object );
		}
	
		/**
		 * Immediately causes the test to fail with the message provided.
		 */
		public static function fail( failMessage:String = ""):void
		{
			throw new AssertionFailedError( failMessage );
		}
	

        /**
         * @private
         */
		private static function failWithUserMessage( userMessage:String, failMessage:String ):void
		{
			if ( userMessage.length > 0 )
				userMessage = userMessage + " - ";
	
			throw new AssertionFailedError( userMessage + failMessage );
		}
	}
}
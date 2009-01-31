/**
 * Copyright (c) 2007 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/ 
package net.digitalprimates.fluint.utils {
	import flash.utils.*;
	
	/** 
	 * Utility class used to display test results in the result display tree.
	 * Provides a utility for getting a qualified name and converting
	 * a qualified name and status to a string.
	 */
	public class ResultDisplayUtils {
		/** 
		 * Provided a class reference, this method returns a class name without 
		 * the full path.
		 * 
		 * @param classRef A reference to any class.
		 * @return Returns readable version of class name.
		 */
		public static function createSimpleName( classRef:* ):String {
			var qualifiedName:String = getQualifiedClassName( classRef );
			var position:int = qualifiedName.lastIndexOf( ':' );
			
			return qualifiedName.substr( position+1 );
		}

		/** 
		 * Provided a name and a status, returns a string to be displayed in 
		 * the result tree.
		 * 
		 * @param displayName The test being run.
		 * @param status Whether the test being run has passed.
		 * 
		 * @return The toString concatenation of the name and status.
		 */
		public static function toString( displayName:String, status:Boolean, executed:Boolean ):String {
			var name:String = displayName + ' - ';
			
			if ( executed ) {
				if ( status ) {
					name += 'Passed';
				} else {
					name += 'Failed';
				}
			} else {
				name += 'Pending';
			}

			return name;
		}
	}
}
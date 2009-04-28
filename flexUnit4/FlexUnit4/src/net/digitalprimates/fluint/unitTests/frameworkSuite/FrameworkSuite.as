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
package net.digitalprimates.fluint.unitTests.frameworkSuite
{
	import flexunit.framework.AllFrameworkTests;
	
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestASComponentUse;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestAssert;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestAsynchronous;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestAsynchronousSetUpTearDown;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestBeforeAfterClassOrder;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestBeforeAfterClassOrderAsync;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestBeforeAfterOrder;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestBeforeAfterOrderAsync;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestBindingUse;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestIgnore;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestMXMLComponentUse;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestMethodOrder;
	import net.digitalprimates.fluint.unitTests.frameworkSuite.testCases.TestSynchronousSetUpTearDown;
	import net.digitalprimates.fluint.unitTests.theorySuite.TheorySuite;
	
	import org.hamcrest.HamcrestSuite;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
    /**
     * @private
     */
	public class FrameworkSuite {
		public var testAssert:TestAssert;
		public var testIgnore:TestIgnore;
		public var testMethodOrder:TestMethodOrder;
		public var testBeforeAfterOrder:TestBeforeAfterOrder;
		public var testBeforeAfterClassOrder:TestBeforeAfterClassOrder;
		public var testBeforeAfterOrderAsync:TestBeforeAfterOrderAsync;
		public var testBeforeAfterClassOrderAsync:TestBeforeAfterClassOrderAsync;
		public var testAsynchronous:TestAsynchronous;
		public var testSynchronousSetUpTearDown:TestSynchronousSetUpTearDown;
		public var testAsynchronousSetUpTearDown:TestAsynchronousSetUpTearDown;
		public var testASComponentUse:TestASComponentUse;
		public var testMXMLComponentUse:TestMXMLComponentUse;
		public var testBindingUse:TestBindingUse;
		public var theory:TheorySuite;
		
		public var hamcrest:HamcrestSuite;
		public var flexUnit1Tests:AllFrameworkTests;
	}
}
/**
 * Copyright (c) 2009 Digital Primates IT Consulting Group
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
 * 
 * @author     Michael Labriola <labriola@digitalprimates.net>
 * @version    
 **/ 
package org.flexunit.experimental.runners.statements
{
	import flexunit.framework.AssertionFailedError;
	
	import org.flexunit.experimental.theories.internals.Assignments;
	import org.flexunit.experimental.theories.internals.ParameterizedAssertionError;
	import org.flexunit.internals.AssumptionViolatedException;
	import org.flexunit.internals.namespaces.classInternal;
	import org.flexunit.internals.runners.statements.AsyncStatementBase;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.runners.model.FrameworkMethod;
	import org.flexunit.runners.model.TestClass;
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;
	
	use namespace classInternal;

	public class TheoryAnchor extends AsyncStatementBase implements IAsyncStatement {
		private var successes:int = 0;
		private var frameworkMethod:FrameworkMethod;
		private var invalidParameters:Array = new Array();
		private var testClass:TestClass;
		private var assignment:Assignments;
		private var errors:Array = new Array();
		private var incompleteLoopCount:int = 0;
		private var completeLoopCount:int = 0;
		
 		public function TheoryAnchor( method:FrameworkMethod, testClass:TestClass ) {
			frameworkMethod = method;
			this.testClass = testClass;
			
			myToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			myToken.addNotificationMethod( handleMethodExecuteComplete );
		}
		
		protected function handleMethodExecuteComplete( result:ChildResult ):void {
			var error:Error;

			if (successes == 0)
				error = new AssertionFailedError("Never found parameters that satisfied method assumptions.  Violated assumptions: " + invalidParameters);
			
			parentToken.sendResult( error );
		}

		public function evaluate(parentToken:AsyncTestToken):void {
			this.parentToken = parentToken;

			//Thhis is run once per theory method found in the class
			var assignment:Assignments = Assignments.allUnassigned( frameworkMethod.method, testClass );
			var statement:AssignmentSequencer = new AssignmentSequencer( assignment, frameworkMethod, testClass.asClass, this );
			statement.evaluate( myToken );
		}

		private function methodCompletesWithParameters( method:FrameworkMethod, complete:Assignments, freshInstance:Object ):IAsyncStatement {
			return new MethodCompleteWithParamsStatement( method, this, complete, freshInstance );
		}

		classInternal function handleAssumptionViolation( e:AssumptionViolatedException ):void {
			invalidParameters.push(e);
		}

		classInternal function reportParameterizedError( e:Error, ...params):void {
 			if (params.length == 0)
				throw e;
			throw new ParameterizedAssertionError(e, frameworkMethod.name, params);
		}

		classInternal function nullsOk():Boolean {
			
			return true;
			
			var isTheory:Boolean = frameworkMethod.method.hasMetaData( "Theory" );

			//this needs to be much more complicated			
			if ( isTheory ) {
				return true;
			} else {
				return false;
			}

/* 			var annotation:Theory = testMethod.method.getSpecificMetaDataArg( "Theory" );
			if (annotation == null)
				return false;
			return annotation.nullsAccepted();*/
			return false;
 		}

		classInternal function handleDataPointSuccess():void {
			successes++;
		}		
	}
}


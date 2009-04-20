package org.flexunit.experimental.runners.statements
{
	import org.flexunit.Assert;
	import org.flexunit.experimental.theories.IPotentialAssignment;
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

 		public function TheoryAnchor( method:FrameworkMethod, testClass:TestClass ) {
			frameworkMethod = method;
			this.testClass = testClass;
			
			myToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
			//myToken.addNotificationMethod( handleBlockExecuteComplete );
		}

		public function execute(parentToken:AsyncTestToken):void {
			this.parentToken = parentToken;

 			runWithAssignment( 
 					Assignments.allUnassigned( frameworkMethod.method, testClass ) );

			if (successes == 0)
				Assert.fail("Never found parameters that satisfied method assumptions.  Violated assumptions: " + invalidParameters);
				
			parentToken.sendResult( null );			
		}

		protected function runWithAssignment( parameterAssignment:Assignments ):void {
			if (!parameterAssignment.complete ) {
				runWithIncompleteAssignment(parameterAssignment);
			} else {
				runWithCompleteAssignment(parameterAssignment);
			}
		}

		protected function runWithIncompleteAssignment( incomplete:Assignments ):void {
 			var source:IPotentialAssignment;
 			var potential:Array = incomplete.potentialsForNextUnassigned();
 			
			for ( var i:int=0; i<potential.length; i++ ) {
				source = potential[ i ] as IPotentialAssignment;
				runWithAssignment( incomplete.assignNext( source ) );
			}
		}

		protected function runWithCompleteAssignment( complete:Assignments ):void {
			var runner:TheoryBlockRunner = new TheoryBlockRunner( testClass.asClass, this, complete );
			runner.getMethodBlock( frameworkMethod ).execute( myToken );
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

import org.flexunit.experimental.theories.internals.Assignments;
import org.flexunit.runners.model.FrameworkMethod;
import org.flexunit.internals.runners.statements.IAsyncStatement;
import org.flexunit.token.AsyncTestToken;
import org.flexunit.internals.runners.statements.AsyncStatementBase;
import org.flexunit.token.ChildResult;
import org.flexunit.experimental.theories.internals.error.CouldNotGenerateValueException;
import org.flexunit.internals.namespaces.classInternal;

use namespace classInternal;

class MethodCompleteWithParamsStatement extends AsyncStatementBase implements IAsyncStatement {
	private var method:FrameworkMethod;
	private var anchor:TheoryAnchor;
	private var complete:Assignments;
	private var freshInstance:Object;

	public function MethodCompleteWithParamsStatement( method:FrameworkMethod, anchor:TheoryAnchor, complete:Assignments, freshInstance:Object ) {
		this.method = method;
		this.complete = complete;
		this.freshInstance = freshInstance;
		this.anchor = anchor;
		
		myToken = new AsyncTestToken( "MethodCompleteWithParamsStatement" );
		myToken.addNotificationMethod( handleChildExecuteComplete );
	}	

	public function execute( parentToken:AsyncTestToken ):void {
		this.parentToken = parentToken;	

 		try {
			var values:Object = complete.getMethodArguments( anchor.nullsOk() );
			method.applyExplosivelyAsync( myToken, freshInstance, values as Array );
		} catch ( e:CouldNotGenerateValueException ) {
			sendComplete( null );	
		} //catch ( e:Error ) {
			//sendComplete( e );
		//}
 	}
	
	public function handleChildExecuteComplete( result:ChildResult ):void {
		sendComplete( result.error );
	}
}

import org.flexunit.internals.runners.statements.IAsyncStatement;
import org.flexunit.runners.BlockFlexUnit4ClassRunner;
import org.flexunit.runners.model.FrameworkMethod;
import org.flexunit.internals.namespaces.classInternal;

use namespace classInternal;

class TheoryBlockRunner extends BlockFlexUnit4ClassRunner {
	private var complete:Assignments;
	private var anchor:TheoryAnchor;
	private var klassInfo:Klass;

	public function TheoryBlockRunner( klass:Class, anchor:TheoryAnchor, complete:Assignments ) {
		super(klass);
		this.anchor = anchor;
		this.complete = complete;
		this.klassInfo = new Klass( klass );
	}

	override protected function collectInitializationErrors( errors:Array ):void {
		// do nothing
	}		

	override protected function methodInvoker( method:FrameworkMethod, test:Object ):IAsyncStatement {
		return new MethodCompleteWithParamsStatement( method, anchor, complete, test );
	}

	override protected function createTest():Object {
		return klassInfo.constructor.newInstanceApply( complete.getConstructorArguments( anchor.nullsOk() ) );
	}
	
	public function getMethodBlock( method:FrameworkMethod ):IAsyncStatement {
		return methodBlock( method );
	}

	override protected function methodBlock( method:FrameworkMethod ):IAsyncStatement {
		var statement:IAsyncStatement = super.methodBlock( method );
		return new TheoryBlockRunnerStatement( statement, anchor, complete ); 
	}

	override protected function withDecoration( method:FrameworkMethod, test:Object ):IAsyncStatement {
		var statement:IAsyncStatement = methodInvoker( method, test );
		//statement = withPotentialAsync( method, test, statement );
		//statement = withPotentialTimeout( method, test, statement );
		statement = possiblyExpectingExceptions( method, test, statement );
		//statement = withStackManagement( method, test, statement );
		
		//Right now we are only running these test synchronously
		return statement;
	}
	
}

import org.flexunit.experimental.theories.internals.Assignments;
import org.flexunit.runners.model.FrameworkMethod;
import org.flexunit.internals.runners.statements.IAsyncStatement;
import org.flexunit.token.AsyncTestToken;
import org.flexunit.internals.runners.statements.AsyncStatementBase;
import org.flexunit.token.ChildResult;
import org.flexunit.experimental.theories.internals.error.CouldNotGenerateValueException;
import org.flexunit.internals.AssumptionViolatedException;
import org.flexunit.experimental.runners.statements.TheoryAnchor;
import org.flexunit.internals.namespaces.classInternal;
import flex.lang.reflect.Klass;

class TheoryBlockRunnerStatement extends AsyncStatementBase implements IAsyncStatement {
	use namespace classInternal;

	private var statement:IAsyncStatement;
	private var anchor:TheoryAnchor;
	private var complete:Assignments;

	public function TheoryBlockRunnerStatement( statement:IAsyncStatement, anchor:TheoryAnchor, complete:Assignments ) {
		this.statement = statement;
		this.anchor = anchor;
		this.complete = complete;
		
		myToken = new AsyncTestToken( "TheoryBlockRunnerStatement" );
		myToken.addNotificationMethod( handleChildExecuteComplete );
	}	

	public function execute( parentToken:AsyncTestToken ):void {
		this.parentToken = parentToken;

 		try {
			statement.execute( myToken );
			anchor.handleDataPointSuccess();
		} catch ( e:AssumptionViolatedException ) {
			anchor.handleAssumptionViolation( e );
			sendComplete( e );	
		} catch ( e:Error ) {
			trace( e.getStackTrace() );
			anchor.reportParameterizedError(e, complete.getArgumentStrings(anchor.nullsOk()));
			//sendComplete( e );			
		}
	}
						
	public function handleChildExecuteComplete( result:ChildResult ):void {
		sendComplete( result.error );
	}
}

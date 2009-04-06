package org.flexunit.experimental.runners.statements
{
	import org.flexunit.experimental.theories.PotentialAssignement;
	import org.flexunit.experimental.theories.internals.Assignments;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.runners.model.FrameworkMethod;
	import org.flexunit.token.AsyncTestToken;

	public class TheoryAnchor implements IAsyncStatement {
		private var successes:int = 0;
		private var method:FrameworkMethod;
		private var invalidParameters:Array = new Array();

		public function execute(parentToken:AsyncTestToken):void {
			
		}
 		public function TheoryAnchor( method:FrameworkMethod ) {
			this.method = method;
		}
/*
		public function execute(parentToken:AsyncTestToken):void {
			runWithAssignment(Assignments.allUnassigned(
					fTestMethod.getMethod(), getTestClass()));

			if (successes == 0)
				Assert
						.fail("Never found parameters that satisfied method assumptions.  Violated assumptions: "
								+ fInvalidParameters);			
		}

		protected function runWithAssignment( parameterAssignment:Assignments ):void {
			if (!parameterAssignment.isComplete()) {
				runWithIncompleteAssignment(parameterAssignment);
			} else {
				runWithCompleteAssignment(parameterAssignment);
			}
		}

		protected function runWithIncompleteAssignment( incomplete:Assignments ):void {
			var source:PotentialAssignement;
			for ( var source:PotentialAssignement in incomplete.potentialsForNextUnassigned() ) {
				runWithAssignment( incomplete.assignNext(source) );
			}
		} */

		protected function runWithCompleteAssignment( complete:Assignments ):void {
/* 			new BlockJUnit4ClassRunner(getTestClass().getJavaClass()) {
				@Override
				protected void collectInitializationErrors(
						List<Throwable> errors) {
					// do nothing
				}

				@Override
				public Statement methodBlock(FrameworkMethod method) {
					final Statement statement= super.methodBlock(method);
					return new Statement() {
						@Override
						public void evaluate() throws Throwable {
							try {
								statement.evaluate();
								handleDataPointSuccess();
							} catch (AssumptionViolatedException e) {
								handleAssumptionViolation(e);
							} catch (Throwable e) {
								reportParameterizedError(e, complete
										.getArgumentStrings(nullsOk()));
							}
						}

					};
				}

				@Override
				protected Statement methodInvoker(FrameworkMethod method, Object test) {
					return methodCompletesWithParameters(method, complete, test);
				}

				@Override
				public Object createTest() throws Exception {
					return getTestClass().getOnlyConstructor().newInstance(
							complete.getConstructorArguments(nullsOk()));
				}
			}.methodBlock(fTestMethod).evaluate();
 */		}

	}
}
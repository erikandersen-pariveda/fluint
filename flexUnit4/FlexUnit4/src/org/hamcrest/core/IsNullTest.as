package org.hamcrest.core {
  
  import org.hamcrest.*;
  import org.hamcrest.object.notNullValue;
  import org.hamcrest.object.nullValue;
  
  public class IsNullTest extends AbstractMatcherTestCase {
    
    [Test]
    public function testEvaluatesToTrueIfArgumentIsNull():void {
      
      assertThat(null, nullValue());
      assertThat("not null", not(nullValue()));
      
      assertThat("not null", notNullValue());
      assertThat(null, not(notNullValue()));
    }
  }
}
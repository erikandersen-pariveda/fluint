package org.hamcrest.core {
  
  import org.hamcrest.*;
  
  public class IsSameTest extends AbstractMatcherTestCase {
    
    [Test]
    public function testEvaluatesToTrueIfArgumentIsReferenceToASpecificObject():void {
      
      var o1:Object = {};
      var o2:Object = {};
      
      assertThat(o1, sameInstance(o1));
      assertThat(o2, not(sameInstance(o1)));
    }
    
    [Test]
    public function testReturnsReadableDescriptionFromToString():void {
      assertDescription("sameInstance(\"ARG\")", sameInstance("ARG"));
    }
    
    [Test]
    public function testReturnsReadableDescriptionFromToStringWhenInitializedithNull():void {
      assertDescription("sameInstance(null)", sameInstance(null));
    }
  }
}
package net.digitalprimates.fluint.sequence
{
  import flash.events.IEventDispatcher;
  
  import net.digitalprimates.fluint.assertion.AssertionFailedError;
  import net.digitalprimates.fluint.sequence.ISequenceAction;

  /**
   * Allows you to make an assert in the middle of a sequence.
   */
  public class SequenceAssert implements ISequenceAction
  {
    private var assertion : Function;
    
    /**
     * Creates a new SequenceAssert.
     * 
     * @param assert Function that makes dpuint assertions
     */
    public function SequenceAssert(assertion : Function)
    {
      this.assertion = assertion;
    }

    public function get target():IEventDispatcher
    {
      return null;
    }
    
    public function execute():void
    {
      try
      {
        assertion();
      } catch (e:AssertionFailedError) {
        trace("SequenceAssert caused failure: " + e.message);
        throw e;
      }
    }
    
  }
}
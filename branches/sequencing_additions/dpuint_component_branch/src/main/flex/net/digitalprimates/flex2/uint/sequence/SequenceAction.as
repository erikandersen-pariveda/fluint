package net.digitalprimates.flex2.uint.sequence
{
  import flash.events.IEventDispatcher;

  /**
   * A function invocation in a sequence.
   */
  public class SequenceAction implements ISequenceAction
  {
    private var object : Object;
    private var args : Array;
    private var func : Function;
    
    /**
     * Constructor.
     *
     * @param func function to call 
     * @param object object where the function lives (can be null if anonymous function)
     * @param args arguments to pass to the function
     */
    public function SequenceAction(func : Function, object : Object = null, args : Array = null)
    {
      this.func = func;
      this.object = object;
      this.args = args;
    }
    
    public function get target():IEventDispatcher
    {
      return null;
    }
    
    public function execute():void
    {
      func.apply(object, args);
    }
    
  }
}
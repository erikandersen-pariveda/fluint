package net.digitalprimates.fluint.sequence
{
  import flash.events.IEventDispatcher;
  import flash.utils.Timer;
  
  /**
   * Allows for sleeping in the middle of a sequence.
   * 
   * NOTE: This heavily relies on the caller to add a corresponding SequenceWaiter for the TimerEvent. It would not
   *       be of much value if you just stuck it in the middle of sequence without the 
   *       associated SequenceWaiter.  
   * 
   * TODO: In the future, it would be nice if you could have multiple sequences grouped together.  That way
   *       you could avoid the coupling described in the above note.
   */
  public class SequenceSleep implements ISequenceAction
  {
    private var timer : Timer;
    
    /**
     * Constructor.
     * 
     * @param milliseconds number of milliseconds between each Timer event
     */
    public function SequenceSleep(millseconds:int, repeatCount:int = 100)
    {
      timer = new Timer(millseconds, repeatCount);
    }
    
    /**
     * Starts the timer.
     */
    public function execute() : void
    {
      timer.start();
    }
    
    /**
     * @return the timer
     */
    public function get target():IEventDispatcher
    {
      return timer;
    }
    
    public function toString() : String {
          return "SequenceSleep";    
    }

  }
}
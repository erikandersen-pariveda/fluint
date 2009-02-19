package net.digitalprimates.fluint.sequence
{
  import flash.display.DisplayObject;
  import flash.events.IEventDispatcher;
  
  import mx.core.UIComponent;
  
  /**
   * Interface to allow multiple ways of acquiring a target for ISequencePend sequences.
   */
  public interface TargetSelector
  {
    /** 
     * The target eventDispatcher used to broadcast events or listen to for events.
     */
    function get target():IEventDispatcher 
  }
}
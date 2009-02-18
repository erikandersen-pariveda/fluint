package net.digitalprimates.fluint.sequence
{
  import flash.display.DisplayObject;
  import flash.events.IEventDispatcher;
  
  import mx.core.UIComponent;
  
  public interface TargetSelector
  {
    /** 
     * The target eventDispatcher used to broadcast events or listen to for events.
     */
    function get target():IEventDispatcher 
  }
}
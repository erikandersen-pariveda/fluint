package net.digitalprimates.fluint.sequence
{
  import flash.display.DisplayObject;
  import flash.events.IEventDispatcher;
  
  import mx.core.UIComponent;
  
  public class TargetSelector
  {
    private var _target : IEventDispatcher;
    
    public function TargetSelector(target : IEventDispatcher)
    {
      this._target = target;
    }
    
    /** 
     * The target eventDispatcher which the implementing classes will manipulate, use to boradcast events or 
     * listen to for events
     */
    public function get target():IEventDispatcher 
    {
      return _target;
    }
    
    /**
     *
     * NOTE: This is really to ensure backward compatibility of the existing Sequence* methods.  I would really like to get rid of
     *       this.
     */
    public static function determineSelector(selector:Object) : TargetSelector
    {
      if (selector is TargetSelector) 
      {
        return selector as TargetSelector;
      } 
      else if (selector is IEventDispatcher) 
      {
        return new TargetSelector(selector as IEventDispatcher);
      } 
      else if (selector is Function) 
      {
        return new DelayedTargetSelector(selector as Function);        
      } 
      else 
      {
        throw new ArgumentError("Argument is not a recognized selector. [" + selector + "]");
      }
    }

  }
}
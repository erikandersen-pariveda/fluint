package net.digitalprimates.fluint.sequence
{
  import flash.events.IEventDispatcher;

  public class DelayedTargetSelector extends TargetSelector
  {
    private var _targetSelector : Function;
    
    private var _cachedTarget : IEventDispatcher;
    
    public function DelayedTargetSelector(targetSelector:Function)
    {
      super(null);
      this._targetSelector = targetSelector;
    }
    
    override public function get target() : IEventDispatcher
    {
      if (!_cachedTarget) {
        _cachedTarget = _targetSelector() as IEventDispatcher;
        if (!_cachedTarget) {
          trace("ERROR: Delayed target not acquired.");
        }
      }

      return _cachedTarget;
    }
    
  }
}
package net.digitalprimates.fluint.sequence
{
  import flash.events.IEventDispatcher;

  /**
   * Delays the requirement to have an IEventDispatcher until playback.
   * 
   * <p>The IEventDispatcher will be selected the first time the target getter is invoked.  That
   * dispatcher will be cached and returned for all subsequent calls.</p>
   */
  public class DelayedTargetSelector implements TargetSelector
  {
    private var _targetSelectorFunction : Function;
    
    private var _cachedTarget : IEventDispatcher;
    
    /**
     * Constructor.
     * 
     * @param targetSelectorFunction a function that returns an IEventDispatcher object
     */
    public function DelayedTargetSelector(targetSelectorFunction:Function)
    {
      this._targetSelectorFunction = targetSelectorFunction;
    }
    
    public function get target() : IEventDispatcher
    {
      if (!_cachedTarget) {
        _cachedTarget = _targetSelectorFunction() as IEventDispatcher;
        if (!_cachedTarget) {
          trace("ERROR: Delayed target not acquired.");
        }
      }

      return _cachedTarget;
    }
    
  }
}
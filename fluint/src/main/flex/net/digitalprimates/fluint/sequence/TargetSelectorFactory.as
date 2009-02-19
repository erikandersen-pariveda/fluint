package net.digitalprimates.fluint.sequence
{
    import flash.events.IEventDispatcher;
    
    public class TargetSelectorFactory
    {
        /**
         * Converts any object into the correct <code>TargetSelector</code>.
         * 
         * This is used to preserve backward compatibility rather than change all the Sequence* constructors to take TargetSelector.
         */
        public static function determineSelector(selector:Object) : TargetSelector
        {
          if (selector is TargetSelector) 
          {
            return selector as TargetSelector;
          } 
          else if (selector is IEventDispatcher) 
          {
            return new ImmediateTargetSelector(selector as IEventDispatcher);
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
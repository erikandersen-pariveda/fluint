package net.digitalprimates.fluint.sequence
{
    import flash.events.IEventDispatcher;

    public class ImmediateTargetSelector implements TargetSelector
    {
        private var _target:IEventDispatcher;
        
        public function ImmediateTargetSelector(target:IEventDispatcher)
        {
            this._target = target;
        }

        public function get target():IEventDispatcher
        {
            return _target;
        }
        
    }
}
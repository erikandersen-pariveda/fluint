package net.digitalprimates.fluint.sequence
{
    import flash.events.IEventDispatcher;

    /**
     * A TargetSelector for when the target is known at record-time.
     */
    public class ImmediateTargetSelector implements TargetSelector
    {
        private var _target:IEventDispatcher;
        
        /**
         * Constructor.
         * 
         * @param target IEventDispatcher to be used in a sequence
         */
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
package net.digitalprimates.fluint.sequence
{
    import flash.events.IEventDispatcher;
    
    public interface ISequenceDispatcher extends ISequenceStep
    {
        /** 
         * The target eventDispatcher which the implementing classes will manipulate, use to boradcast events or 
         * listen to for events
         */
        function get target():IEventDispatcher
    }
}
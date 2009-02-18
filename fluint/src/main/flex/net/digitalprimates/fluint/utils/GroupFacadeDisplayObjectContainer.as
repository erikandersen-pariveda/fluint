package net.digitalprimates.fluint.utils
{
    import flash.display.DisplayObject;
    
    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;

    /**
    * Allows multiple <code>DisplayObject</code>s to be treated as a single node. 
    */
    public class GroupFacadeDisplayObjectContainer extends UIComponent
    {
        private var children : ArrayCollection;
        
        public function GroupFacadeDisplayObjectContainer(children : Array)
        {
            super();
            this.children = new ArrayCollection(children);
        }
        
        override public function get numChildren() : int
        {
            return children.length;
        }
        
        override public function getChildAt(index : int) : DisplayObject
        {
            return children.getItemAt(index) as DisplayObject;
        }
    }
}
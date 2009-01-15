package net.digitalprimates.flex2.uint.utils
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    
    import mx.core.Application;
    import mx.core.Container;
    import mx.core.IChildList;
    import mx.core.UIComponent;
    
    public class ComponentFinder
    {
        private var root : DisplayObjectContainer;
        
        private var allLayersView : GroupFacadeDisplayObjectContainer;
        
        public function ComponentFinder(root : DisplayObjectContainer)
        {
            this.root = root;
            this.allLayersView = new GroupFacadeDisplayObjectContainer([Application.application.systemManager, root]);
        }
        
        private function firstElement(items : Array) : UIComponent
        {
            return items.length == 0 ? null : findUIComponentParent(items[0] as DisplayObject);
        }
        
        /**
         * Converts an array of DisplayObjects into an array of their nearest parents.
         */ 
        private function componentize(items : Array) : Array
        {
            var componentsArray : Array = new Array();
            if (!items || items.length == 0)
            {
                return componentsArray;   
            }
            
            for each(var match : DisplayObject in items)
            {
                componentsArray.push(findUIComponentParent(match));   
            }            
            
            return componentsArray;
        }
        
        /**
         * Finds the first component with the specified id.
         */
        public function withId(id : String) : UIComponent
        {
            var foundItems : Array = new Array();
            
            eachChild(allLayersView, function(node : DisplayObject, foundItemsBucket : Array) : Boolean {
                if (node.hasOwnProperty("id"))
                {
                    if (node["id"] == id)
                    {
                        foundItemsBucket.push(node);
                        return false;
                    }
                }
                return true;
            }, [foundItems]); 
            
            return firstElement(foundItems);
        }
        
        /**
         * Finds the first component with the specified id.
         */
        public function delayedWithId(id : String) : Function
        {
            return function() {return withId(id);};
        }
        
        /**
         * Finds the first component with the specified name.
         */
        public function withName(name : String) : UIComponent
        {
            var foundItems : Array = new Array();
            
            eachChild(allLayersView, function(node : DisplayObject, foundItemsBucket : Array) : Boolean {
                if (node.hasOwnProperty("name"))
                {
                    if (node["name"] == name)
                    {
                        foundItemsBucket.push(node);
                        return false;
                    }
                }
                return true;
            }, [foundItems]); 
            
            return firstElement(foundItems);
        }
        
        /**
         * Finds the first component with the specified name.
         */
        public function delayedWithName(name : String) : Function
        {
            return function() {return withName(name);};
        }
        
        /**
         * Finds the first component that matches <em>ANY</em> of the properties passed in.
         */ 
        public function withAny(properties : Object, excludes : Object = null) : UIComponent
        {
            var foundItems : Array = new Array();
            
            eachChild(allLayersView, function(node : DisplayObject, foundItemsBucket : Array) : Boolean {
                for (var propName : String in properties)
                {
                    if (node.hasOwnProperty(propName) && node[propName] == properties[propName])
                    {
                        var excluded : Boolean = false;
                        if (excludes)
                        {
                            for (var excludePropName : String in excludes)
                            {
                                if (node.hasOwnProperty(excludePropName) && node[excludePropName] == excludes[excludePropName])
                                {
                                    excluded = true;
                                    break;
                                }
                            }
                        }
                        
                        if (!excluded)
                        {
                            trace("Found element matching property: " + propName + " [" + node + "]");
                            foundItemsBucket.push(node);
                            return false;    
                        }
                    }    
                }
                
                return true;
            }, [foundItems]); 
            
            return firstElement(foundItems);
        }
        
        /**
         * Finds the first component that matches <em>ANY</em> of the properties passed in.
         */ 
        public function delayedWithAny(properties : Object) : Function
        {
            return function() {return withAny(properties);};
        }
        
        /**
         * Finds the first component that matches <em>ALL</em> of the properties passed in.
         */ 
        public function withAll(properties : Object) : UIComponent
        {
            var foundItems : Array = new Array();
            
            eachChild(allLayersView, function(node : DisplayObject, foundItemsBucket : Array) : Boolean {
                for (var propName : String in properties)
                {
                    if (node.hasOwnProperty(propName))
                    {
                        if (node[propName] == properties[propName])
                        {
                            foundItemsBucket.push(node);
                            return false;
                        }
                        else
                        {
                            // If we haven't matched on all properties, just skip to the next node
                            return true;
                        }
                    }    
                    else
                    {
                        // If we haven't matched on all properties, just skip to the next node
                        return true;
                    }
                }
                
                return true;
            }, [foundItems]); 
            
            return firstElement(foundItems);
        }
        
        /**
         * Finds the first component that matches <em>ALL</em> of the properties passed in.
         */ 
        public function delayedWithAll(properties : Object) : Function
        {
            return function() {return withAll(properties);};
        }
        
        /**
         * Finds the first component that has the specified text showing.
         */
        public function withText(text : String) : UIComponent
        {
             var matches : Array = allWithAny({"text": text, "label": text}, {name: "hiddenItem"});
             
             // Total hack to get around another total hack in MenuItem in which they create a MenuItemRenderer of 
             // name 'hiddenItem' to do some measuring before they layout the *real* MenuItemRenderer
             for each(var match : UIComponent in matches)
             {
                 if (match.name != "hiddenItem")
                 {
                     return match;
                 }
             }
             return null;
        }
        
        /**
         * Finds the first component that has the specified text showing.
         */
        public function delayedWithText(text : String) : Function
        {
            return function() {return withText(text);};
        }
        
        public function allWithAll(properties : Object) : Array
        {
            var foundItems : Array = new Array();
            
            eachChild(allLayersView, function(node : DisplayObject, foundItemsBucket : Array) : Boolean {
                for (var propName : String in properties)
                {
                    if (node.hasOwnProperty(propName))
                    {
                        if (node[propName] == properties[propName])
                        {
                            foundItemsBucket.push(node);
                            return false;
                        }
                        else
                        {
                            // If we haven't matched on all properties, just skip to the next node
                            return true;
                        }
                    }    
                    else
                    {
                        // If we haven't matched on all properties, just skip to the next node
                        return true;
                    }
                }
                
                return true;
            }, [foundItems]); 
            
            return componentize(foundItems);
        }
        
        public function allWithAny(properties : Object, excludes : Object = null) : Array
        {
            var foundItems : Array = new Array();
            
            eachChild(allLayersView, function(node : DisplayObject, foundItemsBucket : Array) : Boolean {
                for (var propName : String in properties)
                {
                    if (node.hasOwnProperty(propName))
                    {
                        trace(node[propName]);
                        if (node[propName] == properties[propName])
                        {
                            trace("Found element matching property: " + propName + " [" + node + "]");
                            foundItemsBucket.push(node);
                        }
                    }    
                }
                
                return true;
            }, [foundItems]); 
            
            return componentize(foundItems);
        }
        
        /**
         * Recurses through the display graph starting with the <code>parent</code> object, invoking the <code>func</code> function
         * on every node that is at least a <code>DisplayObject</code>.  
         * 
         * <p>
         * The function <code>func</code> must have a return type of <code>Boolean</code>.  If the <code>func</code> function 
         * returns false, the <code>eachChild</code> function will halt recursing.  Otherwise, it will continue recursing through
         * the tree.
         * </p>
         * 
         * <p>
         * The function first parameter <em>MUST</em> be of type <code>DisplayObject</code>.  That parameter is the current node
         * of the tree being recursed.  Additional parameters can be declared on the <code>func</code> function but they must
         * be passed to the <code>eachChild</code> function as an Array.   
         * </p>
         * 
         * @parameter parent where to start recursing 
         * @parameter func function to get invoked on every node in display tree
         * @parameter functionArgs additional arguments to pass to func function 
         */
        public function eachChild(parent : DisplayObjectContainer, nodeFunction : Function, functionArgs : Array) : void
        {
            var args : Array = new Array();
            args.push(parent);
            
            if (!nodeFunction.apply(null, args.concat(functionArgs)))
            {
                return;
            }
            
            var childList : Object;
            if (parent is Container)
            {
                childList = (parent as Container).rawChildren;
            }
            else
            {
                childList = parent;
            }
               
            for (var i : int = 0; i < childList.numChildren; i++)
            {
                var child : DisplayObject = childList.getChildAt(i);
                if (child is DisplayObjectContainer)
                {
                   eachChild(child as DisplayObjectContainer, nodeFunction, functionArgs); 
                }
                else
                {
                    args[0] = child;
                    if (!nodeFunction.apply(null, args.concat(functionArgs)))
                    {
                        return;
                    }
                }
            }    
            
        }
        
        /**
         * Finds the first parent of the target that is a <code>UIComponent</code> or itself if the target is a <code>UIComponent</code>.
         */
        public function findUIComponentParent(target : DisplayObject) : UIComponent
        {
            if (target is UIComponent)
            {
                return target as UIComponent;
            }
            
            if (target.parent)
            {
                if (target.parent is UIComponent)
                {
                    return target.parent as UIComponent;    
                }
                else
                {
                    return findUIComponentParent(target.parent);
                }
            }
            
            throw new Error("Could not find a UIComponent in the whole lot of 'em.");
        }
    }
}
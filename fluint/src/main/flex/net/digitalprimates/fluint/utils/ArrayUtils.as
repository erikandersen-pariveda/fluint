package net.digitalprimates.fluint.utils
{
    import mx.collections.ICollectionView;
    import mx.collections.IViewCursor;
    import mx.utils.ObjectUtil;
    
    import net.digitalprimates.fluint.assertion.AssertionFailedError;
    
    public class ArrayUtils
    {
        public function ArrayUtils()
        {
        }
        
        /**
        * Returns the objects in the source <code>collection</code> that have the same properties as the source <code>object</code>. 
        */
        public static function matchOnIncludes(object : Object, collection : ICollectionView, includes : Array = null) : Array {
            var matches : Array = new Array();

            var view : IViewCursor = collection.createCursor();
            for (;!view.afterLast && !view.beforeFirst; view.moveNext()) {
                
                var element : Object = view.current;
                var mismatchFound : Boolean = false;
                var prop : String;
                if (includes != null) {
                    for each(prop in includes) {
                        if (!(element.hasOwnProperty(prop) && ObjectUtil.compare(element[prop], object[prop]) == 0))
                        {
                            mismatchFound = true;
                            break;
                        }
                    }    
                
                } else {
                    for (prop in object) {
                        if (!(element.hasOwnProperty(prop) && ObjectUtil.compare(element[prop], object[prop]) == 0)) {
                            mismatchFound = true;
                            break;
                        }
                    }
                }
                
                if (!mismatchFound) {
                    matches.push(element);
                }
            }
            return matches;
        }
        
        public static function exclusiveMatchOnIncludes(object : Object, collection : ICollectionView, includes : Array = null) : Object {
            var matches : Array = matchOnIncludes(object, collection, includes);
            if (matches.length == 0) {
                throw new AssertionFailedError("Expected to find exclusive match on [" + object + "] but found none.");
            } 
            else if (matches.length > 1) {
                throw new AssertionFailedError("Expected to find exclusive match on [" + object + "] but found " + matches.length + ".");
            }
            
            return matches[0];
        }
    }
}
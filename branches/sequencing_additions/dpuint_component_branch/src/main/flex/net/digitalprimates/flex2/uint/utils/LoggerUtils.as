package net.digitalprimates.flex2.uint.utils
{
  import mx.core.UIComponent;
  import mx.rpc.http.HTTPService;
  
  public class LoggerUtils
  {
    /**
     * Displays a friendly, concise name that is useful for logging.
     */
    public static function friendlyName(object : Object) : String
    {
        if (object == null)
        {
            return "null";
        }
        
        if (object.hasOwnProperty("id") && object["id"])
        {
            return object["id"];
        }
        else if (object.hasOwnProperty("name") && object["name"])
        {
            return object["name"];
        }
        else if (object is HTTPService)
        {
            return (object as HTTPService).url;
        }
        else if (object is Function)
        {
            return "Function (Delayed Reference)";
        }
        else
        {
            return object.toString();
        }
    }

  }
}
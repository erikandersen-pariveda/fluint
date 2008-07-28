package directoryParser
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;

	public class DirectoryParser extends EventDispatcher
	{
		private var ac:Array = new Array();
		private var pendingDirs:int =1;
		private var rootDir:String;
		public static const RECURSE_DONE:String="recurseDone";
		public function DirectoryParser(dir:String,target:IEventDispatcher=null)
		{
			super(target);
			this.rootDir=dir;
		}
		public function parse():void{
			readDir(rootDir);
		}
		protected function readDir(path:String):void{
			trace("readDir:"+path);
			var dir:File = new File(path);
			dir.addEventListener(FileListEvent.DIRECTORY_LISTING,handleDirectoryListing);
			dir.getDirectoryListingAsync();
			
		}
		protected function handleDirectoryListing( event:FileListEvent ):void{
		   	trace("handleDirectoryListing");
		    for each ( var item:File in event.files ){
		    	
				if(item.extension == "swf"){
					ac.push(item);
					trace(item.nativePath);
				}  else if (item.isDirectory){
					pendingDirs++;
					readDir(item.nativePath);
				}
				
		    }
		    pendingDirs--;
		    if(!pendingDirs){
		    	this.dispatchEvent(new Event(RECURSE_DONE));
		    	trace(ac.length);
		    }
		}
		public function get filesArray():Array{
			return this.ac;
		}

	}
}
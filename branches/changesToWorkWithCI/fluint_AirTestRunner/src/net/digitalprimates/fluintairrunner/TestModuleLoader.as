package net.digitalprimates.fluintairrunner
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   import mx.core.IFlexModuleFactory;
   import mx.events.ModuleEvent;
   
   import net.digitalprimates.fluint.modules.ITestSuiteModule;
   
   public class TestModuleLoader extends EventDispatcher
   {
      private var _context : LoaderContext;
      private var _loader : Loader;
      
      public var file : File;
      public var suites : Array;
      
      public function TestModuleLoader(context : LoaderContext)
      {
         _context = context;
         suites = new Array();
      }

      public function load() : void
      {
         _loader = new Loader();

         _loader.contentLoaderInfo.addEventListener(Event.INIT, function(event : Event) : void {
            var loaderInfo : LoaderInfo = LoaderInfo(event.currentTarget);
            loaderInfo.content.addEventListener("ready", moduleReady);
            trace("MODULE INIT");
         });
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, moduleComplete);
		   _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, moduleProgress);
		   _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, moduleError);
		   _loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, moduleError);
		   
		   _loader.loadBytes(readBytes(this.file), _context);
      }

      private function readBytes(module : File) : ByteArray
      {
         var byteArray :ByteArray = new ByteArray();
         
         var stream : FileStream = new FileStream();
		   stream.open(module, FileMode.READ );
			stream.readBytes(byteArray);
			
			return byteArray;
      }

      private function moduleReady(event : Event)  : void
      {
         var moduleEvent : ModuleEvent = null;
         
         try
         {
            //Am I going to be able to load this swf as a module and as a ITestSUiteModule?
            var factory : IFlexModuleFactory = event.currentTarget as IFlexModuleFactory;
            var tsModule : ITestSuiteModule = factory.create() as ITestSuiteModule;
            this.suites = tsModule.getTestSuites();
            
            moduleEvent = new ModuleEvent(ModuleEvent.READY, event.bubbles, event.cancelable);
         }
         catch(e : Error)
         {
            moduleEvent = new ModuleEvent(ModuleEvent.ERROR, event.bubbles, event.cancelable);
            moduleEvent.errorText = e.message;
         }
         
	      dispatchEvent(moduleEvent);
      }
      
      private function moduleProgress(event : ProgressEvent) : void
      {
         var moduleEvent:ModuleEvent = new ModuleEvent(ModuleEvent.PROGRESS, event.bubbles, event.cancelable);
         moduleEvent.bytesLoaded = event.bytesLoaded;
         moduleEvent.bytesTotal = event.bytesTotal;
         
         dispatchEvent(moduleEvent);
      }
      
      private function moduleComplete(event : Event) : void
      {
         var loaderInfo:LoaderInfo = LoaderInfo( event.currentTarget );
       
         var moduleEvent : ModuleEvent = new ModuleEvent(ModuleEvent.PROGRESS, event.bubbles, event.cancelable);
         moduleEvent.bytesLoaded = loaderInfo.loader.contentLoaderInfo.bytesLoaded;
         moduleEvent.bytesTotal = loaderInfo.loader.contentLoaderInfo.bytesTotal;
         
         dispatchEvent(moduleEvent);
      }
      
      private function moduleError(event : ErrorEvent) : void
      {
         var moduleEvent:ModuleEvent = new ModuleEvent(ModuleEvent.ERROR, event.bubbles, event.cancelable);
         moduleEvent.bytesLoaded = 0;
         moduleEvent.bytesTotal = 0;
         moduleEvent.errorText = event.text;
         dispatchEvent(moduleEvent);
      }
   }
}
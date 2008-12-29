package net.digitalprimates.fluintairrunner
{
   import flash.events.EventDispatcher;
   import flash.filesystem.File;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   import mx.events.ModuleEvent;
   
   import net.digitalprimates.fluint.tests.TestSuite;
   
   public class TestModuleManager extends EventDispatcher
   {
      private var _context : LoaderContext;
      private var _loaders : Array;
      private var _suites : Array;
      private var _moduleCount : Number;
      
      public function TestModuleManager()
      {
         _context = new LoaderContext();
			_context.allowLoadBytesCodeExecution = true;
			_context.applicationDomain = ApplicationDomain.currentDomain;
			
			_loaders = new Array();
			
			_suites = new Array();
      }
      
      public function loadModules(modules : Array) : void
      {
         _moduleCount = modules.length;
         
         for each(var module : File in modules)
         {
            var loader : TestModuleLoader = new TestModuleLoader(_context);
            loader.file = module;
            loader.addEventListener(ModuleEvent.READY, newSuitesAvailable);
            loader.addEventListener(ModuleEvent.ERROR, moduleLoadError);
            
            _loaders.push(loader);
            
            loader.load() 
         }
      }
      
      private function newSuitesAvailable(event : ModuleEvent) : void
      {
         _moduleCount--;
         
         var suites : Array = TestModuleLoader(event.currentTarget).suites;
         for each(var suite : TestSuite in suites)
         {
            _suites.push(suite);
         }
         
         if(_moduleCount == 0)
         {
            var tmEvent : TestModuleEvent = new TestModuleEvent(TestModuleEvent.TEST_MODULES_READY);
            tmEvent.suites = _suites;
            dispatchEvent(tmEvent);
         }
      }
      
      private function moduleLoadError(event : ModuleEvent) : void
      {
         trace(event.errorText);
      }

   }
}
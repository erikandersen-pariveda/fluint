package net.digitalprimates.fluintairrunner
{
   import flash.events.EventDispatcher;
   import flash.filesystem.File;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   import mx.events.ModuleEvent;
   import mx.logging.ILogger;
   
   import net.digitalprimates.fluint.tests.TestSuite;
   
   [Event(name="testModulesReady", type="net.digitalprimates.fluint.TestModuleEvent")]
   [Event(name="noTestModulesFound", type="net.digitalprimates.fluint.TestModuleEvent")]
   public class TestModuleManager extends EventDispatcher
   {
      private var _logger : ILogger;
      private var _context : LoaderContext;
      private var _loaders : Array;
      private var _suites : Array;
      private var _moduleCount : Number;
      private var _modulesToRun : Number = 0;
      
      public function TestModuleManager(logger : ILogger)
      {
         _logger = logger;
         
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
            var loader : TestModuleLoader = new TestModuleLoader(_logger, _context);
            loader.file = module;
            loader.addEventListener(ModuleEvent.READY, newSuitesAvailable);
            loader.addEventListener(ModuleEvent.ERROR, moduleLoadError);
            
            _loaders.push(loader);
            
            loader.load() 
         }
      }
      
      private function newSuitesAvailable(event : ModuleEvent) : void
      {
         _logger.debug("SWF LOADED");
         
         var suites : Array = TestModuleLoader(event.currentTarget).suites;
         for each(var suite : TestSuite in suites)
         {
            _suites.push(suite);
         }
         
         _logger.debug(suites.length + " TEST SUITE(S) FOUND");
         if(suites.length > 0)
         {
            _modulesToRun++;
         }
         
         decrementModuleCount();
      }
      
      private function moduleLoadError(event : ModuleEvent) : void
      {
         decrementModuleCount();         
         _logger.debug("SWF LOAD ERROR: " + event.errorText);
      }
      
      private function decrementModuleCount() : void
      {
         _moduleCount--;
         
         if(_moduleCount == 0 && _modulesToRun > 0)
         {
            var tmEvent : TestModuleEvent = new TestModuleEvent(TestModuleEvent.TEST_MODULES_READY);
            tmEvent.suites = _suites;
            dispatchEvent(tmEvent);
         }
         else if(_moduleCount == 0 && _modulesToRun == 0)
         {
            dispatchEvent(new TestModuleEvent(TestModuleEvent.NO_TEST_MODULES_FOUND));
         }
      }

   }
}
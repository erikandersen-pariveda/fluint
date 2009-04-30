package net.digitalprimates.fluintairrunner
{
   import flash.events.Event;
   import flash.events.InvokeEvent;
   import flash.filesystem.File;
   import flash.utils.Dictionary;
   
   import mx.core.WindowedApplication;
   import mx.logging.ILogger;
   
   import net.digitalprimates.fluint.ui.TestResultDisplay;
   import net.digitalprimates.fluint.ui.TestRunner;

   public class TestRunnerWindow extends WindowedApplication   
   {
      private const REPORT_FILE_NAME : String = "TEST-AllTests.xml";
      private const DEFAULT_REPORT_DIR : String = "app-storage:/";
      private const RETURN_CODE_SUCCESS : int  = 0;
      private const RETURN_CODE_TESTS_FAILED : int = 1;
      private const RETURN_CODE_MISSING_PARAMETERS : int = 2;
      
      private var _logger : ILogger;
      
      public var disp : TestResultDisplay;
      public var testRunner : TestRunner; 
      
      protected var reportDir : String = null;
      
      private var _workingDir : File;
      private var _fileSet : Array;
      private var _fileSetChange : Boolean = false;
      private var _headless : Boolean = false;
      private var _failOnError : Boolean = false;
      private var _headlessChange : Boolean = false;
      private var _invoked : Boolean = false;

      public function TestRunnerWindow():void
      {
         super();
         this.addEventListener(InvokeEvent.INVOKE,listenToCommandLine);
         _logger = TestRunnerUtils.createLogger(this.className);
      }
      
      [Bindable]
      public function get headless():Boolean
      {
         return _headless;
      }
      
      
      public function set headless(b:Boolean):void
      {
         _headless = b;
         _headlessChange = true;
         invalidateProperties();
      }
      
      [Bindable]
      public function get failOnError():Boolean
      {
         return _failOnError;
      }
      
      
      public function set failOnError(b:Boolean):void
      {
         _failOnError = b;
      }

      [Bindable]
      public function get fileSet():Array
      {
         return _fileSet;
      }
      
      public function set fileSet(value:Array):void
      {
         _fileSet = value;
         _fileSetChange = true;
         
         invalidateProperties();
      }
      
      
      protected override function createChildren():void
      {
         super.createChildren();
         
         if ( !headless ) {
            disp = new TestResultDisplay();
            disp.percentHeight=100;
            disp.percentWidth=100;
            disp.creationPolicy="all";
            this.addChild(disp);
         }
         
         testRunner = new TestRunner();
         testRunner.addEventListener(TestRunner.TESTS_COMPLETE, processResults);
         this.addChild(testRunner);
      }
      
      
      protected override function commitProperties():void
      {
         if( this._headlessChange )
         {
            _logger.debug("headless changed to " + headless);
            
            _headlessChange = false;
            
            if( this.headless )
            {
               nativeWindow.minimize();
            }else{
               nativeWindow.maximize();
            }
         }
         
         if( _fileSetChange )
         {
            _logger.debug("fileSet changed to " + fileSet);
            
            _fileSetChange = false;
            
            parseModules();
         }
      }
      
      protected function listenToCommandLine(event:InvokeEvent):void
      {
        _logger.debug("Arguments: " + event.arguments);
        _workingDir = event.currentDirectory;

        var arguments : Dictionary = TestRunnerUtils.parseArgument(event.arguments);
        
        this.headless = arguments['headless'];
        this.failOnError = arguments['failOnError'];
        this.reportDir = arguments['reportDir'];
        this.fileSet = arguments['fileSet'];

        _logger.debug("headless: " + headless);
        _logger.debug("failOnError: " + failOnError);
        _logger.debug("reportDir: '" + this.reportDir + "'");
        _logger.debug("fileSet: '" + this.fileSet + "'");
        
        if (!fileSet)
        {
           _logger.debug("fileSet argument is required.");
          exitWithFailure(RETURN_CODE_MISSING_PARAMETERS);
        }
      }

      private function parseModules():void
      {
         try
         {
            var fileList : Array = fileSet.map(
               function (item:*, index:int, array:Array) : File
               {
                  var file : File = _workingDir.resolvePath(item);
                  _logger.debug("fileSet path: " + file.nativePath);
                  return file;
               }
            );
            
            var swfList : Array = TestRunnerUtils.recurseDirectories(fileList);
            
            _logger.debug("FOUND " + swfList.length + " SWF(S)");
   
            if(swfList.length == 0)
            {
               _logger.debug("No SWFs found!");
               exitWithFailure(RETURN_CODE_MISSING_PARAMETERS);
            }
            
            loadExternalTests( swfList );
         }
         catch(e : Error)
         {
            _logger.error("FAILURE MOST LIKELY DUE TO UNRECOVERABLE RECURSION LOOP. fileSet = [" + fileSet + "]");
         }
      }
      
      protected function loadExternalTests(swfList : Array) : void
      {         
         var manager : TestModuleManager = new TestModuleManager(_logger);
         
         manager.addEventListener(TestModuleEvent.TEST_MODULES_READY, function(event : TestModuleEvent) : void{
            testRunner.startTests(event.suites);
         });
         
         manager.addEventListener(TestModuleEvent.NO_TEST_MODULES_FOUND, function(event : TestModuleEvent) : void{
            _logger.debug("No valid module SWFs found.");
            exitWithFailure(RETURN_CODE_MISSING_PARAMETERS);
         });
         
         _logger.debug("ATTEMPTING TO LOAD " + swfList.length + " SWF(S)");
                  
         manager.loadModules(swfList);
      }

      protected function processResults(event:Event):void
      {
         var results : XML = testRunner.xmlResults;
         var dir : File = new File(DEFAULT_REPORT_DIR);
         
         if(reportDir)
         {
            dir = _workingDir.resolvePath(reportDir);
            
            //Can we actually use the directory?
            if(!dir.exists)
            {
               _logger.debug(dir.nativePath + " does not exist; using " + DEFAULT_REPORT_DIR);
               dir = new File(DEFAULT_REPORT_DIR);
            }
         }
         
         TestRunnerUtils.writeToFile(results, dir, this.REPORT_FILE_NAME);
         
         if(headless)
         {
            if(testsFailed(results) && failOnError)
            {
               exitWithFailure();
            }
            else
            {
               exitWithSuccess();
            }
         }
      }

      private function testsFailed(testResults : XML) : Boolean
      {
         if(testResults.@failureCount 
            && testResults.@errorCount 
            && testResults.@failureCount == 0 
            && testResults.@errorCount == 0)
         {
            return false;
         }
         else
         {
            return true;
         }
      }
      
      private function exitWithFailure(exitCode : int = RETURN_CODE_TESTS_FAILED) : void
      {
         _logger.debug("FAILURE -- EXIT CODE: " + exitCode);
         nativeApplication.exit(exitCode);
      }
      
      private function exitWithSuccess() : void
      {
         _logger.debug("SUCCESS -- EXIT CODE: " + RETURN_CODE_SUCCESS);
         nativeApplication.exit(RETURN_CODE_SUCCESS);
      }
   }
}

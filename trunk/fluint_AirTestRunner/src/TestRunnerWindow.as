package
{
	import directoryParser.DirectoryParser;
	
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert;
	import mx.core.WindowedApplication;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	
	import net.digitalprimates.fluint.ui.TestResultDisplay;
	import net.digitalprimates.fluint.ui.TestRunner;

	public class TestRunnerWindow extends WindowedApplication	
	{
		private var fluintLogger:ILogger;
		
		public var disp:TestResultDisplay;
		public var testRunner:TestRunner; 
		protected var  libraryArray:Array = new Array();
		
		protected var reportDir:String = null;
		private var _fileSet:Array;
		private var _fileSetChange:Boolean = false;
		private var _headless:Boolean = false;
		private var _headlessChange:Boolean = false;
		
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
		public function get fileSet():Array
		{
			return _fileSet;
		}
		
		public function set fileSet(files:Array):void
		{
			_fileSet = files;
			_fileSetChange = true;
			invalidateProperties();
		}
		
		
		protected function startTestProcess( event:Event ):void 
		{
			var error:String = "start test process must be overriden in implementing sub class"
			fluintLogger.error(error);
			setStyle("showFlexChrome",false);
			throw new Error(error);
		}
		
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			disp = new TestResultDisplay();
			disp.percentHeight=100;
			disp.percentWidth=100;
			disp.creationPolicy="all";
			this.addChild(disp);
			
			testRunner = new TestRunner();
			testRunner.addEventListener(TestRunner.TESTS_COMPLETE, writeFile);
			this.addChild(testRunner);
		}
		
		
		protected override function commitProperties():void
		{
			if( this._headlessChange )
			{
				_headlessChange = false;
				if( this.headless )
				{
					//disp.creationPolicy="none";
					nativeWindow.minimize();
				}else{
					//disp.creationPolicy="all";
					nativeWindow.maximize();
				}
				
				// initialize the ui			
				//setStyle("showFlexChrome",true);
				//disp.createComponentsFromDescriptors(true);				
			}
			
			if( _fileSetChange )
			{
				_fileSetChange = false;
				parseModules();
				fluintLogger.debug("fileSet directories=" +fileSet.length);	
			}
		}
		
		
		protected function listenToCommandLine(event:InvokeEvent):void
		{
			for(var i:int=0;i<event.arguments.length;i++)
			{
				switch(event.arguments[i].toLowerCase()){
					case "-headless":
						this.headless=true;												
						break;
						
					case "-reportdir":
						this.reportDir= event.arguments[i+1];
						break;
						
					case "-modules":
						fileSet = String(event.arguments[i+1]).split(";");
						break;		
				}
			}
		}


		private function parseModules():void
		{
			for(var i:int=0;i<fileSet.length;i++)
			{
				var parser:DirectoryParser = new DirectoryParser(fileSet[i]);
					parser.addEventListener(DirectoryParser.RECURSE_DONE,addFiles);
					parser.parse();
			}
		}


		private function addFiles(event:Event):void
		{
			var files:Array = (event.target as DirectoryParser).filesArray;
			if(!libraryArray.length)
			{
				libraryArray = files;
			} else {
				libraryArray = libraryArray.concat(files);
			}
			
			fluintLogger.debug("fileSet files=" +files.length);
		}
		
		
		protected function writeFile(event:Event):void
		{
			if( reportDir != null && reportDir != "" )
			{
				var dir:File = new File(reportDir);
				var file:File = dir.resolvePath( 'fluintResults.xml' );
				var fs:FileStream = new FileStream();
				fs.open(file,FileMode.WRITE);
				fs.writeMultiByte(testRunner.xmlResults,File.systemCharset);
				fs.close();
			}
			
			if(headless)
			{
				this.close();
			}
		}
		
		
		private function initializeLogging():void
		{
			// Create a target.
            var logTarget:TraceTarget = new TraceTarget();
            // Log all log levels.
            logTarget.level = LogEventLevel.DEBUG;

            // Add date, time, category, and log level to the output.
            logTarget.includeDate = true;
            logTarget.includeTime = true;
            logTarget.includeCategory = true;
            logTarget.includeLevel = true;

            // Begin logging.
            Log.addTarget(logTarget);
			fluintLogger = Log.getLogger( this.className );	
		}
		
		
		public function TestRunnerWindow():void
		{
			super();

			this.addEventListener(InvokeEvent.INVOKE,listenToCommandLine);
			this.addEventListener(FlexEvent.CREATION_COMPLETE,startTestProcess);
			
			initializeLogging();
		}
	}
}
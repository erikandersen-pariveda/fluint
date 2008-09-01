package
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import mx.core.IFlexModuleFactory;
	import mx.core.WindowedApplication;
	import mx.events.ModuleEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	
	import net.digitalprimates.fluint.modules.ITestSuiteModule;
	import net.digitalprimates.fluint.tests.TestSuite;
	import net.digitalprimates.fluint.ui.TestResultDisplay;
	import net.digitalprimates.fluint.ui.TestRunner;

	public class TestRunnerWindow extends WindowedApplication	
	{
		private var fluintLogger:ILogger;
		
		public var disp:TestResultDisplay;
		public var testRunner:TestRunner; 
		
		protected var reportDir:String = null;
		private var _fileSet:Array;
		private var _fileSetChange:Boolean = false;
		private var _headless:Boolean = false;
		private var _headlessChange:Boolean = false;
		
		private var _pendingModuleCount:int = 0;
		private var _loaders:Array = new Array();
		private var _suites:Array = new Array();

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
			testRunner.startTests( _suites );
			//_loaders = new Array();
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
			var fileList:Array = new Array();
			for(var i:int=0;i<fileSet.length;i++)
			{
				fileList.push( new File( fileSet[i] ) );
			}
			
			var swfList:Array = recurseDirectories( fileList );

			loadExternalTests( swfList );			
		}

		private function recurseDirectories( fileList:Array, swfList:Array=null ):Array {
			if ( !swfList ) {
				swfList = new Array();
			}
			
			for ( var i:int=0; i<fileList.length; i++ ) {
				var file:File = fileList[ i ];
				
				if ( file.isDirectory ) {
					recurseDirectories( file.getDirectoryListing(), swfList );
				} else if ( file.exists && file.extension == "swf") {
					var fileFound:Boolean = false;
					for ( var j:int=0; j<swfList.length; j++ ) {
						if ( File( swfList[ j ] ).nativePath == file.nativePath ) {
							fileFound = true;
							break;	
						}
					}
					
					if ( !fileFound ) {
						swfList.push( file );
					}
				} 
			}
			
			return swfList;
		}

		private function loadExternalTests( swfList:Array ):void {
			var loader:Loader;
			var byteArray:ByteArray;
			var stream:FileStream;
			
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
			loaderContext.applicationDomain = ApplicationDomain.currentDomain;

			for ( var i:int=0; i<swfList.length; i++ ) {
				stream = new FileStream();
				stream.open( swfList[ i ], FileMode.READ );
				
				byteArray = new ByteArray();
				stream.readBytes( byteArray );
				
				loader = new Loader();
				_loaders.push( loader ); 
				_pendingModuleCount++;

		        loader.contentLoaderInfo.addEventListener( Event.INIT, initHandler);
		        loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeHandler);
		        loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, progressHandler);
		        loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, errorHandler);
		        loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, errorHandler);

				loader.loadBytes( byteArray, loaderContext );
			}
		}

	    public function initHandler(event:Event):void
	    {
	    	var loaderInfo:LoaderInfo = LoaderInfo( event.currentTarget );
	    	loaderInfo.content.addEventListener("ready", readyHandler);
	    }
	
	    /**
	     *  @private
	     */
	    public function progressHandler(event:ProgressEvent):void
	    {
	        var moduleEvent:ModuleEvent = new ModuleEvent(
	            ModuleEvent.PROGRESS, event.bubbles, event.cancelable);
	        moduleEvent.bytesLoaded = event.bytesLoaded;
	        moduleEvent.bytesTotal = event.bytesTotal;
	        dispatchEvent(moduleEvent);
	    }
	
	    /**
	     *  @private
	     */
	    public function completeHandler(event:Event):void
	    {
	    	var loaderInfo:LoaderInfo = LoaderInfo( event.currentTarget );
	
	        var moduleEvent:ModuleEvent = new ModuleEvent(
	            ModuleEvent.PROGRESS, event.bubbles, event.cancelable);
	        moduleEvent.bytesLoaded = loaderInfo.loader.contentLoaderInfo.bytesLoaded;
	        moduleEvent.bytesTotal = loaderInfo.loader.contentLoaderInfo.bytesTotal;
	        dispatchEvent(moduleEvent);
	    }
	
	    /**
	     *  @private
	     */
	    public function errorHandler(event:ErrorEvent):void
	    {
	        var moduleEvent:ModuleEvent = new ModuleEvent(
	            ModuleEvent.ERROR, event.bubbles, event.cancelable);
	        moduleEvent.bytesLoaded = 0;
	        moduleEvent.bytesTotal = 0;
	        moduleEvent.errorText = event.text;
	        dispatchEvent(moduleEvent);
	
	        //trace("child load of " + _url + " generated an error " + event);
	    }
	
	    /**
	     *  @private
	     */
	    public function readyHandler(event:Event):void
	    {
			_pendingModuleCount--;

	    	var factory:IFlexModuleFactory = event.currentTarget as IFlexModuleFactory;
	        //trace("child load of " + _url + " is ready");
	
			if ( factory ) {
		        var child:ITestSuiteModule = factory.create() as ITestSuiteModule;

		        if (child)
		        {
		        	var childTestSuites:Array = child.getTestSuites();
		        	
		        	for ( var i:int=0; i<childTestSuites.length; i++ ) {
		        		if ( childTestSuites[ i ] is TestSuite ) {
			        		_suites.push( childTestSuites[ i ] );
		        		}
		        	}
		        }
			}

	        dispatchEvent(new ModuleEvent(ModuleEvent.READY));

			if ( _pendingModuleCount == 0 ) {
				startTestProcess( event );
			}
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
			//this.addEventListener(FlexEvent.CREATION_COMPLETE,startTestProcess);
			
			initializeLogging();
		}
	}
}
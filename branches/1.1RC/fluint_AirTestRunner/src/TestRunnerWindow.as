package
{
	import flash.display.DisplayObject;
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
	import mx.managers.ISystemManager;
	
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
		
		public function set fileSet(value:Array):void
		{
			_fileSet = value;
			_fileSetChange = true;
			/*
			for ( var i:int=0;i<value.length;i++ ) {
				Alert.show( i + ': ' + value[i] );	
			} 
			*/
			
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
				//Alert.show( i + ': ' + event.arguments[i] );	

				var headlessExp:RegExp = new RegExp( '^-headless' );
				var reportExp:RegExp = new RegExp( '^-reportDir' );
				var filesetExp:RegExp = new RegExp( '^-fileSet' );

				if ( headlessExp.test( event.arguments[i] ) ) {
					this.headless = true;	
				}

				if ( reportExp.test( event.arguments[i] ) ) {
					var reportArray:Array = event.arguments[i].split( "=" );
					if ( reportArray.length == 2 ) {
						var reportString:String = reportArray[1];
						if ( reportString.length > 3 ) {
							reportString = reportString.substr( 1, reportString.length - 2 );
						}

						this.reportDir = reportString; 
					}
				}

				if ( filesetExp.test( event.arguments[i] ) ) {
					var filesetArray:Array = event.arguments[i].split( "=" );
					if ( filesetArray.length == 2 ) {
						var filesetString:String = filesetArray[1];
						if ( filesetString.length > 3 ) {
							filesetString = filesetString.substr( 1, filesetString.length - 2 );
						}

						fileSet = filesetString.split(",");						 
					}
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
	        
	    	//if we loaded something that is not a Flex Module, we will try to handle it right now.
	    	//Modules will broadcast a read event and shouldn't be touched until that point, if this swf does not have
	    	//that content-type, then let's just manually call the readyHandler to try to deal with it.
	    	if ( loaderInfo ) {
	    		if ( ( loaderInfo.content is ISystemManager ) ) {
	    			createSubApp( loaderInfo.content );
	    		}
	    	}
	    	 	
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
	        
	        //Decrement the pending count on an error so that we still load and run the others 
	        _pendingModuleCount--;
	
	        //trace("child load of " + _url + " generated an error " + event);
	    }
	
		private function getLoaderURL( obj:DisplayObject ):String {
	    	var url:String = "";
	    	if ( obj && obj.loaderInfo ) {
	    		url = obj.loaderInfo.loaderURL;
	    	}
	    	
	    	return url;
		}
	    /**
	     *  @private
	     */
	    public function readyHandler(event:Event):void
	    {
			_pendingModuleCount--;

	    	var factory:IFlexModuleFactory = event.currentTarget as IFlexModuleFactory;

			if ( factory ) {
				var instance:* = factory.create();
		        var child:ITestSuiteModule = instance as ITestSuiteModule;

		        dispatchEvent(new ModuleEvent(ModuleEvent.READY));
		        
		        if (child) {
		        	createModule( child );
		        } else {
       		    	fluintLogger.debug("Encountered a Flex Module SWF file that does not Implement ITestSuiteModule. Ignoring Module ");
		        }
		 	}
	    }

	    public function createSubApp( app:DisplayObject ):void
	    {
	    	_pendingModuleCount--;

			//need a way to tie together urls to provide better errors here	    	
	    	fluintLogger.debug("Encountered a SWF file that is not an IFlexModuleFactory, ignoring file " );
	    	return;
	    	
	    	if ( app ) {	    		
	    		//this doesn't yet work but it is being prepared to support sub-applications with the marshall plan
	    		var instance:* = (app as ISystemManager).create();
	    		var child:ITestSuiteModule =  instance as ITestSuiteModule;
	    		
	    		if ( child ) {
		        	createModule( child );
	    		} else {
	    			fluintLogger.debug("Encountered a SWF file that is not an IFlexModuleFactory nor a sub-application supporting ITestModule");
	    		}
	    	}
	    }
	    
	    private function createModule( child:ITestSuiteModule ):void {

        	var childTestSuites:Array = child.getTestSuites();
        	
        	for ( var i:int=0; i<childTestSuites.length; i++ ) {
        		if ( childTestSuites[ i ] is TestSuite ) {
	        		_suites.push( childTestSuites[ i ] );
        		}
        	}
        	
			if ( _pendingModuleCount == 0 ) {
				startTestProcess( null );
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
package net.digitalprimates.fluintairrunner
{
   import cim.fx.logging.targets.LocalConnectionTarget;
   
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.Dictionary;
   
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.logging.LogEventLevel;
   import mx.logging.targets.TraceTarget;
   
   public class TestRunnerUtils
   {
      private static var _logger : ILogger;
      
      public static function createLogger(className : String) : ILogger
		{
			// Create a trace target and LogBook target
         var logTarget:TraceTarget = new TraceTarget();
         var logbookTarget : LocalConnectionTarget = new LocalConnectionTarget("_fluint");
         
         // Log all log levels.
         logTarget.level = LogEventLevel.DEBUG;
         logbookTarget.level = LogEventLevel.DEBUG;

         // Add date, time, category, and log level to the output.
         logTarget.includeDate = true;
         logTarget.includeTime = true;
         logTarget.includeCategory = true;
         logTarget.includeLevel = true;
         logbookTarget.includeDate = true;
         logbookTarget.includeTime = true;
         logbookTarget.includeCategory = true;
         logbookTarget.includeLevel = true;

         // Begin logging.
         Log.addTarget(logTarget);
         Log.addTarget(logbookTarget);
         
         _logger = Log.getLogger(className);
         
         return _logger;	
		}
		
		public static function parseArgument(arguments : Array) : Dictionary
		{
		   var args : Dictionary = new Dictionary();
		   
		   var headlessExp:RegExp = new RegExp( '^-headless' );
			var failOnErrorExp:RegExp = new RegExp('^-failOnError');
			var reportExp:RegExp = new RegExp( '^-reportDir' );
			var filesetExp:RegExp = new RegExp( '^-fileSet' );
		   
		   for each(var argument : String in arguments)
			{
				if ( headlessExp.test(argument) ) {
					args['headless'] = true;	
				}
				
				if(failOnErrorExp.test(argument)){
				   args['failOnError'] = true;
				}

				if ( reportExp.test(argument) ) {
					var reportArray:Array = argument.split( "=" );
					if ( reportArray.length == 2 ) {
						var reportString:String = reportArray[1];
						if ( reportString.length > 3 ) {
							reportString = reportString.substr( 1, reportString.length - 2 );
						}

						args['reportDir'] = reportString; 
					}
				}

				if ( filesetExp.test(argument) ) {
					var filesetArray:Array = argument.split( "=" );
					if ( filesetArray.length == 2 ) {
						var filesetString:String = filesetArray[1];
						if ( filesetString.length > 3 ) {
							filesetString = filesetString.substr( 1, filesetString.length - 2 );
						}

						args['fileSet'] = filesetString.split(",");						 
					}
				}
			}
			
			return args;
		}
      
      public static function recurseDirectories(fileList:Array, swfList:Array=null) : Array {
			if (!swfList) {
				swfList = new Array();
			}
			
			for each(var file: File in fileList){
				if (file.isDirectory) {
					TestRunnerUtils.recurseDirectories(file.getDirectoryListing(), swfList );
				} 
				else if (file.exists && file.extension == "swf") {
					var fileFound:Boolean = false;
					
					for each(var swf : File in swfList){
						if (swf.nativePath == file.nativePath) {
							fileFound = true;
							break;	
						}
					}
					
					if (!fileFound) {
						swfList.push(file);
					}
				} 
			}
			
			return swfList;
		}
		      
      public static function writeToFile(results : XML, reportDir :String, filename : String) : void
		{
		   if( reportDir != null && reportDir != "" )
			{
				var dir:File = new File(reportDir);
				var file:File = dir.resolvePath(filename);
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeMultiByte(results, File.systemCharset);
				fs.close();
			}
		}
   }
}
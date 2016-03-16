# Testing a DataGrid using the Flex Automation APIs #

In this example we will explore how to combine Fluint with the Flex Automation APIs (http://www.adobe.com/devnet/flex/samples/custom_automated/) to test the contents of a DataGrid.

**Note:** to use these APIs with FlexBuilder 3 you need a FlexBuilder Pro license; to use them with FlexBuilder 2 you need an LCDS license.

Suppose you have a program that creates or reads some data and displays it in a DataGrid, and prior to display it modifies the data that is displayed.  You might like to write a test that verifies that the right values are really displayed.  If you try to write the test program you will notice that using the normal DataGrid and DataGridColumn APIs you can’t do it.  There is no way to read the contents of the cells that are displayed.

That’s where the Automation APIs come in.  These are the APIs that are used by GUI test recording tools like RIATest (http://riatest.com/), and they can also be used with Fluint.  These APIs allow you to read the contents of the grid, after the grid has been displayed.

Here is our grid in Grid1.mxml:
```
<?xml version="1.0" encoding="utf-8"?>
<mx:VBox xmlns:mx="http://www.adobe.com/2006/mxml">

    <mx:Script>
    <![CDATA[
   	    private function artistFunc(data:Object, col:Object):String
	    {
	    	return "artiste: " + data.Artist;	
	    }	    
	]]>
    </mx:Script>
    
    <mx:DataGrid id="srcGrid">
        <mx:columns>
            <mx:DataGridColumn headerText="Artist" 
dataField="Artist"  labelFunction="artistFunc"/>
            <mx:DataGridColumn headerText="Album" dataField="Album"/>
            <mx:DataGridColumn headerText="Price" dataField="Price"/>
        </mx:columns>    
    </mx:DataGrid>    
</mx:VBox>
```

It displays three columns of data, but for one of the columns it has a labelFunction that changes the value of the data to display something different.  Therefore it makes sense to write a unit test that reads the contents of the DataGrid after output, since the program is computing the output.

Here is our Fluint test:
```
package com.makana.tests.portalSuite.tests
{
	import com.makana.tests.portalSuite.tests.Grid1;
	
	import mx.automation.delegates.controls.DataGridAutomationImpl;
	import mx.automation.tabularData.DataGridTabularData;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.events.FlexEvent;
	
	import net.digitalprimates.fluint.sequence.SequenceRunner;
	import net.digitalprimates.fluint.sequence.SequenceSetter;
	import net.digitalprimates.fluint.sequence.SequenceWaiter;
	import net.digitalprimates.fluint.tests.TestCase;


	public class GridTest1 extends TestCase
	{
		private var grid:Grid1;
		
		private const srcArray:Array = 
            [
                {Artist:'Carole King', Album:'Tapestry', Price:11.99},
                {Artist:'Paul Simon', Album:'Graceland', Price:10.99},
                {Artist:'Original Cast', Album:'Camelot', Price:12.99},
                {Artist:'The Beatles', Album:'The White Album', Price:11.99}
            ];
		
		
		override protected function setUp():void {
			grid = new Grid1();				
			grid.addEventListener(FlexEvent.CREATION_COMPLETE, 
        		asyncHandler(pendUntilComplete, 500), false, 0, true );
			addChild(grid);			
		}
		
		[Test]
		public function gridData():void {
		  	var sequence:SequenceRunner = new SequenceRunner(this);
		  	
		  	sequence.addStep(new SequenceSetter(grid.srcGrid, {dataProvider:srcArray}));
			sequence.addStep(new SequenceWaiter(grid.srcGrid, FlexEvent.VALUE_COMMIT, 100));	
				
		  	sequence.addAssertHandler(testGridValues, srcArray);
		  	
		  	sequence.run();		  	
        }
        
        
        private function testGridValues(event:Object, passThroughData:Object):void
        {
		  	var vals:Array = getValuesFromGrid(grid.srcGrid);
		  	assertEquals(srcArray.length, vals.length);
		  	
		  	for (var i:int = 0; i<srcArray.length; i++) {
		  		var expectedData:Object = srcArray[i];
		  		
		  		assertTrue(vals[i] is Array);		  		
		  		var actualRow:Array = vals[i] as Array;
		  		assertEquals("row length " + i + ": ", 3, actualRow.length); 
		  		
		  		assertEquals("Artist in row " + i + ": ", "artiste: " + expectedData.Artist, actualRow[0]);		  		
		  		assertEquals("Album in row " + i + ": ", expectedData.Album, actualRow[1]);		  		
		  		assertEquals("Price in row " + i + ": ", expectedData.Price, actualRow[2]);		  		
		  	}
        }
        
        override protected function tearDown():void {
        	removeChild(grid);
        	grid = null;
        }
        
        private function getValuesFromGrid(grid:DataGrid):Array
        {
        	var automation:DataGridAutomationImpl = grid.automationDelegate as DataGridAutomationImpl; 
        	if (automation == null) {
        		Alert.show("link with automation.swc and automation_agent.swc");
        		return [];
        	} else {
	            var data:DataGridTabularData = automation.automationTabularData as DataGridTabularData;
	            var vals:Array = data.getValues(0, data.numRows-1);
			return vals;
        	}
        }        
	}
}
```

The logic is similar to a lot of the other tests in the Fluint Wiki.  Our test extends TestCase.  SetUp() creates the data.  The main test contains a sequence of operations on the data, including setting the grid’s dataProvider to an array of data declared at the beginning of the test in srcArray.  The sequence concludes with a set of assertions, and then tearDown()  cleans up at the end.  The assertions are all in testGridValues() and they use the same assertTrue() and assertEquals() like in the other Wiki examples.

The one difference is the way in which the values are read from the DataGrid.  This is done in getValuesFromGrid().  The test as written above will actually fail in most environments, unless it is built with the following options :

**Note:** In the following statments, you will need to substitute **FLEX-SDK-PATH** with the path to the files on your system. A default install of Flex 3.2 on a windows machine will place these files in C:\Program Files\Adobe\Flex Builder 3\sdks\3.2.0
```
 -include-libraries 
"FLEX-SDK-PATH\frameworks\libs\automation.swc"  
"FLEX-SDK-PATH\3.2.0\frameworks\libs\automation_agent.swc"
```
When a Flex application is built with these two libraries a "mixin" pattern comes into play.  Each GUI component created by the application loads an associated automationDelegate component.  In our test the DataGrid object loads a  DataGridAutomationImpl object, and this automation object can be used to read the values of the grid.

GetValuesFromGrid() checks that the automationDelegate exists.  If the delegate exists, it uses it to read the values from the grid.  The values are returned as an array of arrays.  The outer arrays are for rows and the inner arrays are for the columns in one row.  Each value is returned as a string.  If the program is not linked with the automation libraries, the automationDelegate is null, the test fails, and an Alert is displayed.

I have tried this technique with DataGrid and AdvancedDataGrid and have succeeded in using the Automation APIs to write useful tests.  With AdvancedDataGrid the mixin automationDelegate is AdvancedDataGridAutomationImpl and the tabular data is AdvancedDataGridTabularData.

-Mitch Gart
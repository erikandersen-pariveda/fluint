package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
  import mx.core.UIComponent;
  import mx.events.FlexEvent;
  import mx.events.ListEvent;
  
  import net.digitalprimates.flex2.uint.tests.ComponentTestCase;
  import net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases.mxml.SimpleDataGrid;
  
  public class TestSimpleDataGrid extends ComponentTestCase
  {
    private var grid : SimpleDataGrid;
    
    private var selectedEmployee : XML = <employee>
                                            <name>Maurice Smith</name>
                                            <phone>555-219-2012</phone>
                                            <email>maurice@fictitious.com</email>
                                            <active>false</active>
                                         </employee>;
    
    public function TestSimpleDataGrid()
    {
      super(function():UIComponent {
        return new SimpleDataGrid();
      });
    }
    
    override protected function uiComponentReady():void 
    {
      this.grid = uiComponent as SimpleDataGrid;
    }
    
    public function testSelectRow() : void {
      selectRow(2, grid.dataGrid);
      
      assertFinished(function():void {
        assertObjectEquals(grid.dataGrid.selectedItem, selectedEmployee);
      	assertObjectEquals(grid.eventsFired, [FlexEvent.VALUE_COMMIT, ListEvent.CHANGE]);
      	
        assertEquals("Maurice Smith", grid.nameLabel.text);
      });
    }

  }
}
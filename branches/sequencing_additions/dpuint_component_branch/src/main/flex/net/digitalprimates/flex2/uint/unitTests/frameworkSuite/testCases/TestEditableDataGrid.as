package net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases
{
  import mx.controls.DataGrid;
  import mx.core.UIComponent;
  
  import net.digitalprimates.flex2.uint.tests.ComponentTestCase;
  import net.digitalprimates.flex2.uint.unitTests.frameworkSuite.testCases.mxml.EditableDataGrid;

  public class TestEditableDataGrid extends ComponentTestCase
  {
    private var editableGrid : EditableDataGrid;
    
    public function TestEditableDataGrid()
    {
      super(function():UIComponent {
        return new EditableDataGrid();
      });
    }
    
    override protected function uiComponentReady():void {
      this.editableGrid = uiComponent as EditableDataGrid;
    }
    
    public function testDeleteButton():void {
      clickOn(elementInRow("deleteButton", 0, editableGrid.dataGrid));
      waitForPopup("Deleted!");
      
      play();
    }
    
    public function testInlineEditing() : void {
      typeInto("Ben Franklin", cell(0, 1, editableGrid.dataGrid));
      unselectCell(editableGrid.dataGrid);
      
      assertFinished(function():void {
                
      });
    }
    
    public function testInlineEditingOnUneditableColumn() : void {
      typeInto("New@Email.com", cell(0, 3, editableGrid.dataGrid));
      unselectCell(editableGrid.dataGrid);
      
      assertFinished(function():void {
                
      });
    }
    
  }
}
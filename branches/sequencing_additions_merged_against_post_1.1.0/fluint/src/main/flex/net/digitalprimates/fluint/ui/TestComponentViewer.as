package net.digitalprimates.fluint.ui
{
    import mx.binding.utils.BindingUtils;
    import mx.containers.Panel;
    import mx.containers.VBox;
    import mx.controls.Alert;
    import mx.controls.HRule;
    import mx.controls.Text;
    import mx.core.Application;
    import mx.core.IChildList;
    import mx.core.ScrollPolicy;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.managers.ISystemManager;
    import mx.managers.PopUpManager;
    
    import net.digitalprimates.fluint.monitor.TestMethodResult;
    import net.digitalprimates.fluint.tests.ComponentTestCase;

    /**
     * Gets initialized for each test case.
     */
    public class TestComponentViewer
    {
        private var testResults : TestResultDisplay;        
        private var moduleTestContainer:Object;
        private var allTestResultsContainer:VBox;
        
        private static var _testComponentViewer : TestComponentViewer;

        public static function instance() : TestComponentViewer {
            if (!_testComponentViewer) {
                _testComponentViewer = new TestComponentViewer();
            }
            
            return _testComponentViewer;
        }

        public function TestComponentViewer()
        {
            this.moduleTestContainer = new Object();
            
            allTestResultsContainer = new VBox();
            allTestResultsContainer.percentWidth = 100;
            allTestResultsContainer.percentHeight = 100;
            allTestResultsContainer.verticalScrollPolicy = ScrollPolicy.AUTO;

            Application.application.addChild(allTestResultsContainer);

            testResults = (Application.application as Application).getChildByName("testResultDisplay") as TestResultDisplay;
            // BindingUtils.bindSetter(testItemSelected, testResults.testTree, "selectedItem");
            // TODO FIx this
        }

        public function setup(_testCase : ComponentTestCase) : void {
            var testContainer : VBox = new VBox();
            testContainer.percentHeight = 100;
            testContainer.percentWidth = 100;

            var testLabel : Text = new Text();
            testLabel.setStyle("fontSize", "14");
            testLabel.setStyle("fontWeight", "bold");
            testLabel.text = _testCase.currentTestName;

            var separator : HRule = new HRule();
            separator.percentWidth = 100;
            
            _testCase.uiComponent.percentHeight = 100;
            _testCase.uiComponent.percentWidth = 100;
            
            testContainer.addChild(testLabel);
            testContainer.addChild(separator);
            testContainer.addChild(_testCase.uiComponent);

            moduleTestContainer[_testCase.currentTestName] = {container:testContainer, testRun:_testCase.currentTestIndex};
            testContainer.addEventListener(FlexEvent.CREATION_COMPLETE, _testCase.asyncHandler(_testCase.creationComplete, 5000));

            // Add to the beginning of the container so you can watch the _uiComponent while it is being tested
            allTestResultsContainer.addChildAt(testContainer, 0);
        }
        
        public function teardown(_testCase : ComponentTestCase) : void {
            
            allTestResultsContainer.removeAllChildren();
            
              // Close all popups so you can see the results.
              var systemManager : ISystemManager = Application.application.systemManager;
              var children : IChildList = systemManager.rawChildren as IChildList;
              
              var removedPopupsPanel : Panel;
              
              for (var i : int = 0; i < children.numChildren; i++) {
                var child : UIComponent = children.getChildAt(i) as UIComponent;
                if (child is Alert && (child as Alert).visible) 
                {
                  if (!removedPopupsPanel) {
                      removedPopupsPanel = new Panel();
                      removedPopupsPanel.title = "Removed Popups";
                      removedPopupsPanel.layout = "vertical";
                      removedPopupsPanel.percentWidth = 100;
                      
                      var testContainer : UIComponent = moduleTestContainer[_testCase.currentTestName].container as UIComponent;
                      testContainer.addChildAt(removedPopupsPanel, testContainer.numChildren - 1);
                  }  
                  
                  var alert : Alert = child as Alert;  
                  var popupText : Text = new Text();
                  popupText.text = alert.text;      
                    
                  removedPopupsPanel.addChild(popupText);
                    
                  trace("Teardown: Removing popup - " + alert.text);
                  PopUpManager.removePopUp(child);
                }
              }   
            }
        

       /**
        * Highlights the selected test items UI container.
        */
        private function testItemSelected(selectedName:String) : void 
        {
            allTestResultsContainer.removeAllChildren();

            // Checking that we're on an actual test result, and not one of the grouping nodes.            
            var testResult : TestMethodResult = testResults.testTree.selectedItem as TestMethodResult
            if (!testResult) {
                var message : Text = new Text();
                message.setStyle("fontSize", "16");
                message.text = "Select an individual test case to see its final state.";

                allTestResultsContainer.addChild(message);
            } 
            else {
                // Apply style to selected test
                var testName : String = testResult.metadata.@name;
                var testElement : Object = moduleTestContainer[testName];

                if (testElement) {
                    var testContainer : UIComponent = (testElement.container as UIComponent);
                    testContainer.setStyle("borderStyle", "solid");
                    testContainer.setStyle("borderColor", testResult.error || testResult.failed ? "red" : "green");
                    testContainer.setStyle("borderThickness", "4");
                    
                    allTestResultsContainer.addChild(testContainer);    
                
                } else {
                    var errorMsg : Text = new Text();
                    errorMsg.setStyle("fontSize", "16");
                    errorMsg.text = "Viewing was not enabled for this component.";
                    
                    allTestResultsContainer.addChild(errorMsg);
                }
            }
        }
    }
}
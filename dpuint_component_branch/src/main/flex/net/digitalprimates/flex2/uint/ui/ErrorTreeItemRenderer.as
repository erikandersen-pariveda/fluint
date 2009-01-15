/**
 * Copyright (c) 2007 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/ 
package net.digitalprimates.flex2.uint.ui {
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	
	import net.digitalprimates.flex2.uint.monitor.ITestResult;
	import net.digitalprimates.flex2.uint.monitor.ITestResultContainer;
	import net.digitalprimates.flex2.uint.monitor.TestStatus;

	/** 
	 * A TreeItemRenderer that shows TestSuites, TestCases and TestMethods with 
	 * failures in bold and in red.
	 */
	public class ErrorTreeItemRenderer extends TreeItemRenderer {
        /**
         * @private
         */
        override public function set data(value:Object):void {
            super.data = value;
            
            if ( TreeListData(listData) && ( TreeListData(listData).item is ITestResult ) && ( ITestResult( TreeListData(listData).item ).status == TestStatus.FAILED) ){
                setStyle("color", 0xff0000);
                setStyle("fontWeight", 'bold');
            } else {
                setStyle("color", 0x000000);
                setStyle("fontWeight", 'normal');
            }  
        }

        /**
         * @private
         */
       override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
       		var failureInfo:String;
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            var trc:ITestResultContainer;

            if(super.data) {
                if(TreeListData(listData).hasChildren) {
                	if ( TreeListData(listData).item is ITestResultContainer ) {
                		trc = ITestResultContainer( TreeListData(listData).item );
                		
                		if ( trc.numberOfFailures > 0 ) {
	                		failureInfo = ' ( ' + trc.numberOfFailures + ' )';
                		} else {
                			failureInfo = "";
                		}
	                    label.text =  TreeListData(listData).label + failureInfo;
                	}                	                    
                }
            }
        }
	}
}
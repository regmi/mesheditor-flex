package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.validators.*;
    
    import com.WindowAddVertex_LAYOUT;
    
    public class WindowAddVertex extends WindowAddVertex_LAYOUT
    {
        public function WindowAddVertex():void
        {
            super();
            
            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete);
        }
        
        private function creationComplete(evt:FlexEvent):void
        {
            this.btnAdd.addEventListener(MouseEvent.CLICK, this.btnAddClick);
        }
        
        private function btnAddClick(evt:MouseEvent):void
        {
            var errors:Array = Validator.validateAll(this.numValidator);
            if (errors.length == 0)
            {
                Alert.show("Looks valid to me.", "SUCCESS");
            }
        }
    }
}

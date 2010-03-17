package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.validators.*;
    
    import com.WindowAddVertex_LAYOUT;
    import com.MeshEditorEvent;
    
    public class WindowAddVertex extends WindowAddVertex_LAYOUT
    {
        public function WindowAddVertex():void
        {
            super();
            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete, false, 0, true);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnAdd.addEventListener(MouseEvent.CLICK, this.btnAddClick, false, 0, true);
        }

        private function btnAddClick(evt:MouseEvent):void
        {
            var errors:Array = Validator.validateAll(this.numValidator);
            if (errors.length == 0)
            {
                var meEvt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_SUBMIT);
                meEvt.data = new Object()
                meEvt.data.x = this.txtX.text;
                meEvt.data.y = this.txtY.text;
                this.dispatchEvent(meEvt);

                var closeEvt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
                this.dispatchEvent(closeEvt);
            }
        }
    }
}

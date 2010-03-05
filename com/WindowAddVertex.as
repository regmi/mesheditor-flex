package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.validators.*;
    
    import com.WindowAddVertex_LAYOUT;
    import com.VertexEvent;
    
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
                var vertexEvt:VertexEvent = new VertexEvent(VertexEvent.ADD_VERTEX);
                vertexEvt.data = new Object()
                vertexEvt.data.x = this.txtX.text;
                vertexEvt.data.y = this.txtY.text;
                this.dispatchEvent(vertexEvt);

                var closeEvt:CloseEvent = new CloseEvent("close");
                this.dispatchEvent(closeEvt);
            }
        }
    }
}

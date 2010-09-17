package com.window
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.containers.*;

    import com.window.WindowSelectVertices
    import com.MeshEditorEvent;

    public class WindowAddElement extends WindowSelectVertices
    {
        public function WindowAddElement():void
        {
            super();
            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete, false, 0, true);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.title = "Add Element";
        }

        protected override function btnSelectVertexClick(evt:MouseEvent):void
        {
            if(this.gridAvailableVertices.selectedItem != null && this.selectedVertices.length < 4)
            {
                this.addToSelected();
                
                if(this.selectedVertices.length >= 3)
                {
                    var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_SELECTED);
                    e.data = new Object();


                    e.data.v1 = this.selectedVertices[0];
                    e.data.v2 = this.selectedVertices[1];
                    e.data.v3 = this.selectedVertices[2];

                    if(this.selectedVertices.length == 4)
                    {
                        e.data.v4 = this.selectedVertices[3];
                    }
                    
                    this.dispatchEvent(e);
                }
            }
        }

        protected override function btnDeselectVertexClick(evt:MouseEvent):void
        {
            if(this.gridSelectedVertices.selectedItem != null)
            {
                this.removeFromSelected();

                if(this.selectedVertices.length >= 3)
                {
                    var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_SELECTED);
                    e.data = new Object();

                    e.data.v1 = this.selectedVertices[0];
                    e.data.v2 = this.selectedVertices[1];
                    e.data.v3 = this.selectedVertices[2];

                    if(this.selectedVertices.length == 4)
                        e.data.v4 = this.selectedVertices[3];
                    
                    this.dispatchEvent(e);
                }
            }
        }

        protected override function btnAddClick(evt:MouseEvent):void
        {
            if(this.selectedVertices.length > 2)
            {
                var meEvt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_SUBMITTED);
                meEvt.data = new Object();;

                meEvt.data.v1 = this.selectedVertices[0];
                meEvt.data.v2 = this.selectedVertices[1];
                meEvt.data.v3 = this.selectedVertices[2];
                meEvt.data.material = 0;

                if(this.selectedVertices.length == 4)
                    meEvt.data.v4 = this.selectedVertices[3];

                this.dispatchEvent(meEvt);

                var closeEvt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
                this.dispatchEvent(closeEvt);
            }
        }
    }
}

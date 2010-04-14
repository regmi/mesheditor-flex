package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.containers.*;

    import com.WindowSelectVertices

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
            if(this.gridAvailableVertices.selectedItem != null && this.xmlSelectedVertices.*.length() < 4)
            {
                this.addToSelected();
                
                if(this.xmlSelectedVertices.*.length() >= 3)
                {
                    var vl:Array = [];
                    for each(var v:XML in this.xmlSelectedVertices.vertex)
                    {
                        vl.push({id:v.@id, x:v.x, y:v.y});
                    }
                    
                    var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_SELECTED);
                    e.data = new Object();
                    e.data.vertexList = vl;
                    this.dispatchEvent(e);
                }
            }
        }

        protected override function btnDeselectVertexClick(evt:MouseEvent):void
        {
            if(this.gridSelectedVertices.selectedItem != null)
            {
                this.removeFromSelected();

                if(this.xmlSelectedVertices.*.length() >= 3)
                {
                    var vl:Array = [];
                    for each(var v:XML in this.xmlSelectedVertices.vertex)
                    {
                        vl.push({id:v.@id, x:v.x, y:v.y});
                    }

                    var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_SELECTED);
                    e.data = new Object();
                    e.data.vertexList = vl;
                    this.dispatchEvent(e);
                }
            }
        }

        protected override function btnAddClick(evt:MouseEvent):void
        {
            if(this.xmlSelectedVertices.*.length() > 2)
            {
                var meEvt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_SUBMIT);
                var dta:Object = new Object();
                dta.vertexList = [];
                for each(var v:XML in this.xmlSelectedVertices.vertex)
                {
                    dta.vertexList.push({id:v.@id, x:v.x, y:v.y});
                }
                meEvt.data = dta;
                this.dispatchEvent(meEvt);

                var closeEvt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
                this.dispatchEvent(closeEvt);
            }
        }
    }
}

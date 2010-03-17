package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.containers.*;

    import com.WindowAddElement_LAYOUT

    public class WindowAddElement extends WindowAddElement_LAYOUT
    {
        [Bindable]
        private var xmlAvailableVertices:XML;

        [Bindable]
        private var xmlElementVertices:XML; 

        public function WindowAddElement():void
        {
            super();
            this.xmlAvailableVertices = null;
            this.xmlElementVertices = null;

            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete, false, 0, true);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnAddToElement.addEventListener(MouseEvent.CLICK, this.btnAddToElementClick, false, 0, true);
            this.btnRemoveFromElement.addEventListener(MouseEvent.CLICK, this.btnRemoveFromElementClick, false, 0, true);
            this.btnAdd.addEventListener(MouseEvent.CLICK, this.btnAddClick, false, 0, true);
            
            this.gridAvailableVertices.addEventListener(ListEvent.ITEM_CLICK, this.gridAvailableVerticesItemClick, false, 0, true);
            this.gridElementVertices.addEventListener(ListEvent.ITEM_CLICK, this.gridAvailableVerticesItemClick, false, 0, true);

            if(this.xmlAvailableVertices != null)
                this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
        }

        public function initAvailableVertices(aV:XML):void
        {
            this.xmlAvailableVertices = aV.copy();

            if(this.xmlElementVertices == null)
            {
                this.xmlElementVertices = new XML("<vertices></vertices>");
            }
        }

        public function addAvailableVertex(data:Object):void
        {
            this.appendVertexToXML(this.xmlAvailableVertices, data);
            this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
        }

        public function removeAvailableVertex(data:Object):void
        {
            this.removeVertexFromXML(this.xmlAvailableVertices, data);
            this.removeVertexFromXML(this.xmlElementVertices, data);

            this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
            this.gridElementVertices.dataProvider = this.xmlElementVertices.vertex;
        }

        private function btnAddToElementClick(evt:MouseEvent):void
        {
            if(this.gridAvailableVertices.selectedItem != null && this.xmlElementVertices.*.length() < 4)
            {
                var sv:Object = new Object();
                sv.id = this.gridAvailableVertices.selectedItem.@id;
                sv.x = this.gridAvailableVertices.selectedItem.x;
                sv.y = this.gridAvailableVertices.selectedItem.y;

                this.removeVertexFromXML(this.xmlAvailableVertices, sv);
                this.appendVertexToXML(this.xmlElementVertices, sv);

                this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
                this.gridElementVertices.dataProvider = this.xmlElementVertices.vertex;
                
                if(this.xmlElementVertices.*.length() >= 3)
                {
                    var vl:Array = [];
                    for each(var v:XML in this.xmlElementVertices.vertex)
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

        private function btnRemoveFromElementClick(evt:MouseEvent):void
        {
            if(this.gridElementVertices.selectedItem != null)
            {
                var sv:Object = new Object();
                sv.id = this.gridElementVertices.selectedItem.@id;
                sv.x = this.gridElementVertices.selectedItem.x;
                sv.y = this.gridElementVertices.selectedItem.y;

                this.removeVertexFromXML(this.xmlElementVertices, sv);
                this.appendVertexToXML(this.xmlAvailableVertices, sv);

                this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
                this.gridElementVertices.dataProvider = this.xmlElementVertices.vertex;
                
                if(this.xmlElementVertices.*.length() >= 3)
                {
                    var vl:Array = [];
                    for each(var v:XML in this.xmlElementVertices.vertex)
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

        private function btnAddClick(evt:MouseEvent):void
        {
            if(this.xmlElementVertices.*.length() > 2)
            {
                var meEvt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_SUBMIT);
                var dta:Object = new Object();
                dta.vertexList = [];
                for each(var v:XML in this.xmlElementVertices.vertex)
                {
                    dta.vertexList.push({id:v.@id, x:v.x, y:v.y});
                }
                meEvt.data = dta;
                this.dispatchEvent(meEvt);

                var closeEvt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
                this.dispatchEvent(closeEvt);
            }
        }

        private function appendVertexToXML(destXml:XML, data:Object):void
        {
            var xmlStr:String = "<vertex id='" + data.id + "'><x>" + data.x + "</x><y>" + data.y + "</y></vertex>";
            destXml.appendChild(new XML(xmlStr));
        }

        private function removeVertexFromXML(srcXml:XML, data:Object):void
        {
            delete srcXml.vertex.(@id == data.id)[0];
        }

        private function gridAvailableVerticesItemClick(evt:ListEvent):void
        {
            evt.rowIndex = int(evt.target.selectedItem.@id);
            this.dispatchEvent(evt);
        }
    }
}

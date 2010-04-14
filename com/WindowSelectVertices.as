package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.containers.*;
    import mx.controls.dataGridClasses.*;

    import com.WindowSelectVertices_LAYOUT

    public class WindowSelectVertices extends WindowSelectVertices_LAYOUT
    {
        [Bindable]
        protected var xmlAvailableVertices:XML;

        [Bindable]
        protected var xmlSelectedVertices:XML; 

        public function WindowSelectVertices():void
        {
            super();
            this.xmlAvailableVertices = null;
            this.xmlSelectedVertices = null;

            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete, false, 0, true);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnAdd.addEventListener(MouseEvent.CLICK, this.btnAddClick, false, 0, true);
            this.btnSelectVertex.addEventListener(MouseEvent.CLICK, this.btnSelectVertexClick, false, 0, true);
            this.btnDeselectVertex.addEventListener(MouseEvent.CLICK, this.btnDeselectVertexClick, false, 0, true);

            this.gridAvailableVertices.addEventListener(ListEvent.ITEM_ROLL_OVER, this.gridAvailableVerticesItemClick, false, 0, true);
            this.gridSelectedVertices.addEventListener(ListEvent.ITEM_ROLL_OVER, this.gridAvailableVerticesItemClick, false, 0, true);

            this.gridSelectedVertices.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, this.gridSelectedVerticesItemDoubleClick, false, 0, true);
            this.gridAvailableVertices.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, this.gridAvailableVerticesItemDoubleClick, false, 0, true);

            if(this.xmlAvailableVertices != null)
                this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
        }

        public function initAvailableVertices(aV:XML):void
        {
            this.xmlAvailableVertices = aV.copy();

            if(this.xmlSelectedVertices == null)
            {
                this.xmlSelectedVertices = new XML("<vertices></vertices>");
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
            this.removeVertexFromXML(this.xmlSelectedVertices, data);

            this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
            this.gridSelectedVertices.dataProvider = this.xmlSelectedVertices.vertex;
        }

        protected function appendVertexToXML(destXml:XML, data:Object):void
        {
            var xmlStr:String = "<vertex id='" + data.id + "'><x>" + data.x + "</x><y>" + data.y + "</y></vertex>";
            destXml.appendChild(new XML(xmlStr));
        }

        protected function removeVertexFromXML(srcXml:XML, data:Object):void
        {
            delete srcXml.vertex.(@id == data.id)[0];
        }

        protected function gridAvailableVerticesItemClick(evt:ListEvent):void
        {
            var dgir:DataGridItemRenderer = DataGridItemRenderer(evt.itemRenderer);
            var dgirdxml:XML=XML(dgir.data);//XML

            evt.rowIndex = int(dgirdxml.@id);
            this.dispatchEvent(evt);
        }

        protected function addToSelected():void
        {
            var sv:Object = new Object();
            sv.id = this.gridAvailableVertices.selectedItem.@id;
            sv.x = this.gridAvailableVertices.selectedItem.x;
            sv.y = this.gridAvailableVertices.selectedItem.y;

            this.removeVertexFromXML(this.xmlAvailableVertices, sv);
            this.appendVertexToXML(this.xmlSelectedVertices, sv);

            this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
            this.gridSelectedVertices.dataProvider = this.xmlSelectedVertices.vertex;        
        }

        protected function removeFromSelected():void
        {
            var sv:Object = new Object();
            sv.id = this.gridSelectedVertices.selectedItem.@id;
            sv.x = this.gridSelectedVertices.selectedItem.x;
            sv.y = this.gridSelectedVertices.selectedItem.y;

            this.removeVertexFromXML(this.xmlSelectedVertices, sv);
            this.appendVertexToXML(this.xmlAvailableVertices, sv);

            this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
            this.gridSelectedVertices.dataProvider = this.xmlSelectedVertices.vertex;
        }

        protected function btnSelectVertexClick(evt:MouseEvent):void {}

        protected function btnDeselectVertexClick(evt:MouseEvent):void {}

        protected function btnAddClick(evt:MouseEvent):void {}

        private function gridSelectedVerticesItemDoubleClick(evt:ListEvent):void
        {
            this.btnDeselectVertexClick(null);
        }

        private function gridAvailableVerticesItemDoubleClick(evt:ListEvent):void
        {
            this.btnSelectVertexClick(null);
        }
    }
}

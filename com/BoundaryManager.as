package com
{
    import com.MeshEditorEvent;
    import flash.events.*;
    
    public class BoundaryManager extends EventDispatcher
    {
        [Bindable]
        private var xmlBoundaries:XML; 
        private var nextId:int;

        public function BoundaryManager():void
        {
            super();
            this.xmlBoundaries = new XML("<boundaries></boundaries>"); 
            this.nextId = 1;
        }

        public function addBoundary(data:Object):void
        {
            if (! this.checkDuplicate(data))
            {
                var xmlStr:String = "<boundary id='"+ this.nextId + "'>";
                xmlStr += "<v1>" + data.vertexList[0].id + "</v1>";
                xmlStr += "<v2>" + data.vertexList[1].id + "</v2>";
                xmlStr += "<marker>" +data.marker + "</marker>";
                xmlStr += "</boundary>";

                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_ADDED);
                evt.data = data;
                evt.data.id = this.nextId;

                this.xmlBoundaries.appendChild(new XML(xmlStr));
                this.dispatchEvent(evt);
                this.nextId++;
            }
        }

        public function removeBoundary(data:Object):void
        {
            delete this.xmlBoundaries.boundary.(@id == data.id)[0];

            var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_REMOVED);
            evt.data = data;

            this.dispatchEvent(evt);

            if(this.xmlBoundaries.*.length() == 0)
                this.nextId = 1;
            trace("-b-")
        }

        private function editBoundary(evt:Object):void
        {

        }

        private function checkDuplicate(data:Object):Boolean
        {
            if(this.xmlBoundaries.boundary.( (v1 == data.vertexList[0].id && v2 == data.vertexList[1].id) || (v1 == data.vertexList[1].id && v2 == data.vertexList[0].id) ).length() != 0)
                return true;
            else
                return false;
        }

        public function get boundaries():XML
        {
            return this.xmlBoundaries;
        }

        public function getBoundary(id:int):XML
        {
            return this.xmlBoundaries.boundary.(@id == id)[0];
        }
    }
}

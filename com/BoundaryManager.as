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
                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_ADDED);
                evt.data = data;

                var xmlStr:String = "";

                if(data.id == null)
                {
                    xmlStr = "<boundary id='"+ this.nextId + "'>";
                    evt.data.id = this.nextId;
                }
                else
                {
                    xmlStr = "<boundary id='"+ data.id + "'>";
                    if(data.id > this.nextId)
                        this.nextId = data.id;
                }

                xmlStr += "<v1>" + data.vertexList[0].id + "</v1>";
                xmlStr += "<v2>" + data.vertexList[1].id + "</v2>";
                xmlStr += "<marker>" +data.marker + "</marker>";
                xmlStr += "</boundary>";

                this.xmlBoundaries.appendChild(new XML(xmlStr));

                this.nextId++;
                this.dispatchEvent(evt);
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

        public function removeBoundaryWithVertex(data:Object):void
        {
            for each(var b:XML in this.xmlBoundaries.boundary.(v1 == data.id || v2 == data.id))
            {
                this.removeBoundary({id:b.@id});
            }
        }

        public function get boundaries():XML
        {
            return this.xmlBoundaries;
        }

        public function getBoundary(id:int):XML
        {
            return this.xmlBoundaries.boundary.(@id == id)[0];
        }

        public function clear():void
        {
            this.nextId = 0;
            this.xmlBoundaries = new XML("<boundaries></boundaries>");
        }

        public function loadBoundaries(boundaries:XMLList, vertices:XMLList):void
        {
            this.clear();

            for each(var boundary:XML in boundaries.boundary)
            {
                var data:Object = new Object()
                data.id = boundary.@id;
                data.vertexList = [];
                data.marker = boundary.marker;

                var v1:XML = vertices.vertex.(@id == boundary.v1)[0];
                data.vertexList.push({id:boundary.v1, x:v1.x, y:v1.y})

                var v2:XML = vertices.vertex.(@id == boundary.v2)[0];
                data.vertexList.push({id:boundary.v2, x:v2.x, y:v2.y})

                this.addBoundary(data);
            }
        }
    }
}

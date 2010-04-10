package com
{
    import com.MeshEditorEvent;
    import flash.events.*;
    
    public class VertexManager extends EventDispatcher
    {
        [Bindable]
        private var xmlVertices:XML; 
        private var nextId:int;

        public function VertexManager():void
        {
            super();
            this.xmlVertices = new XML("<vertices></vertices>"); 
            this.nextId = 1;
        }

        public function addVertex(data:Object):void
        {
            if (! this.checkDuplicate(data))
            {
                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_ADDED);
                evt.data = data;

                var xmlStr:String = "";

                if(data.id == null)
                {
                    xmlStr = "<vertex id='"+ this.nextId + "'>";
                    evt.data.id = this.nextId;
                }
                else
                {
                    xmlStr = "<vertex id='"+ data.id + "'>";
                    if(data.id > this.nextId)
                        this.nextId = data.id;
                }

                xmlStr += "<x>" + data.x + "</x>";
                xmlStr += "<y>" + data.y + "</y>";
                xmlStr += "</vertex>";

                this.xmlVertices.appendChild(new XML(xmlStr));
                this.dispatchEvent(evt);
                this.nextId++;
            }
        }

        public function removeVertex(data:Object):void
        {
            delete this.xmlVertices.vertex.(@id == data.id)[0];

            var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_REMOVED);
            evt.data = data;

            this.dispatchEvent(evt);

            if(this.xmlVertices.*.length() == 0)
                this.nextId = 1;
        }

        private function editVertex(evt:Object):void
        {

        }

        private function checkDuplicate(data:Object):Boolean
        {
            if(this.xmlVertices.vertex.(x == data.x && y == data.y).length() != 0)
                return true;
            else
                return false;
        }

        public function get vertices():XML
        {
            return this.xmlVertices;
        }

        public function getVertex(id:int):XML
        {
            return this.xmlVertices.vertex.(@id == id)[0];
        }

        public function getIndex(id:String):int
        {
            var index:int = 0
            for each(var v:XML in this.xmlVertices.vertex)
            {
                if(v.@id == id)
                    return index;
                else
                    index++;
            }
            return -1;
        }

        public function clear():void
        {
            this.xmlVertices = new XML("<vertices></vertices>");
            this.nextId = 0;
        }

        public function loadVertices(vertices:XMLList):void
        {
            this.clear();

            for each(var vertex:XML in vertices.vertex)
            {
                this.addVertex({id:vertex.@id, x:vertex.x, y:vertex.y});
            }
        }
    }
}

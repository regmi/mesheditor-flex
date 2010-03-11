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
            this.xmlVertices = new XML("<vertices>" + 
            "<vertex id='1'><x>20</x><y>400</y></vertex>" +
            "<vertex id='2'><x>40</x><y>300</y></vertex>" +
            "<vertex id='3'><x>60</x><y>200</y></vertex>" +
            "<vertex id='4'><x>80</x><y>100</y></vertex>" +
            "<vertex id='5'><x>400</x><y>200</y></vertex>" +
            "</vertices>"); 
            this.nextId = 6;
        }

        public function addVertex(data:Object):void
        {
            if (! this.checkDuplicate(data))
            {
                var xmlStr:String = "<vertex id='"+ this.nextId + "'>";
                xmlStr += "<x>" + data.x + "</x>";
                xmlStr += "<y>" + data.y + "</y>";
                xmlStr += "</vertex>";

                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_ADDED);
                evt.data = data;
                evt.data.id = this.nextId;

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
    }
}

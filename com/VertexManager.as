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
            this.xmlVertices = new XML("<vertices></vertices>"); 
            this.nextId = 1;
        }

        public function addVertex(data:Object):void
        {
            if (! this.checkDuplicate(data))
            {
                var xmlStr:String = "<vertex id='"+ this.nextId++ + "'>";
                xmlStr += "<x>" + data.x + "</x>";
                xmlStr += "<y>" + data.y + "</y>";
                xmlStr += "</vertex>";

                this.xmlVertices.appendChild(new XML(xmlStr));
                this.dispatchEvent(new MeshEditorEvent(MeshEditorEvent.VERTEX_LIST_CHANGE));
            }
        }

        public function removeVertex(data:Object):void
        {
            for( var i:int=0;i<this.xmlVertices.*.length();i++)
            {
                if(this.xmlVertices.vertex[i].@id == (data as XML).@id)
                {
                    delete this.xmlVertices.vertex[i];
                    break;
                }
            }

            if(this.xmlVertices.*.length() == 0)
                this.nextId = 1;
            
            this.dispatchEvent(new MeshEditorEvent(MeshEditorEvent.VERTEX_LIST_CHANGE));
        }

        private function editVertex(evt:Object):void
        {

        }

        private function checkDuplicate(data:Object):Boolean
        {
            for(var i:int;i<this.xmlVertices.*.length();i++)
            {
                if (this.xmlVertices.vertex[i].x == data.x && this.xmlVertices.vertex[i].y == data.y)
                    return true;
            }

            return false;
        }

        public function get vertices():XML
        {
            return this.xmlVertices;
        }
    }
}

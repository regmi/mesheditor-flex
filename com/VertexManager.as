package com
{
    import com.VertexEvent;
    import mx.controls.DataGrid;
    import flash.events.*;
    
    public class VertexManager extends EventDispatcher
    {
        [Bindable]
        private var xmlVertices:XML; 

        public function VertexManager():void
        {
            this.xmlVertices = new XML("<vertices></vertices>"); 
        }

        public function addVertex(data:Object):void
        {
            if (! this.checkDuplicate(data))
            {
                var xmlStr:String = "<vertex>";
                xmlStr += "<X>" + data.x + "</X>";
                xmlStr += "<Y>" + data.y + "</Y>";
                xmlStr += "</vertex>";

                this.xmlVertices.appendChild(new XML(xmlStr));
                this.dispatchEvent(new VertexEvent(VertexEvent.VERTEX_LIST_CHANGE));
            }
        }

        private function removeVertex(evt:VertexEvent):void
        {

        }

        private function editVertex(evt:VertexEvent):void
        {

        }

        private function checkDuplicate(data:Object):Boolean
        {
            for(var i:int;i<this.xmlVertices.*.length();i++)
            {
                if (this.xmlVertices.vertex[i].X == data.x && this.xmlVertices.vertex[i].Y == data.y)
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

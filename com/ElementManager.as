package com
{
    import com.MeshEditorEvent;
    import flash.events.*;
    
    public class ElementManager extends EventDispatcher
    {
        [Bindable]
        private var xmlElements:XML; 
        private var nextId:int;
        
        public function ElementManager():void
        {
            this.xmlElements = new XML("<elements></elements>"); 
            this.nextId = 1;
        }

        public function addElement(data:Object):void
        {
            if(!this.checkDuplicate(data))
            {
                var xmlStr:String = "<element id='"+ this.nextId + "'>";
                xmlStr += "<v1>" + data.vertexId[0] + "</v1>";
                xmlStr += "<v2>" + data.vertexId[1] + "</v2>";
                xmlStr += "<v3>" + data.vertexId[2] + "</v3>";

                var tmp:int = int(data.vertexId[3])
                if(tmp != 0)
                {
                    xmlStr += "<v4>" + tmp + "</v4>";
                }

                xmlStr += "</element>";
                var e:XML = new XML(xmlStr);
                this.xmlElements.appendChild(e);

                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_ADDED);
                evt.data = data;
                evt.data.id = this.nextId;
                this.dispatchEvent(evt);
                this.nextId++;
            }
        }

        public function removeElement(data:Object):void
        {
            delete this.xmlElements.element.(@id == data.id)[0];

            if(this.xmlElements.*.length() == 0)
                this.nextId = 1;

            var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_REMOVED);
            evt.data = data;

            this.dispatchEvent(evt);
        }

        private function editVertex(evt:Object):void
        {

        }

        private function checkDuplicate(data:Object):Boolean
        {
            var vId1:Array = [];
            var vId2:Array = [];
            var count:int = 0;
            var tmp:int = 0;

            vId1.push(int(data.vertexId[0]));
            vId1.push(int(data.vertexId[1]));
            vId1.push(int(data.vertexId[2]));

            tmp = int(data.vertexId[3])
            if(tmp != 0)
                vId1.push(tmp);

            for each(var element:XML in this.xmlElements.element)
            {
                count = 0;

                vId2.splice(0,vId2.length);
                vId2.push(int(element.v1));
                vId2.push(int(element.v2));
                vId2.push(int(element.v3));

                tmp = int(element.v4);
                if(tmp != 0)
                    vId2.push(tmp);

                if(vId1.length == vId2.length)
                {
                    for each(var val:Number in vId2)
                    {
                        if(vId1.indexOf(val) == -1)
                            break;
                        else
                            count++;
                    }
                }

                if(count == vId1.length)
                    return true;
            }

            return false;
        }

        public function get elements():XML
        {
            return this.xmlElements;
        }
    }
}

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
            super();
            this.xmlElements = new XML("<elements>" +
            //"<element id='1'><v1>2</v1><v2>4</v2><v3>5</v3></element>" +
            //"<element id='2'><v1>1</v1><v2>2</v2><v3>4</v3></element>" +
            //"<element id='3'><v1>5</v1><v2>3</v2><v3>2</v3></element>" +
            "</elements>");
            this.nextId = 1;
        }

        public function addElement(data:Object):void
        {
            if(!this.checkDuplicate(data))
            {
                var xmlStr:String = "<element id='"+ this.nextId + "'>";

                try
                {
                    for(var i:int=0; i<data.vertexList.length;i++)
                        xmlStr += "<v" +(i+1)+ ">" + data.vertexList[i].id + "</v" + (i+1) + ">";
                }catch(e:Error){}

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

            try
            {
                for(var i:int=0; i<data.vertexList.length;i++)
                    vId1.push(int(data.vertexList[i].id));
            }catch(e:Error){}

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

        public function getElement(id:int):XML
        {
            return this.xmlElements.element.(@id == id)[0];
        }

        public function get elements():XML
        {
            return this.xmlElements;
        }
    }
}

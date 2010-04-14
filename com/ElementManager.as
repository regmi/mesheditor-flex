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
            this.xmlElements = new XML("<elements></elements>");
            this.nextId = 1;
        }

        public function addElement(data:Object):void
        {
            if(!this.checkDuplicate(data))
            {
                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_ADDED);
                evt.data = data;

                var xmlStr:String = "";

                if(data.id == null)
                {
                    xmlStr = "<element id='"+ this.nextId + "'>";
                    evt.data.id = this.nextId;
                }
                else
                {
                    xmlStr = "<element id='"+ data.id + "'>";
                    if(data.id > this.nextId)
                        this.nextId = data.id;
                }

                try
                {
                    for(var i:int=0; i<data.vertexList.length;i++)
                        xmlStr += "<v" +(i+1)+ ">" + data.vertexList[i].id + "</v" + (i+1) + ">";
                }catch(e:Error){}

                xmlStr += "</element>";
                var e:XML = new XML(xmlStr);
                this.xmlElements.appendChild(e);
                
                this.nextId++;
                this.dispatchEvent(evt);
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

        public function removeElementWithVertex(data:Object):void
        {
            for each(var e:XML in this.xmlElements.element)
            {
                if(e.v1 == data.id)
                    this.removeElement({id:e.@id});
                else
                {
                    if(e.v2 == data.id)
                        this.removeElement({id:e.@id});
                    else
                    {
                        if(e.v3 == data.id)
                            this.removeElement({id:e.@id});
                        else
                        {
                            try
                            {
                                if(e.v4 == data.id)
                                    this.removeElement({id:e.@id});
                            }catch(e:Error){}
                        }
                    }
                }
            }
        }

        public function getElement(id:int):XML
        {
            return this.xmlElements.element.(@id == id)[0];
        }

        public function get elements():XML
        {
            return this.xmlElements;
        }

        public function clear():void
        {
            this.nextId = 0;
            this.xmlElements = new XML("<elements></elements>");
        }

        public function loadElements(elements:XMLList, vertices:XMLList):void
        {
            this.clear();

            for each(var element:XML in elements.element)
            {
                var data:Object = new Object()
                data.id = element.@id;
                data.vertexList = [];

                for each(var vId:XML in element.*)
                {
                    var vertex:XML = vertices.vertex.(@id == vId)[0];
                    data.vertexList.push({id:vId, x:vertex.x, y:vertex.y})
                }

                this.addElement(data);
            }
        }

        public function getElementsWithVertex(id:int):XML
        {
            var
            for each( var e in this.xmlElements.element)
            {
                
            }
            var xl:XMLList = this.elements.element.((*.length() == 3 && (v1 == id || v2 == id || v3 == id)) || (*.length() == 4 && v4 == id));
            return xl;
        }
    }
}

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
            var xmlStr:String = "<element id='"+ this.nextId++ + "'>";
            xmlStr += "<v1>" + (data.vertices as XML).vertex[0].@id + "</v1>";
            xmlStr += "<v2>" + (data.vertices as XML).vertex[1].@id + "</v2>";
            xmlStr += "<v3>" + (data.vertices as XML).vertex[2].@id + "</v3>";

            try
            {
                xmlStr += "<v4>" + (data.vertices as XML).vertex[3].@id + "</v4>";
            }
            catch(e:Error){}

            xmlStr += "</element>";
            var e:XML = new XML(xmlStr);

            if(!this.checkDuplicate(e))
            {
                this.xmlElements.appendChild(e);
                this.dispatchEvent(new MeshEditorEvent(MeshEditorEvent.ELEMENT_LIST_CHANGE));
            }
        }

        public function removeElement(data:Object):void
        {
            for( var i:int=0;i<this.xmlElements.*.length();i++)
            {
                if(this.xmlElements.element[i].@ID == (data as XML).@ID)
                {
                    delete this.xmlElements.element[i];
                    break;
                }
            }

            if(this.xmlElements.*.length() == 0)
                this.nextId = 1;
            
            this.dispatchEvent(new MeshEditorEvent(MeshEditorEvent.ELEMENT_LIST_CHANGE));
        }

        private function editVertex(evt:Object):void
        {

        }

        private function checkDuplicate(e:XML):Boolean
        {
            var vId1:Array = [];
            var vId2:Array = [];
            var count:int = 0;
            var tmp:int = 0;

            vId1.push(int(e.v1));
            vId1.push(int(e.v2));
            vId1.push(int(e.v3));

            tmp = int(e.v4)
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

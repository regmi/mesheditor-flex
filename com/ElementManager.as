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
            if (! this.checkDuplicate(data))
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

                this.xmlElements.appendChild(new XML(xmlStr));

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

        private function checkDuplicate(data:Object):Boolean
        {
            return false;
        }

        public function get elements():XML
        {
            return this.xmlElements;
        }
    }
}

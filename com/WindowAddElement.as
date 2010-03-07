package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.containers.*;

    import com.WindowAddElement_LAYOUT

    public class WindowAddElement extends WindowAddElement_LAYOUT
    {
        [Bindable]
        private var xmlAvailableVertices:XML;

        [Bindable]
        private var xmlElementVertices:XML; 

        public function WindowAddElement():void
        {
            super();
            this.xmlAvailableVertices = null;
            this.xmlElementVertices = null;

            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnAddToElement.addEventListener(MouseEvent.CLICK, this.btnAddToElementClick);
            this.btnRemoveFromElement.addEventListener(MouseEvent.CLICK, this.btnRemoveFromElementClick);
            this.btnAdd.addEventListener(MouseEvent.CLICK, this.btnAddClick);

            if(this.xmlAvailableVertices != null)
                this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
        }

        public function initAvailableVertices(aV:XML):void
        {
            this.xmlAvailableVertices = aV.copy();

            if(this.xmlElementVertices == null)
            {
                this.xmlElementVertices = new XML("<vertices></vertices>");
            }
            else
            {
                var e:XML = new XML("<vertices></vertices>");
                
                for(var i:int=0;i<this.xmlElementVertices.*.length();i++)
                {
                    if(this.vertexExists(this.xmlAvailableVertices, this.xmlElementVertices.vertex[i]))
                    {
                        this.removeVertex(this.xmlAvailableVertices, this.xmlElementVertices.vertex[i]);
                        e.appendChild(this.xmlElementVertices.vertex[i]);
                    }
                }

                this.xmlElementVertices = e;
            }

            try
            {
                this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
            }catch(e:Error){}

            try
            {
                this.gridElementVertices.dataProvider = this.xmlElementVertices.vertex;
            }catch(e:Error){}
        }

        private function btnAddToElementClick(evt:MouseEvent):void
        {
            if(this.gridAvailableVertices.selectedItem != null && this.xmlElementVertices.*.length() < 4)
            {
                this.removeVertex(this.xmlAvailableVertices, this.gridAvailableVertices.selectedItem);
                this.appendVertex(this.xmlElementVertices, this.gridAvailableVertices.selectedItem);

                this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
                this.gridElementVertices.dataProvider = this.xmlElementVertices.vertex;
            }
        }

        private function btnRemoveFromElementClick(evt:MouseEvent):void
        {
            if(this.gridElementVertices.selectedItem != null)
            {
                this.removeVertex(this.xmlElementVertices, this.gridElementVertices.selectedItem);
                this.appendVertex(this.xmlAvailableVertices, this.gridElementVertices.selectedItem);

                this.gridAvailableVertices.dataProvider = this.xmlAvailableVertices.vertex;
                this.gridElementVertices.dataProvider = this.xmlElementVertices.vertex;
            }
        }

        private function btnAddClick(evt:MouseEvent):void
        {
            if(this.xmlElementVertices.*.length() > 2)
            {
                var meEvt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_SUBMIT);
                var dta:Object = new Object();
                dta.vertices = this.xmlElementVertices;
                meEvt.data = dta;
                this.dispatchEvent(meEvt);

                var closeEvt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
                this.dispatchEvent(closeEvt);
            }
        }

        private function appendVertex(destXml:XML, vertex:Object):void
        {
            var xmlStr:String = "<vertex id='" + (vertex as XML).@id + "'><x>" + vertex.x + "</x><y>" + vertex.x + "</y></vertex>";
            destXml.appendChild(new XML(xmlStr));
        }

        private function removeVertex(srcXml:XML, vertex:Object):void
        {
            for( var i:int=0;i<srcXml.*.length();i++)
            {
                if(srcXml.vertex[i].@id == (vertex as XML).@id)
                {
                    delete srcXml.vertex[i];
                    break;
                }
            }
        }
        
        private function vertexExists(srcXml:XML, data:XML):Boolean
        {
            for each(var vtx:XML in srcXml.vertex)
            {
                if(vtx.@id == data.@id)
                    return true;
            }

            return false;
        }
    }
}

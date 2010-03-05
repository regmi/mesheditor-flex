package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import mx.containers.*;
    import mx.managers.PopUpManager;

    import flash.events.*;

    import com.WindowAddVertex;
    import com.WindowAddElement;
    import com.WindowAddCurve;

    import com.VertexEvent;
    import com.VertexManager;

    public class MeshEditor extends Application
    {
        // Components in MXML
        public var btnShowWindow:Button;
        public var btnRemoveItem:Button;
        public var gridVertices:DataGrid;
        public var accordion:Accordion;

        private var windowAddVertex:WindowAddVertex;
        private var windowAddElement:WindowAddElement;
        private var windowAddBoundry:WindowAddBoundry;
        private var windowAddCurve:WindowAddCurve;

        private var vertexManager:VertexManager;

        public function MeshEditor()
        {
            this.windowAddVertex = null;
            this.windowAddElement = null;
            this.windowAddBoundry = null;
            this.windowAddCurve = null;

            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnShowWindow.addEventListener(MouseEvent.CLICK, this.btnShowWindowClick);
            this.btnRemoveItem.addEventListener(MouseEvent.CLICK, this.btnRemoveItemClick);
            
            this.vertexManager = new VertexManager();
            this.vertexManager.addEventListener(VertexEvent.VERTEX_LIST_CHANGE, this.vertexListChangeHandler);
        }

        private function btnShowWindowClick(evt:MouseEvent):void
        {
            if(this.accordion.selectedIndex == 0)
            {
                if(this.windowAddVertex == null)
                {
                    this.windowAddVertex = new WindowAddVertex();
                    this.windowAddVertex.addEventListener(CloseEvent.CLOSE, this.windowCloseClick);
                    this.windowAddVertex.addEventListener(VertexEvent.ADD_VERTEX, this.addVertexHandler);

                    PopUpManager.addPopUp(this.windowAddVertex, this, false);
                    PopUpManager.centerPopUp(this.windowAddVertex);
                }
            }
            else if(this.accordion.selectedIndex == 1)
            {
                if(this.windowAddElement == null)
                {
                    this.windowAddElement = new WindowAddElement();
                    this.windowAddElement.addEventListener(CloseEvent.CLOSE, this.windowCloseClick);

                    PopUpManager.addPopUp(this.windowAddElement, this, false);
                    PopUpManager.centerPopUp(this.windowAddElement);   
                }
            }
            else if(this.accordion.selectedIndex == 2)
            {
                if(this.windowAddCurve == null)
                {
                    this.windowAddCurve = new WindowAddCurve();
                    this.windowAddCurve.addEventListener(CloseEvent.CLOSE, this.windowCloseClick);

                    PopUpManager.addPopUp(this.windowAddCurve, this, false);
                    PopUpManager.centerPopUp(this.windowAddCurve);
                }
            }
            else if(this.accordion.selectedIndex == 3)
            {
                if(this.windowAddBoundry == null)
                {
                    this.windowAddBoundry = new WindowAddBoundry();
                    this.windowAddBoundry.addEventListener(CloseEvent.CLOSE, this.windowCloseClick);

                    PopUpManager.addPopUp(this.windowAddBoundry, this, false);
                    PopUpManager.centerPopUp(this.windowAddBoundry);
                }
            }
        }

        private function btnRemoveItemClick(evt:MouseEvent):void
        {
            if(this.accordion.selectedIndex == 0)
            {

            }
            else if(this.accordion.selectedIndex == 1)
            {

            }
            else if(this.accordion.selectedIndex == 2)
            {

            }
            else if(this.accordion.selectedIndex == 4)
            {

            }
        }

        private function windowCloseClick(evt:CloseEvent):void
        {
            if(evt.target is WindowAddVertex)
            {
                PopUpManager.removePopUp(this.windowAddVertex);
                this.windowAddVertex = null;
            }
            else if(evt.target is WindowAddElement)
            {
                PopUpManager.removePopUp(this.windowAddElement);
                this.windowAddElement = null;
            }
            else if (evt.target is WindowAddCurve)
            {
                PopUpManager.removePopUp(this.windowAddCurve);
                this.windowAddCurve = null;
            }
            else if (evt.target is WindowAddBoundry)
            {
                PopUpManager.removePopUp(this.windowAddBoundry);
                this.windowAddBoundry = null;
            }
        }

        private function addVertexHandler(evt:VertexEvent):void
        {
            this.vertexManager.addVertex(evt.data);
        }

        private function vertexListChangeHandler(evt:VertexEvent):void
        {
            this.gridVertices.dataProvider = evt.target.vertices.vertex;
            
            if(this.windowAddElement != null)
                this.windowAddElement.dispatchEvent(evt);
        }
    }
}

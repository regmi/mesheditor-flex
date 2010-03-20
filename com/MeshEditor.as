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

    import com.MeshEditorEvent;
    import com.VertexManager;
    import com.ElementManager;
    import com.DrawingArea;

    public class MeshEditor extends Application
    {
        // Components in MXML
        public var btnShowWindow:Button;
        public var btnRemoveItem:Button;
        public var gridVertices:DataGrid;
        public var gridElements:DataGrid;
        public var gridBoundaries:DataGrid;
        public var accordion:Accordion;

        private var windowAddVertex:WindowAddVertex;
        private var windowAddElement:WindowAddElement;
        private var windowAddBoundary:WindowAddBoundary;
        private var windowAddCurve:WindowAddCurve;

        private var vertexManager:VertexManager;
        private var elementManager:ElementManager;
        private var boundaryManager:BoundaryManager;
        private var drawingArea:DrawingArea;

        public function MeshEditor()
        {
            this.windowAddVertex = null;
            this.windowAddElement = null;
            this.windowAddBoundary = null;
            this.windowAddCurve = null;

            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnShowWindow.addEventListener(MouseEvent.CLICK, this.btnShowWindowClick);
            this.btnRemoveItem.addEventListener(MouseEvent.CLICK, this.btnRemoveItemClick);
            this.gridVertices.addEventListener(ListEvent.ITEM_CLICK, this.gridVerticesItemClick);

            this.drawingArea = new DrawingArea(600, 500);
            this.drawingArea.x = 10;
            this.drawingArea.y = 30;
            this.addChild(this.drawingArea);

            this.vertexManager = new VertexManager();
            this.vertexManager.addEventListener(MeshEditorEvent.VERTEX_ADDED, this.vertexAddedHandler);
            this.vertexManager.addEventListener(MeshEditorEvent.VERTEX_REMOVED, this.vertexRemovedHandler);
            this.vertexManager.dispatchVertexAdded();

            this.elementManager = new ElementManager();
            this.elementManager.addEventListener(MeshEditorEvent.ELEMENT_ADDED, this.elementAddedHandler);
            this.elementManager.addEventListener(MeshEditorEvent.ELEMENT_REMOVED, this.elementRemovedHandler);

            this.boundaryManager = new BoundaryManager();
            this.boundaryManager.addEventListener(MeshEditorEvent.BOUNDARY_ADDED, this.boundaryAddedHandler);
            this.boundaryManager.addEventListener(MeshEditorEvent.BOUNDARY_REMOVED, this.boundaryRemovedHandler);

            this.gridVertices.dataProvider = this.vertexManager.vertices.vertex;
        }

        private function btnShowWindowClick(evt:MouseEvent):void
        {
            if(this.accordion.selectedIndex == 0)
            {
                if(this.windowAddVertex == null)
                {
                    this.windowAddVertex = new WindowAddVertex();
                    this.windowAddVertex.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);
                    this.windowAddVertex.addEventListener(MeshEditorEvent.VERTEX_SUBMIT, this.submitVertexHandler, false, 0, true);

                    PopUpManager.addPopUp(this.windowAddVertex, this, false);
                    PopUpManager.centerPopUp(this.windowAddVertex);
                }
            }
            else if(this.accordion.selectedIndex == 1)
            {
                if(this.windowAddElement == null)
                {
                    this.windowAddElement = new WindowAddElement();
                    this.windowAddElement.initAvailableVertices(this.vertexManager.vertices);
                    this.windowAddElement.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);
                    this.windowAddElement.addEventListener(MeshEditorEvent.ELEMENT_SUBMIT, this.submitElementHandler, false, 0, true);
                    this.windowAddElement.addEventListener(ListEvent.ITEM_CLICK, this.gridVerticesItemClick, false, 0, true);
                    this.windowAddElement.addEventListener(MeshEditorEvent.ELEMENT_SELECTED, this.elementSelected, false, 0, true);

                    PopUpManager.addPopUp(this.windowAddElement, this, false);
                    PopUpManager.centerPopUp(this.windowAddElement);   
                }
                
                if(!this.gridElements.hasEventListener(ListEvent.ITEM_CLICK))
                    this.gridElements.addEventListener(ListEvent.ITEM_CLICK, this.gridElementsItemClick, false, 0, true);

            }
            else if(this.accordion.selectedIndex == 2)
            {
                if(this.windowAddCurve == null)
                {
                    this.windowAddCurve = new WindowAddCurve();
                    this.windowAddCurve.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);

                    PopUpManager.addPopUp(this.windowAddCurve, this, false);
                    PopUpManager.centerPopUp(this.windowAddCurve);
                }
            }
            else if(this.accordion.selectedIndex == 3)
            {
                if(this.windowAddBoundary == null)
                {
                    this.windowAddBoundary = new WindowAddBoundary();
                    this.windowAddBoundary.initAvailableVertices(this.vertexManager.vertices);
                    this.windowAddBoundary.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);
                    this.windowAddBoundary.addEventListener(MeshEditorEvent.BOUNDARY_SUBMIT, this.submitBoundaryHandler, false, 0, true);
                    this.windowAddBoundary.addEventListener(ListEvent.ITEM_CLICK, this.gridVerticesItemClick, false, 0, true);
                    this.windowAddBoundary.addEventListener(MeshEditorEvent.BOUNDARY_SELECTED, this.boundarySelected, false, 0, true);

                    PopUpManager.addPopUp(this.windowAddBoundary, this, false);
                    PopUpManager.centerPopUp(this.windowAddBoundary);
                }

                if(!this.gridBoundaries.hasEventListener(ListEvent.ITEM_CLICK))
                    this.gridBoundaries.addEventListener(ListEvent.ITEM_CLICK, this.gridBoundariesItemClick, false, 0, true);
            }
        }

        private function btnRemoveItemClick(evt:MouseEvent):void
        {
            var itm:Object;
            
            if(this.accordion.selectedIndex == 0)
            {
                for each (itm in this.gridVertices.selectedItems)
                {
                    this.vertexManager.removeVertex({id:itm.@id, x:itm.x, y:itm.y});
                }
            }
            else if(this.accordion.selectedIndex == 1)
            {
                for each (itm in this.gridElements.selectedItems)
                {
                    this.elementManager.removeElement({id:itm.@id});
                }
            }
            else if(this.accordion.selectedIndex == 2)
            {

            }
            else if(this.accordion.selectedIndex == 3)
            {
                for each (itm in this.gridBoundaries.selectedItems)
                {
                    trace("-a-")
                    this.boundaryManager.removeBoundary({id:itm.@id});
                }
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
            else if (evt.target is WindowAddBoundary)
            {
                PopUpManager.removePopUp(this.windowAddBoundary);
                this.windowAddBoundary = null;
            }
        }

        private function submitVertexHandler(evt:MeshEditorEvent):void
        {
            this.vertexManager.addVertex(evt.data);
        }

        private function submitElementHandler(evt:MeshEditorEvent):void
        {
            this.elementManager.addElement(evt.data);
        }

        private function submitBoundaryHandler(evt:MeshEditorEvent):void
        {
            trace("--Add Boundary--");
            trace(evt.data.vertexList[0]);
            trace(evt.data.vertexList[1]);
            trace(evt.data.marker);

            this.boundaryManager.addBoundary(evt.data);
        }

        private function vertexAddedHandler(evt:MeshEditorEvent):void
        {
            this.gridVertices.dataProvider = evt.target.vertices.vertex;

            if(this.windowAddElement != null)
                this.windowAddElement.addAvailableVertex(evt.data);

            this.drawingArea.addVertex(evt.data);
        }

        private function vertexRemovedHandler(evt:MeshEditorEvent):void
        {
            this.gridVertices.dataProvider = evt.target.vertices.vertex;

            if(this.windowAddElement != null)
                this.windowAddElement.removeAvailableVertex(evt.data);

            this.drawingArea.removeVertex(evt.data);
        }

        private function elementAddedHandler(evt:MeshEditorEvent):void
        {
            this.gridElements.dataProvider = evt.target.elements.element;
            this.drawingArea.addElement(evt.data);
        }

        private function boundaryAddedHandler(evt:MeshEditorEvent):void
        {
            this.gridBoundaries.dataProvider = evt.target.boundaries.boundary;
            this.drawingArea.addBoundary(evt.data);
        }

        private function elementRemovedHandler(evt:MeshEditorEvent):void
        {
            this.gridElements.dataProvider = evt.target.elements.element;
            this.drawingArea.removeElement(evt.data);
        }

        private function boundaryRemovedHandler(evt:MeshEditorEvent):void
        {
            trace("-br-")
            this.gridBoundaries.dataProvider = evt.target.boundaries.boundary;
            this.drawingArea.removeBoundary(evt.data);
        }

        private function gridVerticesItemClick(evt:ListEvent):void
        {
            if(evt.target == this.gridVertices)
                this.drawingArea.selectVertex({id:evt.target.selectedItem.@id});
            else// if(evt.target == this.windowAddElement)
                this.drawingArea.selectVertex({id:evt.rowIndex});
        }

        private function gridElementsItemClick(evt:ListEvent):void
        {
            var vl:Array = [];
            evt.target.selectedItem.@id
            var element:XML = this.elementManager.getElement(evt.target.selectedItem.@id);
            for each(var v:XML in element.*)
            {
                var vertex:XML = this.vertexManager.getVertex(int(v));
                vl.push({id:vertex.@id, x:vertex.x, y:vertex.y});
            }
            this.drawingArea.selectElement({vertexList:vl});
        }

        private function gridBoundariesItemClick(evt:ListEvent):void
        {
            var vl:Array = [];
            evt.target.selectedItem.@id
            var element:XML = this.boundaryManager.getBoundary(evt.target.selectedItem.@id);
            
            var vertex:XML = this.vertexManager.getVertex(int(element.v1));
            vl.push({id:vertex.@id, x:vertex.x, y:vertex.y});

            vertex = this.vertexManager.getVertex(int(element.v2));
            vl.push({id:vertex.@id, x:vertex.x, y:vertex.y});

            this.drawingArea.selectBoundary({vertexList:vl});
        }

        private function elementSelected(evt:MeshEditorEvent):void
        {
            this.drawingArea.selectElement(evt.data);
        }

        private function boundarySelected(evt:MeshEditorEvent):void
        {
            trace("--Boundary Selected--");
            this.drawingArea.selectBoundary(evt.data);
        }
    }
}

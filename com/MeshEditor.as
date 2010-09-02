package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import mx.rpc.http.*;
    import mx.containers.*;
    import mx.rpc.events.*;
    import mx.controls.dataGridClasses.*;

    import mx.managers.PopUpManager;

    import flash.net.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.external.*;

    import com.WindowAddVertex;
    import com.WindowAddElement;
    import com.WindowAddCurve;
    import com.WindowAddBoundary;
    import com.WindowShowHelp;

    import com.MeshEditorEvent;
    import com.MeshManager;
    import com.DrawingArea;
    import com.Geometry;

    public class MeshEditor extends Application
    {
        // Components in MXML
        public var numStepper:NumericStepper;
        public var btnShowWindow:Button;
        public var btnRemoveItem:Button;
        public var gridVertices:DataGrid;
        public var gridElements:DataGrid;
        public var gridBoundaries:DataGrid;
        public var accordion:Accordion;
        public var btnSaveMesh:Button;
        public var btnLoadMesh:Button;
        public var btnSubmitMesh:Button;
        public var btnTriangulateMesh:Button;
        public var btnClear:Button;
        public var btnHelp:Button;
        public var chkBoxShowElement:CheckBox;
        public var chkBoxShowBoundary:CheckBox;

        private var windowAddVertex:WindowAddVertex;
        private var windowAddElement:WindowAddElement;
        private var windowAddBoundary:WindowAddBoundary;
        private var windowAddCurve:WindowAddCurve;
        private var windowShowHelp:WindowShowHelp;

        public var meshManager:MeshManager;
        private var drawingArea:DrawingArea;
        private var meshfile:FileReference;

        public function MeshEditor()
        {
            this.windowAddVertex = null;
            this.windowAddElement = null;
            this.windowAddBoundary = null;
            this.windowAddCurve = null;

            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete);
            this.addEventListener(FlexEvent.APPLICATION_COMPLETE, this.applicationComplete);
        }

        private function applicationComplete(evt:FlexEvent):void
        {
            this.stage.focus = this;
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.handleKeyDown);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.chkBoxShowElement.addEventListener(Event.CHANGE, this.chkBoxShowElementChange);
            this.chkBoxShowBoundary.addEventListener(Event.CHANGE, this.chkBoxShowBoundaryChange);
            this.btnShowWindow.addEventListener(MouseEvent.CLICK, this.btnShowWindowClick);
            this.btnRemoveItem.addEventListener(MouseEvent.CLICK, this.btnRemoveItemClick);
            this.btnSaveMesh.addEventListener(MouseEvent.CLICK, this.btnSaveMeshClick);
            this.btnLoadMesh.addEventListener(MouseEvent.CLICK, this.btnLoadMeshClick);
            this.btnSubmitMesh.addEventListener(MouseEvent.CLICK, this.btnSubmitMeshClick);
            this.btnTriangulateMesh.addEventListener(MouseEvent.CLICK, this.btnTriangulateMeshClick);
            this.btnClear.addEventListener(MouseEvent.CLICK, this.btnClearClick);
            this.btnHelp.addEventListener(MouseEvent.CLICK, this.btnHelpClick);

            this.gridVertices.addEventListener(ListEvent.ITEM_ROLL_OVER, this.gridVerticesItemRollOver);
            this.gridVertices.addEventListener(ListEvent.CHANGE, this.gridVerticesItemRollOver);
            this.gridVertices.addEventListener(DataGridEvent.ITEM_EDIT_END, this.gridVerticesItemEditEnd);

            this.drawingArea = new DrawingArea(600, 515);
            this.drawingArea.addEventListener(MeshEditorEvent.VERTEX_ADDED, this.drawingAreaVertexAdded);
            this.drawingArea.addEventListener(MeshEditorEvent.VERTEX_REMOVED, this.drawingAreaVertexRemoved);
            this.drawingArea.addEventListener(MeshEditorEvent.VERTEX_UPDATED, this.drawingAreaVertexUpdated);
            this.drawingArea.addEventListener(MeshEditorEvent.VERTEX_DRAG_END, this.drawingAreaVertexDragEnd);
            this.drawingArea.addEventListener(MeshEditorEvent.ELEMENT_ADDED, this.drawingAreaElementAdded);
            this.drawingArea.addEventListener(MeshEditorEvent.ELEMENT_REMOVED, this.drawingAreaElementRemoved);
            this.drawingArea.addEventListener(MeshEditorEvent.BOUNDARY_ADDED, this.drawingAreaBoundaryAdded);
            this.drawingArea.addEventListener(MeshEditorEvent.BOUNDARY_REMOVED, this.drawingAreaBoundaryRemoved);
            this.drawingArea.x = 10;
            this.drawingArea.y = 30;
            this.addChild(this.drawingArea);

            this.numStepper.addEventListener(NumericStepperEvent.CHANGE, this.numStepperChange);

            this.meshManager = new MeshManager();
            this.meshManager.addEventListener(MeshEditorEvent.VERTEX_ADDED, this.meshManagerVertexAdded);
            this.meshManager.addEventListener(MeshEditorEvent.VERTEX_REMOVED, this.meshManagerVertexRemoved);
            this.meshManager.addEventListener(MeshEditorEvent.VERTEX_UPDATED, this.meshManagerVertexUpdated);
            this.meshManager.addEventListener(MeshEditorEvent.ELEMENT_ADDED, this.meshManagerElementAdded);
            this.meshManager.addEventListener(MeshEditorEvent.ELEMENT_REMOVED, this.meshManagerElementRemoved);
            this.meshManager.addEventListener(MeshEditorEvent.ELEMENT_UPDATED, this.meshManagerElementUpdated);
            this.meshManager.addEventListener(MeshEditorEvent.BOUNDARY_ADDED, this.meshManagerBoundaryAdded);
            this.meshManager.addEventListener(MeshEditorEvent.BOUNDARY_REMOVED, this.meshManagerBoundaryRemoved);
            this.meshManager.addEventListener(MeshEditorEvent.BOUNDARY_UPDATED, this.meshManagerBoundaryUpdated);

            this.accordion.addEventListener(IndexChangedEvent.CHANGE, this.accordionChange);

            this.gridVertices.dataProvider = this.meshManager.vertices;

            try
            {
                this.parseFlashVars();
            }
            catch(e:Error) {}
        }

        private function numStepperChange(evt:NumericStepperEvent):void
        {
            this.zoomInOut(evt.value);
        }

        private function zoomInOut(scaleFactor:Number):void
        {
            this.drawingArea.scaleFactor = scaleFactor;
            this.drawingArea.updateGrid();

            for each(var v:Object in this.meshManager.vertices)
            {
                this.drawingArea.updateVertex(v);
            }

            for each(var e:Object in this.meshManager.elements)
            {
                this.drawingArea.updateElement(e);
            }

            for each(var b:Object in this.meshManager.boundaries)
            {
                this.drawingArea.updateBoundary(b);
            }
        }

        private function handleKeyDown(evt:KeyboardEvent):void
        {
            //trace(evt.charCode);

            if(evt.ctrlKey && evt.charCode == 127)
            {
                this.btnRemoveItemClick(null);
            }
            if(evt.ctrlKey && evt.keyCode == 112)//f1
            {
                navigateToURL(new URLRequest("http://femhub.org/doc/src/intromesh.html#mesheditor-based-on-flex"), "_blank")
            }
            else if(evt.charCode == 115)//save
            {
                this.btnSaveMeshClick(null);
            }
            else if(evt.charCode == 108)//load
            {
                this.btnLoadMeshClick(null);
            }
            else if(evt.charCode == 13)//submit
            {
                this.btnSubmitMeshClick(null);
            }
            else if(evt.charCode == 116)//triangulate
            {
                this.btnTriangulateMeshClick(null);
            }
            else if(evt.charCode == 118)//vertex mode
            {
                this.accordion.selectedIndex = 0;
                this.accordionChange(null);
            }
            else if(evt.charCode == 101)//element mode
            {
                this.accordion.selectedIndex = 1;
                this.accordionChange(null);
            }
            else if(evt.charCode == 98)//boundary mode
            {
                this.accordion.selectedIndex = 2;
                this.accordionChange(null);
            }
            else if(evt.charCode == 99)//clear
            {
                this.btnClearClick(null);
            }
            else if(evt.charCode == 104)//help
            {
                this.btnHelpClick(null);
            }
            else if(evt.charCode == 45)//zoom out
            {
                if(this.numStepper.value > 10)
                {
                    this.numStepper.value -= 5;
                    this.zoomInOut(this.numStepper.value);
                }
            }
            else if(evt.charCode == 61)//zoom in
            {
                if(this.numStepper.value < 270)
                {
                    this.numStepper.value += 5;
                    this.zoomInOut(this.numStepper.value);
                }
            }
        }

        private function btnShowWindowClick(evt:MouseEvent):void
        {
            if(this.accordion.selectedIndex == 0)
            {
                if(this.windowAddVertex == null)
                {
                    this.windowAddVertex = new WindowAddVertex();
                    this.windowAddVertex.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);
                    this.windowAddVertex.addEventListener(MeshEditorEvent.VERTEX_SUBMITTED, this.vertexSubmitted, false, 0, true);

                    PopUpManager.addPopUp(this.windowAddVertex, this, false);
                    PopUpManager.centerPopUp(this.windowAddVertex);
                }
            }
            else if(this.accordion.selectedIndex == 1)
            {
                if(this.windowAddElement == null)
                {
                    this.windowAddElement = new WindowAddElement();
                    this.windowAddElement.initAvailableVertices(this.meshManager.vertices);
                    this.windowAddElement.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);
                    this.windowAddElement.addEventListener(MeshEditorEvent.ELEMENT_SUBMITTED, this.elementSubmitted, false, 0, true);
                    this.windowAddElement.addEventListener(ListEvent.ITEM_ROLL_OVER, this.gridVerticesItemRollOver, false, 0, true);
                    this.windowAddElement.addEventListener(MeshEditorEvent.ELEMENT_SELECTED, this.elementSelected, false, 0, true);

                    PopUpManager.addPopUp(this.windowAddElement, this, false);
                    PopUpManager.centerPopUp(this.windowAddElement);   
                }
            }
            else if(this.accordion.selectedIndex == 2)
            {
                if(this.windowAddBoundary == null)
                {
                    this.windowAddBoundary = new WindowAddBoundary();
                    this.windowAddBoundary.initAvailableVertices(this.meshManager.vertices);
                    this.windowAddBoundary.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);
                    this.windowAddBoundary.addEventListener(MeshEditorEvent.BOUNDARY_SUBMITTED, this.boundarySubmitted, false, 0, true);
                    this.windowAddBoundary.addEventListener(ListEvent.ITEM_ROLL_OVER, this.gridVerticesItemRollOver, false, 0, true);
                    this.windowAddBoundary.addEventListener(MeshEditorEvent.BOUNDARY_SELECTED, this.boundarySelected, false, 0, true);

                    PopUpManager.addPopUp(this.windowAddBoundary, this, false);
                    PopUpManager.centerPopUp(this.windowAddBoundary);
                }
            }
            else if(this.accordion.selectedIndex == 3)
            {
                if(this.windowAddCurve == null)
                {
                    this.windowAddCurve = new WindowAddCurve();
                    this.windowAddCurve.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);

                    PopUpManager.addPopUp(this.windowAddCurve, this, false);
                    PopUpManager.centerPopUp(this.windowAddCurve);
                }
            }
        }

        private function btnRemoveItemClick(evt:MouseEvent):void
        {
            var itm:Object;
            
            if(this.accordion.selectedIndex == 0)
            {
                for each (itm in this.gridVertices.selectedItems)
                {
                    this.meshManager.removeVertex(itm);
                }
            }
            else if(this.accordion.selectedIndex == 1)
            {
                for each (itm in this.gridElements.selectedItems)
                {
                    this.meshManager.removeElement(itm);
                }
            }
            else if(this.accordion.selectedIndex == 2)
            {
                for each (itm in this.gridBoundaries.selectedItems)
                {
                    this.meshManager.removeBoundary(itm);
                }
            }
            else if(this.accordion.selectedIndex == 3)
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
            else if (evt.target is WindowAddBoundary)
            {
                PopUpManager.removePopUp(this.windowAddBoundary);
                this.windowAddBoundary = null;
            }
            else if(evt.target is WindowShowHelp)
            {
                PopUpManager.removePopUp(this.windowShowHelp);
                this.windowShowHelp = null;
            }
        }

        private function vertexSubmitted(evt:MeshEditorEvent):void
        {
            this.meshManager.addVertex(evt.data);
        }

        private function elementSubmitted(evt:MeshEditorEvent):void
        {
            this.meshManager.addElement(evt.data);
        }

        private function boundarySubmitted(evt:MeshEditorEvent):void
        {
            this.meshManager.addBoundary(evt.data);
        }

        private function meshManagerVertexAdded(evt:MeshEditorEvent):void
        {
            if(this.windowAddElement != null)
                this.windowAddElement.addAvailableVertex(evt.data);

            this.drawingArea.addVertex(evt.data);
        }

        private function meshManagerVertexRemoved(evt:MeshEditorEvent):void
        {
            this.drawingArea.removeVertex(evt.data);
        }

        private function meshManagerVertexUpdated(evt:MeshEditorEvent):void
        {
            this.drawingArea.updateVertex(evt.data);
        }

        private function meshManagerElementAdded(evt:MeshEditorEvent):void
        {
            this.drawingArea.addElement(evt.data);
        }

        private function meshManagerBoundaryAdded(evt:MeshEditorEvent):void
        {
            this.drawingArea.addBoundary(evt.data);
        }

        private function meshManagerElementRemoved(evt:MeshEditorEvent):void
        {
            this.drawingArea.removeElement(evt.data);
        }

        private function meshManagerElementUpdated(evt:MeshEditorEvent):void
        {
            this.drawingArea.updateElement(evt.data);
        }

        private function meshManagerBoundaryRemoved(evt:MeshEditorEvent):void
        {
            this.drawingArea.removeBoundary(evt.data);
        }

        private function meshManagerBoundaryUpdated(evt:MeshEditorEvent):void
        {
            this.drawingArea.updateBoundary(evt.data);
        }

        private function gridVerticesItemRollOver(evt:ListEvent):void
        {
            var dgir:DataGridItemRenderer = DataGridItemRenderer(evt.itemRenderer);
            var dgirData:Object = Object(dgir.data);

            if(evt.target == this.gridVertices)
                this.drawingArea.selectVertex(dgirData);
            else
            {
                this.drawingArea.selectVertex({id:evt.rowIndex});
            }
        }

        private function gridVerticesItemEditEnd(evt:DataGridEvent):void
        {
            if (evt.reason == DataGridEventReason.CANCELLED)
            {
                return;
            }

            var newData:String = TextInput(evt.currentTarget.itemEditorInstance).text;

            if(newData == "" || isNaN(parseFloat(newData)))
            {
                evt.preventDefault();
                TextInput(evt.currentTarget.itemEditorInstance).errorString = "Enter a valid Number.";
                return;
            }
            else
            {
                this.meshManager.updatedVertex = this.gridVertices.selectedItem;
            }
        }

        protected function gridBoundariesItemEditEnd(evt:DataGridEvent):void
        {
            if (evt.reason == DataGridEventReason.CANCELLED)
            {
                return;
            }

            var newData:String = TextInput(evt.currentTarget.itemEditorInstance).text;

            if(newData == "" || isNaN(parseFloat(newData)))
            {
                evt.preventDefault();
                TextInput(evt.currentTarget.itemEditorInstance).errorString = "Enter a valid Number.";
                return;
            }
            /*
            else
            {
                this.meshManager.updatedBoundary = this.gridVertices.selectedItem;
            }*/
        }

        protected function gridElementsItemRollOver(evt:ListEvent):void
        {
            var dgir:DataGridItemRenderer = DataGridItemRenderer(evt.itemRenderer);
            var dgirData:Object = Object(dgir.data);

            this.drawingArea.selectElement(dgirData);
        }

        protected function gridBoundariesItemRollOver(evt:ListEvent):void
        {
            var dgir:DataGridItemRenderer = DataGridItemRenderer(evt.itemRenderer);
            var dgirData:Object = Object(dgir.data);

            this.drawingArea.selectBoundary(dgirData);
        }

        private function elementSelected(evt:MeshEditorEvent):void
        {
            this.drawingArea.selectElement(evt.data);
        }

        private function boundarySelected(evt:MeshEditorEvent):void
        {
            this.drawingArea.selectBoundary(evt.data);
        }

        private function btnSaveMeshClick(evt:MouseEvent):void
        {
            this.meshfile = new FileReference();

            //var data:XML = new XML( this.meshManager.getMeshXML() );
            var data:String = this.meshManager.getMeshHermes();

            this.meshfile.save(data, "domain.mesh")
        }

        private function btnSubmitMeshClick(evt:MouseEvent):void
        {
            var var_name:String = Application.application.parameters['var_name'] == null ? 'domain' : Application.application.parameters['var_name'];
            var arg:String = var_name + " = Mesh(" + this.meshManager.getMeshCSV() + ")";
            trace(arg)

            if(ExternalInterface.available)
            {
                ExternalInterface.call("autogenerated_cell", Application.application.parameters['output_cell'], arg);
            }
            else
            {
                trace("-No External Interface-");
            }
        }

        private function btnTriangulateMeshClick(evt:MouseEvent):void
        {
            var httpTriangulationService:HTTPService = new HTTPService();
            httpTriangulationService.addEventListener(ResultEvent.RESULT, this.httpTriangulationServiceResultHandler);

            //httpTriangulationService.url = "http://localhost/~aayush/cgi-bin/generate_mesh.py";
            httpTriangulationService.url = "http://hpfem.org/~aayush/cgi-bin/generate_mesh.py";
            
            httpTriangulationService.method = "POST";
            httpTriangulationService.resultFormat = "xml"
            httpTriangulationService.request = this.meshManager.getDomainForTriangulation();
            httpTriangulationService.send();
        }

        private function httpTriangulationServiceResultHandler(evt:ResultEvent):void
        {
            var res:XML = XML(String(evt.result));

            this.btnClearClick(null);
            this.meshManager.loadXmlData(res);
        }

        private function btnClearClick(evt:MouseEvent):void
        {
            this.drawingArea.clear();
            this.meshManager.clear();
        }

        private function btnHelpClick(evt:MouseEvent):void
        {
            if(this.windowShowHelp == null)
            {
                this.windowShowHelp = new WindowShowHelp();
                this.windowShowHelp.addEventListener(CloseEvent.CLOSE, this.windowCloseClick, false, 0, true);

                PopUpManager.addPopUp(this.windowShowHelp, this, false);
                PopUpManager.centerPopUp(this.windowShowHelp);
            }
        }

        private function btnLoadMeshClick(evt:MouseEvent):void
        {
            this.meshfile = new FileReference();
            this.meshfile.addEventListener(Event.COMPLETE, this.meshfileLoadComplete, false, 0, true);
            this.meshfile.addEventListener(Event.CANCEL, this.meshfileCancle, false, 0, true);
            this.meshfile.addEventListener(Event.SELECT, this.meshfileSelect, false, 0, true);
            this.meshfile.browse([new FileFilter("domain", "*.mesh")]);
        }

        private function meshfileLoadComplete(evt:Event):void
        {
            this.btnClearClick(null);

            //var xml:XML = new XML(this.meshfile.data);
            //this.meshManager.loadXmlData(xml);

            this.meshManager.loadHermesData(String(this.meshfile.data));
        }

        private function meshfileCancle(evt:Event):void
        {
            trace("-c12-");
            this.stage.focus = this;
        }

        private function meshfileSelect(evt:Event):void
        {
            this.meshfile.load();
        }

        private function accordionChange(evt:IndexChangedEvent):void
        {
            this.drawingArea.changeMode(this.accordion.selectedIndex)
        }

        private function chkBoxShowElementChange(evt:Event):void
        {
            this.drawingArea.showHideElement();
        }

        private function chkBoxShowBoundaryChange(evt:Event):void
        {
            this.drawingArea.showHideBoundary();
        }

        private function drawingAreaVertexUpdated(evt:MeshEditorEvent):void
        {
            this.gridVertices.dataProvider  = this.meshManager.vertices;
            this.meshManager.updateElementWithVertex(evt.data);
            this.meshManager.updateBoundaryWithVertex(evt.data);
        }

        private function drawingAreaVertexDragEnd(evt:MeshEditorEvent):void
        {
            if(this.meshManager.isVertexInsideOtherElement(evt.data) || this.meshManager.isEdgeIntersectingEdge())
            {
                evt.data.x = evt.data2.x;
                evt.data.y = evt.data2.y;
            }

            this.gridVertices.dataProvider  = this.meshManager.vertices;
            this.drawingArea.updateVertex(evt.data);
            this.meshManager.updateElementWithVertex(evt.data);
            this.meshManager.updateBoundaryWithVertex(evt.data);
        }

        private function drawingAreaVertexAdded(evt:MeshEditorEvent):void
        {
            this.meshManager.addVertex(evt.data);
        }

        private function drawingAreaVertexRemoved(evt:MeshEditorEvent):void
        {
            this.meshManager.removeVertex(evt.data);
        }

        private function drawingAreaBoundaryAdded(evt:MeshEditorEvent):void
        {
            this.meshManager.addBoundary(evt.data);
        }

        private function drawingAreaBoundaryRemoved(evt:MeshEditorEvent):void
        {
            this.meshManager.removeBoundary(evt.data);
        }

        private function drawingAreaElementAdded(evt:MeshEditorEvent):void
        {
            this.meshManager.addElement(evt.data);
        }

        private function drawingAreaElementRemoved(evt:MeshEditorEvent):void
        {
            this.meshManager.removeElement(evt.data);
        }

        private function parseFlashVars():void
        {
            //Parse and add vertices
            var vertex_list:String = Application.application.parameters['nodes'];
            if(vertex_list != "")
            {
                var vertices:Array = vertex_list.split(",");
                for each(var v:String in vertices)
                {
                    var xy:Array = v.split(" ");

                    if(xy[0] != null && xy[1] != null)
                        this.meshManager.addVertex({x:xy[0], y:xy[1]})
                }
            }

            //Parse and add Elements
            var v1:XML,v2:XML,v3:XML,v4:XML;
            var obj:Object;

            var element_list:String = Application.application.parameters['elements'];
            if(element_list != "")
            {
                var elements:Array = element_list.split(",");
                for each(var e:String in elements)
                {
                    var vertex:Array = e.split(" ");
                    obj = new Object();

                    if(vertex.length == 4 && vertex[0] != null && vertex[1] != null && vertex[2] != null && vertex[3] != null)
                    {
                        obj.v1 = this.meshManager.getVertex(int(vertex[0]));
                        obj.v2 = this.meshManager.getVertex(int(vertex[1]));
                        obj.v3 = this.meshManager.getVertex(int(vertex[2]));

                        this.meshManager.addElement(obj);
                    }
                    else if(vertex.length == 5 && vertex[0] != null && vertex[1] != null && vertex[2] != null && vertex[3] != null && vertex[4] != null)
                    {
                        obj.v1 = this.meshManager.getVertex(int(vertex[0]));
                        obj.v2 = this.meshManager.getVertex(int(vertex[1]));
                        obj.v3 = this.meshManager.getVertex(int(vertex[2]));
                        obj.v4 = this.meshManager.getVertex(int(vertex[3]));

                        this.meshManager.addElement(obj);
                    }
                }
            }

            //Parse and add Boundaries
            var boundary_list:String = Application.application.parameters['boundaries'];
            if(vertex_list != "")
            {
                var boundaries:Array = boundary_list.split(",");
                for each(var b:String in boundaries)
                {
                    var vertex_marker:Array = b.split(" ");
                    obj = new Object()

                    if(vertex_marker[0] != null && vertex_marker[1] != null && vertex_marker[2] != null)
                    {
                        obj.v1 = this.meshManager.getVertex(int(vertex_marker[0]));
                        obj.v2 = this.meshManager.getVertex(int(vertex_marker[1]));
                        obj.marker = vertex_marker[2];

                        //ExternalInterface.call("alert", obj.v1.id + " " + obj.v1.id + " " + obj.marker);
                        this.meshManager.addBoundary(obj)
                    }
                }
            }
        }
    }
}

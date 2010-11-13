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

    import com.*;
    import com.window.*;

    public class MeshEditor extends Application
    {
        // Components in MXML
        public var btnShowWindow:Button;
        public var btnRemoveItem:Button;
        public var gridVertices:DataGrid;
        public var gridElements:DataGrid;
        public var gridBoundaries:DataGrid;
        public var accordion:Accordion;
        public var btnSubmitMesh:Button;
        public var btnSaveMesh:Button;
        public var btnLoadMesh:Button;
        public var btnTriangulateMesh:Button;
        public var btnClear:Button;
        public var btnHelp:Button;
        public var btnZoomIn:Button;
        public var btnZoomOut:Button;
        public var  btnDeleteMesh:Button;
        public var chkBoxShowElement:CheckBox;
        public var chkBoxShowBoundary:CheckBox;
        public var lblCordinate:Label;
        public var hboxDrawingArea:HBox;
        public var hScrollBar:HScrollBar;
        public var vScrollBar:VScrollBar;
        public var txtEvaluate:TextInput;

        private var windowAddVertex:WindowAddVertex;
        private var windowAddElement:WindowAddElement;
        private var windowAddBoundary:WindowAddBoundary;
        private var windowAddCurve:WindowAddCurve;
        private var windowShowHelp:WindowShowHelp;

        public var meshManager:MeshManager;
        private var drawingArea:DrawingArea;
        private var meshfile:FileReference;

        private var rpcConnection:Rpc;

        private var oldBoundaryAngle:int;

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

            if (this.loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
            {
                IEventDispatcher(this.loaderInfo["uncaughtErrorEvents"]).addEventListener("uncaughtError", this.uncaughtErrorHandler);
            }
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.chkBoxShowElement.addEventListener(Event.CHANGE, this.chkBoxShowElementChange);
            this.chkBoxShowBoundary.addEventListener(Event.CHANGE, this.chkBoxShowBoundaryChange);
            this.btnShowWindow.addEventListener(MouseEvent.CLICK, this.btnShowWindowClick);
            this.btnSubmitMesh.addEventListener(MouseEvent.CLICK, this.btnSubmitMeshClick);
            this.btnRemoveItem.addEventListener(MouseEvent.CLICK, this.btnRemoveItemClick);
            this.btnSaveMesh.addEventListener(MouseEvent.CLICK, this.btnSaveMeshClick);
            this.btnLoadMesh.addEventListener(MouseEvent.CLICK, this.btnLoadMeshClick);
            this.btnTriangulateMesh.addEventListener(MouseEvent.CLICK, this.btnTriangulateMeshClick);
            this.btnClear.addEventListener(MouseEvent.CLICK, this.btnClearClick);
            this.btnHelp.addEventListener(MouseEvent.CLICK, this.btnHelpClick);
            this.btnZoomIn.addEventListener(MouseEvent.CLICK, this.btnZoomInClick);
            this.btnZoomOut.addEventListener(MouseEvent.CLICK, this.btnZoomOutClick);
            this.btnDeleteMesh.addEventListener(MouseEvent.CLICK, this.btnDeleteMeshClick);

            this.gridVertices.addEventListener(ListEvent.ITEM_ROLL_OVER, this.gridVerticesItemRollOver);
            this.gridVertices.addEventListener(ListEvent.CHANGE, this.gridVerticesItemRollOver);
            this.gridVertices.addEventListener(DataGridEvent.ITEM_EDIT_END, this.gridVerticesItemEditEnd);

            this.drawingArea = new DrawingArea();
            this.drawingArea.addEventListener(MeshEditorEvent.VERTEX_ADDED, this.drawingAreaVertexAdded);
            this.drawingArea.addEventListener(MeshEditorEvent.VERTEX_REMOVED, this.drawingAreaVertexRemoved);
            this.drawingArea.addEventListener(MeshEditorEvent.VERTEX_UPDATED, this.drawingAreaVertexUpdated);
            this.drawingArea.addEventListener(MeshEditorEvent.VERTEX_DRAG_END, this.drawingAreaVertexDragEnd);
            this.drawingArea.addEventListener(MeshEditorEvent.ELEMENT_ADDED, this.drawingAreaElementAdded);
            this.drawingArea.addEventListener(MeshEditorEvent.ELEMENT_REMOVED, this.drawingAreaElementRemoved);
            this.drawingArea.addEventListener(MeshEditorEvent.BOUNDARY_ADDED, this.drawingAreaBoundaryAdded);
            this.drawingArea.addEventListener(MeshEditorEvent.BOUNDARY_REMOVED, this.drawingAreaBoundaryRemoved);
            this.drawingArea.addEventListener(MouseEvent.MOUSE_OUT, this.drawingAreaMouseOut);
            this.drawingArea.addEventListener(MouseEvent.MOUSE_MOVE, this.drawingAreaMouseMove);
            this.drawingArea.addEventListener(MouseEvent.MOUSE_WHEEL, this.drawingAreaMouseWheel);
            this.drawingArea.addEventListener(MouseEvent.MOUSE_UP, this.drawingAreaMouseUp);
            this.drawingArea.addEventListener(MouseEvent.MOUSE_DOWN, this.drawingAreaMouseDown);
            this.hboxDrawingArea.addChild(this.drawingArea);

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

            this.hScrollBar.addEventListener(ScrollEvent.SCROLL, this.hScrollBarScroll);
            this.vScrollBar.addEventListener(ScrollEvent.SCROLL, this.vScrollBarScroll);

            this.rpcConnection = new Rpc("http://localhost:8000/async");
            this.rpcConnection.addEventListener(MeshEditorEvent.RPC_RESULT, this.rpcConnectionRpcResult);

            try
            {
                this.parseFlashVars();
            }
            catch(e:Error) {}
        }

        private function uncaughtErrorHandler(evt:ErrorEvent):void
        {
            var em:String = "-- Uncaught Error --";

            trace(em);
            Debug.jsLog(em);

            em = evt["error"].toString();

            trace(em);
            Debug.jsLog(em);

            trace("Stack Trace:")
            Debug.jsLog("Stack Trace:");

            em = evt["error"].getStackTrace()

            trace(em);
            Debug.jsLog(em);
        }

        private function rpcConnectionRpcResult(evt:MeshEditorEvent):void
        {
            Debug.jsLog("RPC.Engine.evaluate() ressult:");
            Debug.jsLog(evt.data.result.out);
            trace("RPC.Engine.evaluate() ressult:");
            trace(evt.data.result.out);

            var res:XML = XML(String(evt.data.result.out));

            this.btnClearClick(null);
            this.meshManager.loadXmlData(res);
        }

        private function hScrollBarScroll(evt:ScrollEvent):void
        {
            this.drawingArea.scrollCanvas(-1, evt.position);
        }

        private function vScrollBarScroll(evt:ScrollEvent):void
        {
            this.drawingArea.scrollCanvas(evt.position, -1);
        }

        private function zoomInOut():void
        {
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
            else if(evt.ctrlKey && evt.charCode == 13)//submit
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
            else if(evt.ctrlKey && evt.charCode == 45)//zoom out
            {
                this.btnZoomOutClick(null);
            }
            else if(evt.ctrlKey && evt.charCode == 61)//zoom in
            {
                this.btnZoomInClick(null);
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

        protected function gridBoundariesItemEditPreEnd(evt:DataGridEvent):void
        {
            var grid:DataGrid = evt.target as DataGrid;
            var field:String = evt.dataField;
            var row:Number = Number(evt.rowIndex);

            if(field == "angle")
            {
                this.meshManager.updatedBoundary = grid.dataProvider.getItemAt(row);
                this.oldBoundaryAngle = int(grid.dataProvider.getItemAt(row)[field]);
            }
            else
                this.meshManager.updatedBoundary = null;
            
            trace("-oba:-", this.oldBoundaryAngle)
        }

        protected function gridBoundariesItemEditPostEnd(evt:DataGridEvent):void
        {
            if (evt.reason == DataGridEventReason.CANCELLED)
            {
                return;
            }

            var grid:DataGrid = evt.target as DataGrid;
            var field:String = evt.dataField;
            var row:Number = Number(evt.rowIndex);

            this.meshManager.updatedBoundary = grid.dataProvider.getItemAt(row);

            if(field == "angle")
            {
                var newData:String = grid.dataProvider.getItemAt(row)[field];

                if(newData == "" || isNaN(parseFloat(newData)))
                {
                    this.meshManager.updatedBoundary.angle = this.oldBoundaryAngle;
                }
                else
                {
                    var newAngle:Number = Number(newData);

                    if(newAngle != 0)
                    {
                        if(this.meshManager.isEdgeIntersectingEdge())
                        {
                            Alert.show("Some edge intersect with this chosen value of angle !", "Error !", Alert.OK, this, this.boudaryAngleAlertHandler)
                        }
                    }
                }
            }
        }

        private function boudaryAngleAlertHandler(evt:CloseEvent):void
        {
            this.meshManager.updatedBoundary.angle = this.oldBoundaryAngle;
            this.meshManager.boundariesChange(null);
            this.gridBoundaries.dataProvider = this.meshManager.boundaries;
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
            else
            {
                var grid:DataGrid = evt.target as DataGrid;
                var row:Number = Number(evt.rowIndex);

                if(evt.dataField == "angle")
                {
                    this.meshManager.updatedBoundary = grid.dataProvider.getItemAt(row);
                }
                else
                    this.meshManager.updatedBoundary = null;
            }
        }

        protected function gridElementsItemEditEnd(evt:DataGridEvent):void
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
            //var anyOutside:int = meshManager.isAnyVertexOutsideBoundary();
            var anyOutside:int = 0;

            if(anyOutside == 0)
            {
                this.writeMeshToFile();
            }
            else if(anyOutside == -1)
            {
                Alert.show("There are OPEN Boundaries. Do you still want to save mesh ?", "Warning !", 3, this, this.saveAlertClickHandler)
            }
            else if(anyOutside == -2)
            {
                Alert.show("Some vertices are outside the boundaries. Do you still want to save mesh ?", "Warning !", 3, this, this.saveAlertClickHandler)
            }
        }

        private function saveAlertClickHandler(evt:CloseEvent):void
        {
            if (evt.detail==Alert.YES)
                this.writeMeshToFile();
        }

        private function submitAlertClickHandler(evt:CloseEvent):void
        {
            if (evt.detail==Alert.YES)
                this.sumbitMeshToOnlineLab();
        }

        private function writeMeshToFile():void
        {
            this.meshfile = new FileReference();

            //var data:XML = new XML( this.meshManager.getMeshXML() );
            var data:String = this.meshManager.getMeshHermes();

            this.meshfile.save(data, "domain.mesh")
        }

        private function sumbitMeshToOnlineLab():void
        {
            var var_name:String = Application.application.parameters['var_name'] == null ? 'domain' : Application.application.parameters['var_name'];
            var arg:String = var_name + " = Mesh(" + this.meshManager.getMeshCSV() + ")";

            if(ExternalInterface.available)
            {
                ExternalInterface.call("autogenerated_cell", Application.application.parameters['output_cell'], arg);
            }
            else
            {
                trace("-No External Interface-");
            }
        }

        private function btnSubmitMeshClick(evt:MouseEvent):void
        {
            var anyOutside:int = meshManager.isAnyVertexOutsideBoundary();

            if(anyOutside == 0)
            {
                this.sumbitMeshToOnlineLab();
            }
            if(anyOutside == -1)
            {
                Alert.show("There are OPEN Boundaries. Do you still want to submit mesh ?", "Warning !", 3, this, this.submitAlertClickHandler)
            }
            else if(anyOutside == -2)
            {
                Alert.show("Some vertices are outside the boundaries. Do you still want to submit mesh ?", "Warning !", 3, this, this.submitAlertClickHandler)
            }
        }

        private function btnTriangulateMeshClick(evt:MouseEvent):void
        {
            /*
            var httpTriangulationService:HTTPService = new HTTPService();
            httpTriangulationService.addEventListener(ResultEvent.RESULT, this.httpTriangulationServiceResultHandler);

            //httpTriangulationService.url = "http://localhost/~aayush/cgi-bin/generate_mesh.py";
            httpTriangulationService.url = "http://hpfem.org/~aayush/cgi-bin/generate_mesh.py";

            httpTriangulationService.method = "POST";
            httpTriangulationService.resultFormat = "xml"
            httpTriangulationService.request = this.meshManager.getDomainForTriangulation();
            httpTriangulationService.send();
            */

            var domain:Object = this.meshManager.getDomainForTriangulation();
            //var command:String = "from femhub.triangulation import print_triangulated_mesh_xml; nodes = '0 0,0 1,1 1,1 0,0.5 0.5'; boundaries = '0 1 1 0,1 2 1 0,2 3 1 0,3 0 1 0'; print_triangulated_mesh_xml(nodes, boundaries)";
            var command:String = "from femhub.triangulation import print_triangulated_mesh_xml; print_triangulated_mesh_xml('" + domain.nodes + "','" + domain.boundaries + "')";
            this.rpcConnection.evaluate(command);
        }

        private function httpTriangulationServiceResultHandler(evt:ResultEvent):void
        {
            var res:XML = XML(String(evt.result));

            trace(res);

            this.btnClearClick(null);
            this.meshManager.loadXmlData(res);
        }

        private function btnClearClick(evt:MouseEvent):void
        {
            this.drawingArea.clear();
            this.meshManager.clear();
        }

        private function btnZoomOutClick(evt:MouseEvent):void
        {
            if(this.drawingArea.scaleFactor > 10)
            {
                this.drawingArea.scaleFactor -= 5;
                this.zoomInOut();
                this.meshManager.scaleFactor = this.drawingArea.scaleFactor;
            }
        }

        private function btnZoomInClick(evt:MouseEvent):void
        {
            if(this.drawingArea.scaleFactor < 280)
            {
                this.drawingArea.scaleFactor += 5;
                this.zoomInOut();
                this.meshManager.scaleFactor = this.drawingArea.scaleFactor;
            }
        }

        private function btnDeleteMeshClick(evt:MouseEvent):void
        {
            this.meshManager.deleteMesh();
        }

        private function drawingAreaMouseWheel(evt:MouseEvent):void
        {
            if(evt.delta > 0)
            {
                this.btnZoomInClick(null);
            }
            else
            {
                this.btnZoomOutClick(null);
            }
        }

        private function drawingAreaMouseUp(evt:MouseEvent):void
        {
            this.drawingArea.mouseUp(evt);
        }

        private function drawingAreaMouseDown(evt:MouseEvent):void
        {
            this.drawingArea.mouseDown(evt);
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
            this.meshManager.updateBoundaryWithVertex(evt.data);
            this.meshManager.updateElementWithVertex(evt.data);
        }

        private function drawingAreaVertexDragEnd(evt:MeshEditorEvent):void
        {
            if(this.meshManager.isAnyVertexInsideAnyElement() || this.meshManager.isEdgeIntersectingEdge())
            {
                evt.data.x = evt.data2.x;
                evt.data.y = evt.data2.y;
            }

            this.gridVertices.dataProvider  = this.meshManager.vertices;
            this.drawingArea.updateVertex(evt.data);
            this.meshManager.updateBoundaryWithVertex(evt.data);
            this.meshManager.updateElementWithVertex(evt.data);
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

        private function drawingAreaMouseOut(evt:MouseEvent):void
        {
            this.lblCordinate.text = "";
        }

        private function drawingAreaMouseMove(evt:MouseEvent):void
        {
            var x:Number = int(this.drawingArea.canvas.mouseX / this.drawingArea.scaleFactor * 1000) / 1000;
            var y:Number = int(-this.drawingArea.canvas.mouseY / this.drawingArea.scaleFactor * 1000) / 1000;

            this.lblCordinate.text = String(x) + " , " + String(y);
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

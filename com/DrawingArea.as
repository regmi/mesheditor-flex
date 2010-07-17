package com
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    import flash.filters.*;
    import mx.core.*;
    import com.VertexMarker;
    import mx.managers.*;

    public class DrawingArea extends UIComponent
    {
        private var dictVertexMarker:Dictionary;
        private var dictElementMarker:Dictionary;
        private var dictBoundaryMarker:Dictionary;

        private var vertexContainer:Sprite;
        private var elementContainer:Sprite;
        private var boundaryContainer:Sprite;

        private var vertexSelectMarker:VertexSelectMarker;
        private var elementSelectMarker:ElementSelectMarker;
        private var boundarySelectMarker:BoundarySelectMarker;

        private var canvas:Sprite;
        private var grid:Grid;
        private var selectionLine:Sprite;
        
        public var scaleFactor:Number;
        private var vertexDragged:VertexMarker;

        private var timerUpdateVertex:Timer;
        private var timerUpdateSelectionLine:Timer;

        private const ADD_ELEMENT:int = 1;
        private const ADD_BOUNDARY:int = 2;

        private var readyToAdd:int;
        private var selectedVertexQueue:Array;
        private var pointBeforeDrag:Point;

        public function DrawingArea(w:int, h:int):void
        {
            super();

            this.width = w;
            this.height = h;
            this.scaleFactor = 240;

            this.vertexContainer = new Sprite();
            this.elementContainer = new Sprite();
            this.boundaryContainer = new Sprite();

            this.graphics.beginFill(0xFFFFFF);
            this.graphics.drawRect(0,0,w,h);
            this.graphics.endFill();

            this.grid = new Grid();
            this.grid.drawGrid(this.scaleFactor);

            var mask:Sprite = new Sprite();
            mask.graphics.beginFill(0xFFFFFF);
            mask.graphics.drawRect(0,0,w,h);
            mask.graphics.endFill();

            this.selectionLine = new Sprite();

            this.canvas = new Sprite();
            this.canvas.addChild(this.grid);
            this.canvas.addChild(this.elementContainer);
            this.canvas.addChild(this.boundaryContainer);
            this.canvas.addChild(this.vertexContainer);
            this.canvas.x = this.width/2;
            this.canvas.y = this.height/2;
            this.canvas.doubleClickEnabled = true;
            this.canvas.addEventListener(MouseEvent.MOUSE_DOWN, this.canvasMouseDown);
            this.canvas.addEventListener(MouseEvent.MOUSE_UP, this.canvasMouseUp);
            this.canvas.addEventListener(MouseEvent.DOUBLE_CLICK, this.canvasMouseDoubleClick);

            this.addChild(this.canvas);
            this.addChild(mask);

            this.canvas.mask = mask;

            this.dictVertexMarker = new Dictionary();
            this.dictElementMarker = new Dictionary();
            this.dictBoundaryMarker = new Dictionary();

            this.vertexSelectMarker = new VertexSelectMarker();
            this.elementSelectMarker = new ElementSelectMarker();
            this.boundarySelectMarker = new BoundarySelectMarker();

            this.timerUpdateVertex = new Timer(50);
            this.timerUpdateVertex.addEventListener(TimerEvent.TIMER, this.timerUpdateVertexTimer);

            this.timerUpdateSelectionLine = new Timer(100);
            this.timerUpdateSelectionLine.addEventListener(TimerEvent.TIMER, this.timerUpdateSelectionLineTimer);

            this.vertexDragged = null;
            this.pointBeforeDrag = new Point();

            this.readyToAdd = 0;
            this.selectedVertexQueue = [];

            this.addEventListener(MouseEvent.MOUSE_UP, this.drawingAreaMouseUp);
            this.addEventListener(MouseEvent.MOUSE_DOWN, this.drawingAreaMouseDown);
        }

        public function addVertex(data:Object):void
        {
            var vm:VertexMarker = new VertexMarker(data);
            vm.updateVertex(this.scaleFactor);

            this.dictVertexMarker[data.id] = vm;
            this.vertexContainer.addChild(vm);
        }

        public function updateVertex(data:Object):void
        {
            var vm:VertexMarker = this.dictVertexMarker[data.id];
            vm.updateVertex(this.scaleFactor);
        }

        public function removeVertex(data:Object):void
        {
            this.vertexContainer.removeChild(this.dictVertexMarker[data.id]);
            delete this.dictVertexMarker[data.id];

            this.vertexSelectMarker.timeOut(null);
        }

        public function selectVertex(data:Object):void
        {
            this.vertexSelectMarker.x = this.dictVertexMarker[int(data.id)].x;
            this.vertexSelectMarker.y = this.dictVertexMarker[int(data.id)].y;
            this.vertexContainer.addChild(this.vertexSelectMarker);

            this.vertexSelectMarker.setTimeOut();
        }

        public function addElement(data:Object):void
        {
            var em:ElementMarker = new ElementMarker(data);
            this.dictElementMarker[data.id] = em;
            this.elementContainer.addChild(em);

            em.drawBorder(data, this.scaleFactor);
        }

        public function updateElement(data:Object):void
        {
            var em:ElementMarker = this.dictElementMarker[data.id] ;
            em.drawBorder(data, this.scaleFactor);
        }

        public function removeElement(data:Object):void
        {
            this.elementContainer.removeChild(this.dictElementMarker[data.id]);
            delete this.dictElementMarker[data.id];

            this.elementSelectMarker.timeOut(null);
        }

        public function selectElement(data:Object):void
        {
            this.elementContainer.addChild(this.elementSelectMarker);
            this.elementSelectMarker.drawBorder(data, this.scaleFactor);

            this.elementSelectMarker.setTimeOut();
        }

        public function addBoundary(data:Object):void
        {
            var bm:BoundaryMarker = new BoundaryMarker(data);
            this.dictBoundaryMarker[data.id] = bm;
            this.boundaryContainer.addChild(bm);

            bm.drawBorder(data, this.scaleFactor);
        }

        public function updateBoundary(data:Object):void
        {
            var bm:BoundaryMarker = this.dictBoundaryMarker[data.id] ;
            bm.drawBorder(data, this.scaleFactor);
        }

        public function removeBoundary(data:Object):void
        {
            this.boundaryContainer.removeChild(this.dictBoundaryMarker[data.id]);
            delete this.dictBoundaryMarker[data.id];

            this.elementSelectMarker.timeOut(null);
        }

        public function selectBoundary(data:Object):void
        {
            this.boundaryContainer.addChild(this.boundarySelectMarker);

            this.boundarySelectMarker.drawBorder(data, this.scaleFactor);
            this.boundarySelectMarker.setTimeOut();
        }

        public function clear():void
        {
            var key:String;

            for(key in this.dictVertexMarker)
            {
                this.vertexContainer.removeChild(this.dictVertexMarker[key]);
                delete this.dictVertexMarker[key];
            }

            for(key in this.dictElementMarker)
            {
                this.elementContainer.removeChild(this.dictElementMarker[key]);
                delete this.dictElementMarker[key];
            }

            for(key in this.dictBoundaryMarker)
            {
                this.boundaryContainer.removeChild(this.dictBoundaryMarker[key]);
                delete this.dictBoundaryMarker[key];
            }
        }

        public function getClickedPoint():Point
        {
            var p:Point = new Point();
            p.x = this.elementContainer.mouseX/this.scaleFactor;
            p.y = this.elementContainer.mouseY/this.scaleFactor;
            return p;
        }

        private function timerUpdateVertexTimer(evt:TimerEvent):void
        {
            this.vertexDragged.updateDataProvider(this.scaleFactor);

            var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_UPDATED);
            e.data = this.vertexDragged.dataProvider;

            this.dispatchEvent(e);
        }

        private function timerUpdateSelectionLineTimer(evt:TimerEvent):void
        {
            this.selectionLine.graphics.clear();
            this.selectionLine.graphics.lineStyle(1, 0xFF00FF);
            this.selectionLine.graphics.moveTo(this.selectedVertexQueue[0].dataProvider.x*this.scaleFactor, -this.selectedVertexQueue[0].dataProvider.y*this.scaleFactor);

            for(var i:int=1;i<this.selectedVertexQueue.length;i++)
            {
                this.selectionLine.graphics.lineTo(this.selectedVertexQueue[i].dataProvider.x*this.scaleFactor, -this.selectedVertexQueue[i].dataProvider.y*this.scaleFactor);
            }

            this.selectionLine.graphics.lineTo(this.selectionLine.mouseX-3, (this.selectionLine.mouseY-3));
        }

        private function canvasMouseUp(evt:MouseEvent):void
        {
            if(evt.target is VertexMarker)
            {
                evt.target.stopDrag();
                this.timerUpdateVertex.stop();

                var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_DRAG_END);
                e.data = this.vertexDragged.dataProvider;
                e.data2 = this.pointBeforeDrag;

                this.dispatchEvent(e);

                this.vertexDragged = null;
                //pointBeforeDrag = null;
            }
        }

        private function canvasMouseDown(evt:MouseEvent):void
        {
            if(evt.target is VertexMarker)
            {
                this.vertexDragged = VertexMarker(evt.target);
                evt.target.startDrag();

                //pointBeforeDrag = new Point();

                pointBeforeDrag.x = this.vertexDragged.dataProvider.x;
                pointBeforeDrag.y = this.vertexDragged.dataProvider.y;

                this.timerUpdateVertex.start();
            }
        }

        private function canvasMouseDoubleClick(evt:MouseEvent):void
        {
            var e:MeshEditorEvent;

            if(evt.target is VertexMarker)
            {
                e = new MeshEditorEvent(MeshEditorEvent.VERTEX_REMOVED);
                e.data = (evt.target as VertexMarker).dataProvider;
                this.dispatchEvent(e);
            }
            else if(evt.target is ElementMarker)
            {
                e = new MeshEditorEvent(MeshEditorEvent.ELEMENT_REMOVED);
                e.data = (evt.target as ElementMarker).dataProvider;
                this.dispatchEvent(e);
            }
            else if(evt.target is BoundaryMarker)
            {
                e = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_REMOVED);
                e.data = (evt.target as BoundaryMarker).dataProvider;
                this.dispatchEvent(e);
            }
        }

        private function canvasMouseClick(evt:MouseEvent):void
        {
            if(evt.target is VertexMarker)
            {
                var v1:Object, v2:Object, v3:Object, v4:Object;
                var e:MeshEditorEvent;

                this.addToSelectedVertexQueue(evt.target as VertexMarker);
                (evt.target as VertexMarker).toggleSelect(true);

                if(this.selectedVertexQueue.length == 1)
                {
                    if(this.readyToAdd == this.ADD_ELEMENT)
                    {
                        this.elementContainer.addChild(this.selectionLine);
                    }
                    else if(this.readyToAdd == this.ADD_BOUNDARY)
                    {
                        this.boundaryContainer.addChild(this.selectionLine);
                    }

                    this.timerUpdateSelectionLine.start();
                }

                if(this.readyToAdd == this.ADD_BOUNDARY && this.selectedVertexQueue.length >= 2)
                {
                    this.timerUpdateSelectionLine.stop();
                    this.selectionLine.graphics.clear();
                    this.boundaryContainer.removeChild(this.selectionLine);

                    v1 = selectedVertexQueue.pop();
                    v1.toggleSelect(false);

                    v2 = selectedVertexQueue.pop();
                    v2.toggleSelect(false);

                    e = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_ADDED);
                    e.data = {v1:v1.dataProvider, v2:v2.dataProvider, marker:1};
                    this.dispatchEvent(e);
                }
                else if(this.readyToAdd == this.ADD_ELEMENT && this.selectedVertexQueue.length == 4)
                {
                    this.timerUpdateSelectionLine.stop();
                    this.selectionLine.graphics.clear();
                    this.elementContainer.removeChild(this.selectionLine);

                    v1 = selectedVertexQueue.pop();
                    v1.toggleSelect(false);

                    v2 = selectedVertexQueue.pop();
                    v2.toggleSelect(false);

                    v3 = selectedVertexQueue.pop();
                    v3.toggleSelect(false);

                    v4 = selectedVertexQueue.pop();
                    v4.toggleSelect(false);

                    e = new MeshEditorEvent(MeshEditorEvent.ELEMENT_ADDED);

                    if(v1 == v4)
                        e.data = {v1:v1.dataProvider, v2:v2.dataProvider, v3:v3.dataProvider};
                    else
                        e.data = {v1:v1.dataProvider, v2:v2.dataProvider, v3:v3.dataProvider, v4:v4.dataProvider};
                    
                    this.dispatchEvent(e);
                }
            }
        }

        private function addToSelectedVertexQueue(vm:VertexMarker):void
        {
            if(this.selectedVertexQueue.length<4)
            {
                this.selectedVertexQueue.push(vm)
            }
            else
            {
                this.selectedVertexQueue.shift();
                this.selectedVertexQueue.push(vm);
            }

            //trace queue
            //var str:String = ""
            //for each(var v:VertexMarker in this.selectedVertexQueue)
            //    str += v.dataProvider.id + ", ";
            //trace(str);
        }

        public function clearSelectedVertexQueue():void
        {
            for each(var vm:VertexMarker in this.selectedVertexQueue)
            {
                vm.toggleSelect(false);
            }

            this.selectedVertexQueue.splice(0,this.selectedVertexQueue.length);

            this.timerUpdateSelectionLine.stop();
            this.selectionLine.graphics.clear();

            try
            {
                this.elementContainer.removeChild(this.selectionLine);
            }catch(e:Error){}

            try
            {
                this.boundaryContainer.removeChild(this.selectionLine);
            }catch(e:Error){}
        }

        private function drawingAreaMouseDown(evt:MouseEvent):void
        {
            if(evt.shiftKey)
            {
                this.canvas.startDrag();
            }
        }

        private function drawingAreaMouseUp(evt:MouseEvent):void
        {
            if(evt.ctrlKey)
            {
                var p:Point = this.getClickedPoint();
                var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_ADDED);
                e.data = {x:p.x, y:-p.y};
                this.dispatchEvent(e);
            }
            else
            {
                this.canvas.stopDrag();

                if(evt.target is DrawingArea)
                {
                    this.clearSelectedVertexQueue();
                }
            }
        }

        public function changeMode(mode:int):void
        {
            this.readyToAdd = mode;
            this.clearSelectedVertexQueue();

            if(mode == 0)
            {
                this.canvas.addEventListener(MouseEvent.MOUSE_DOWN, this.canvasMouseDown);
                this.canvas.addEventListener(MouseEvent.MOUSE_UP, this.canvasMouseUp);
                this.canvas.removeEventListener(MouseEvent.CLICK, this.canvasMouseClick);
            }
            else
            {
                this.canvas.removeEventListener(MouseEvent.MOUSE_DOWN, this.canvasMouseDown);
                this.canvas.removeEventListener(MouseEvent.MOUSE_UP, this.canvasMouseUp);
                this.canvas.addEventListener(MouseEvent.CLICK, this.canvasMouseClick);
            }
        }

        public function updateGrid():void
        {
            this.grid.drawGrid(this.scaleFactor);
        }

        public function showHideElement():void
        {
            this.elementContainer.visible = !this.elementContainer.visible;
        }

        public function showHideBoundary():void
        {
            this.boundaryContainer.visible = !this.boundaryContainer.visible;
        }
    }
}

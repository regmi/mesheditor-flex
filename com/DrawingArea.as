package com
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    import flash.filters.*;
    import mx.core.*;
    import com.VertexMarker;

    public class DrawingArea extends UIComponent
    {
        private var dictVertexMarker:Dictionary;
        private var dictElementMarker:Dictionary;

        private var vertexContainer:Sprite;
        private var elementContainer:Sprite;

        private var vertexSelectMarker:VertexSelectMarker;
        private var elementSelectMarker:ElementSelectMarker;
        private var boundarySelectMarker:BoundarySelectMarker;
        private var canvas:Sprite
        public var scaleFactor:Number;

        public function DrawingArea(w:int, h:int):void
        {
            super();

            this.width = w;
            this.height = h;
            this.scaleFactor = 240;

            this.vertexContainer = new Sprite();
            this.elementContainer = new Sprite();

            this.graphics.beginFill(0xFFFFFF);
            this.graphics.drawRect(0,0,w,h);
            this.graphics.endFill();

            var g:Grid = new Grid();
            g.drawGrid();

            var mask:Sprite = new Sprite();
            mask.graphics.beginFill(0xFFFFFF);
            mask.graphics.drawRect(0,0,w,h);
            mask.graphics.endFill();

            this.canvas = new Sprite();
            this.canvas.addChild(g);
            this.canvas.addChild(this.elementContainer);
            this.canvas.addChild(this.vertexContainer);
            this.canvas.x = this.width/2;
            this.canvas.y = this.height/2;

            this.addChild(this.canvas);
            this.addChild(mask);

            this.canvas.mask = mask;

            this.dictVertexMarker = new Dictionary();
            this.dictElementMarker = new Dictionary();

            this.vertexSelectMarker = new VertexSelectMarker();
            this.elementSelectMarker = new ElementSelectMarker();
            this.boundarySelectMarker = new BoundarySelectMarker();
        }

        public function addVertex(data:Object):void
        {
            var vm:VertexMarker = new VertexMarker();
            vm.x = this.scaleFactor*data.x;
            vm.y = -this.scaleFactor*data.y;

            this.dictVertexMarker[data.id] = vm;
            this.vertexContainer.addChild(vm);
        }

        public function updateVertex(data:Object):void
        {
            var vm:VertexMarker = this.dictVertexMarker[data.id];
            vm.x = this.scaleFactor*data.x;
            vm.y = -this.scaleFactor*data.y;
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
            var em:ElementMarker = new ElementMarker();
            this.dictElementMarker[data.id] = em;
            this.elementContainer.addChild(em);

            em.drawBorder(data, this.scaleFactor);
        }

        public function updateElement(data:Object):void
        {
            var em:Object = this.dictElementMarker[data.id] ;
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

        public function selectBoundary(data:Object):void
        {
            this.elementContainer.addChild(this.elementSelectMarker);
            this.elementSelectMarker.drawBorder(data, this.scaleFactor);

            this.elementSelectMarker.setTimeOut();
        }

        public function clear():void
        {
            var key:String;

            for(key in this.dictVertexMarker)
            {
                this.vertexContainer.removeChild(this.dictVertexMarker[key]);
                this.dictVertexMarker[key] = null;
            }

            for(key in this.dictElementMarker)
            {
                this.elementContainer.removeChild(this.dictElementMarker[key]);
                this.dictElementMarker[key] = null;
            }
        }

        public function getClickedPoint():Point
        {
            var p:Point = new Point();
            p.x = this.elementContainer.mouseX/this.scaleFactor;
            p.y = this.elementContainer.mouseY/this.scaleFactor;
            return p;
        }

        public function stopDragCanvas():void
        {
            this.canvas.stopDrag();
        }

        public function startDragCanvas():void
        {
            this.canvas.startDrag();
        }
    }
}

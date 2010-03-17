package com
{
    import flash.display.*;
    import flash.events.*;
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

        public function DrawingArea(w:int, h:int):void
        {
            super();

            this.width = w;
            this.height = h;

            this.vertexContainer = new Sprite();
            this.elementContainer = new Sprite();

            this.graphics.beginFill(0xFFFFFF);
            this.graphics.drawRect(0,0,600,500);
            this.graphics.endFill();

            this.addChild(this.elementContainer);
            this.addChild(this.vertexContainer);

            this.dictVertexMarker = new Dictionary();
            this.dictElementMarker = new Dictionary();

            this.vertexSelectMarker = new VertexSelectMarker();
            this.elementSelectMarker = new ElementSelectMarker();
        }

        public function addVertex(data:Object):void
        {
            var vm:VertexMarker = new VertexMarker();
            vm.x = parseInt(data.x);
            vm.y = parseInt(data.y);

            this.dictVertexMarker[data.id] = vm;
            this.vertexContainer.addChild(vm);
        }

        public function removeVertex(data:Object):void
        {
            this.vertexContainer.removeChild(this.dictVertexMarker[parseInt(data.id)]);
            delete this.dictVertexMarker[parseInt(data.id)];

            this.vertexSelectMarker.timeOut(null);
        }

        public function addElement(data:Object):void
        {
            var em:ElementMarker = new ElementMarker();
            this.dictElementMarker[data.id] = em;
            this.elementContainer.addChild(em);
            em.drawBorder(data.vertexList);
        }

        public function removeElement(data:Object):void
        {
            this.elementContainer.removeChild(this.dictElementMarker[parseInt(data.id)]);
            delete this.dictElementMarker[parseInt(data.id)];

            this.elementSelectMarker.timeOut(null);
        }
        
        public function selectVertex(data:Object):void
        {
            this.vertexSelectMarker.x = this.dictVertexMarker[int(data.id)].x;
            this.vertexSelectMarker.y = this.dictVertexMarker[int(data.id)].y;
            this.vertexContainer.addChild(this.vertexSelectMarker);
            this.vertexSelectMarker.setTimeOut();
        }

        public function selectElement(data:Object):void
        {
            this.elementContainer.addChild(this.elementSelectMarker);
            this.elementSelectMarker.drawBorder(data.vertexList);
            this.elementSelectMarker.setTimeOut();
        }
    }
}

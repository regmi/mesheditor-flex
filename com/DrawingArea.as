package com
{
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import mx.core.*;
    import com.VertexMarker;

    public class DrawingArea extends UIComponent
    {
        private var dictVertexMarker:Dictionary;
        private var dictElementMarker:Dictionary;

        public function DrawingArea(w:int, h:int):void
        {
            this.width = w;
            this.height = h;

            this.graphics.beginFill(0xFFFFFF);
            this.graphics.drawRect(0,0,600,500);
            this.graphics.endFill();

            this.dictVertexMarker = new Dictionary();
            this.dictElementMarker = new Dictionary();
        }

        public function addVertex(data:Object):void
        {
            var vm:VertexMarker = new VertexMarker();
            vm.x = parseInt(data.x);
            vm.y = parseInt(data.y);

            this.dictVertexMarker[data.id] = vm;
            this.addChild(vm);
        }

        public function removeVertex(data:Object):void
        {
            this.removeChild(this.dictVertexMarker[parseInt(data.id)]);
            delete this.dictVertexMarker[parseInt(data.id)];
        }

        public function addElement(data:Object):void
        {
            
        }

        public function removeElement(data:Object):void
        {
            
        }
    }
}

package com
{
    import flash.display.*;
    import flash.events.*;
    
    public class VertexMarker extends Sprite
    {
        public var dataProvider:Object;
        private var selected:Boolean;

        public function VertexMarker(data:Object)
        {
            super();
            this.graphics.lineStyle(1);
            this.graphics.beginFill(0xFFB380);
            this.graphics.drawCircle(0, 0, 4);
            this.graphics.endFill();

            this.dataProvider = data;
            this.buttonMode = true;
            this.useHandCursor = true;
            this.doubleClickEnabled = true;
        }

        public function updateDataProvider(scaleFactor:Number):void
        {
            this.dataProvider.x = this.x/scaleFactor;
            this.dataProvider.y = -this.y/scaleFactor;
        }

        public function updateVertex(scaleFactor:Number):void
        {
            this.x = scaleFactor*this.dataProvider.x;
            this.y = -scaleFactor*this.dataProvider.y;
        }

        public function toggleSelect(selected:Boolean):void
        {
            if(selected)
            {
                this.graphics.lineStyle(1);
                this.graphics.beginFill(0xDD0000);
                this.graphics.drawCircle(0, 0, 4);
                this.graphics.endFill();
            }
            else
            {
                this.graphics.lineStyle(1);
                this.graphics.beginFill(0xFFB380);
                this.graphics.drawCircle(0, 0, 4);
                this.graphics.endFill();
            }
        }
    }
}

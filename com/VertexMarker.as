package com
{
    import flash.display.*;
    
    public class VertexMarker extends Sprite
    {
        public function VertexMarker()
        {
            super();
            this.graphics.lineStyle(1);
            this.graphics.drawCircle(0, 0, 3);
        }
    }
}

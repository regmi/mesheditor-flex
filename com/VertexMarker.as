package com
{
    import com.MeshEditorEvent;
    import flash.events.*;
    import flash.display.*;
    
    public class VertexMarker extends Sprite
    {
        public function VertexMarker()
        {
            this.graphics.lineStyle(2);
            this.graphics.drawCircle(0, 0, 3);
        }
    }
}

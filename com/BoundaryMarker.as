package com
{
    import com.MeshEditorEvent;
    import flash.ui.*;
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;

    public class BoundaryMarker extends Sprite
    {
        public var dataProvider:Object;

        public function BoundaryMarker(data:Object)
        {
            super();
            this.dataProvider = data;
            this.doubleClickEnabled = true;

            this.buttonMode = true;
            this.useHandCursor = true;
        }

        //It should be called only after ElementMarker is placed in the display list
        public function drawBorder(data:Object, scaleFactor:Number):void
        {
            this.x = scaleFactor*data.v1.x;
            this.y = -scaleFactor*data.v1.y;

            this.graphics.clear();
            this.graphics.lineStyle(2, 0x000000);
            this.graphics.beginFill(0xCECECE, 0.5);

            var gp:Point = this.parent.localToGlobal(new Point(scaleFactor*data.v2.x, -scaleFactor*data.v2.y));
            var lp:Point = this.globalToLocal(gp);
            this.graphics.lineTo(lp.x, lp.y);

            this.graphics.lineTo(0,0);
            this.graphics.endFill();
        }
    }
}

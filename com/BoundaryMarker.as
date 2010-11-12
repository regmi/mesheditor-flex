package com
{
    import com.*;
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
        public function drawBorder(boundary:Object, scaleFactor:Number):void
        {
            this.graphics.clear();
            this.graphics.lineStyle(2, 0x000000);

            if(boundary.angle == 0)
            {
                this.graphics.moveTo(scaleFactor*boundary.v1.x, -scaleFactor*boundary.v1.y);
                this.graphics.lineTo(scaleFactor*boundary.v2.x, -scaleFactor*boundary.v2.y);
            }
            else
            {
                DrawingShapes.generateArcCordinates(boundary, scaleFactor);

                this.graphics.moveTo(scaleFactor*boundary.v1.x, -scaleFactor*boundary.v1.y);
                for each(var p:Object in boundary.curve_path)
                {
                    this.graphics.lineTo(p.x * scaleFactor, -p.y * scaleFactor);
                }
                this.graphics.lineTo(scaleFactor*boundary.v2.x, -scaleFactor*boundary.v2.y);
            }
        }
    }
}

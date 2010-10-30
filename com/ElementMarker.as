package com
{
    import com.MeshEditorEvent;
    import flash.ui.*;
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;

    public class ElementMarker extends Sprite
    {
        public var dataProvider:Object;

        public function ElementMarker(data:Object)
        {
            super();
            this.dataProvider = data;
            this.doubleClickEnabled = true;
        }

        //It should be called only after ElementMarker is placed in the display list
        public function _drawBorder(data:Object, scaleFactor:Number):void
        {
            this.graphics.clear();
            this.graphics.lineStyle(1, 0x0033FF);

            //this.graphics.beginFill(0xCECECE, 0.5);

            for each(var edg:Object in data.edges)
            {
                if(edg.boundary == true && edg.angle != 0)
                {
                    var arcInfo:Object = Geometry.getArcInfo(edg);
                    DrawingShapes.drawArc1(this.graphics, arcInfo, scaleFactor);
                }
                else
                {
                    this.graphics.moveTo(scaleFactor*edg.v1.x, -scaleFactor*edg.v1.y);
                    this.graphics.lineTo(scaleFactor*edg.v2.x, -scaleFactor*edg.v2.y);
                }
            }

            //this.graphics.endFill();
        }

        public function drawBorder(data:Object, scaleFactor:Number):void
        {
            var path:Array = Geometry.getPath(data.edges);

            this.graphics.clear();
            this.graphics.lineStyle(1, 0x0033FF);
            this.graphics.beginFill(0xCECECE, 0.5);
            this.graphics.moveTo(scaleFactor*path[0].v1.x, -scaleFactor*path[0].v1.y);

            var arcInfo:Object;

            if(path[0].boundary == undefined)
            {
                this.graphics.lineTo(scaleFactor*path[0].v2.x, -scaleFactor*path[0].v2.y);
            }
            else
            {
                if(path[0].boundary == true && path[0].angle == 0)
                {
                    this.graphics.lineTo(scaleFactor*path[0].v2.x, -scaleFactor*path[0].v2.y);
                }
                else
                {
                    arcInfo = Geometry.getArcInfo2(path[0]);
                    DrawingShapes.drawArc0(this.graphics, arcInfo, scaleFactor);
                }
            }

            for(var i:int=1;i<path.length;i++)
            {
                if(path[i].boundary == undefined)
                {
                    this.graphics.lineTo(scaleFactor*path[i].v2.x, -scaleFactor*path[i].v2.y);
                }
                else
                {
                    if(path[i].boundary == true && path[i].angle == 0)
                    {
                        this.graphics.lineTo(scaleFactor*path[i].v2.x, -scaleFactor*path[i].v2.y);
                    }
                    else
                    {
                        arcInfo = Geometry.getArcInfo2(path[i]);
                        DrawingShapes.drawArc0(this.graphics, arcInfo, scaleFactor);
                    }
                }
            }

            this.graphics.endFill();
        }
    }
}

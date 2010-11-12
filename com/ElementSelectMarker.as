package com
{
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.filters.*;
    import flash.geom.*;

    public class ElementSelectMarker extends Shape
    {
        private var timer:Timer;

        public function ElementSelectMarker()
        {
            super();
            this.timer = null;
        }

        public function setTimeOut():void
        {
            if(this.timer == null)
            {
                this.timer = new Timer(5000);
                this.timer.addEventListener(TimerEvent.TIMER, this.timeOut);
            }

            this.timer.stop();
            this.timer.start();
        }

        //It should be called only after ElementMarker is placed in the display list
        public function drawBorder(data:Object, scaleFactor:Number):void
        {
            var path:Array = Geometry.getPath(data.edges);

            this.graphics.clear();
            this.graphics.lineStyle(2, 0xAA0000);
            this.graphics.beginFill(0x3399CC, 0.5);
            this.graphics.moveTo(scaleFactor*path[0].edge.v1.x, -scaleFactor*path[0].edge.v1.y);

            if(path[0].edge.boundary == undefined)
            {
                this.graphics.lineTo(scaleFactor*path[0].edge.v2.x, -scaleFactor*path[0].edge.v2.y);
            }
            else
            {
                if(path[0].edge.boundary == true && path[0].edge.angle == 0)
                {
                    this.graphics.lineTo(scaleFactor*path[0].edge.v2.x, -scaleFactor*path[0].edge.v2.y);
                }
                else
                {
                    for each(var p:Object in path[0].edge.curve_path)
                    {
                        this.graphics.lineTo(p.x * scaleFactor, -p.y * scaleFactor);
                    }
                    this.graphics.lineTo(scaleFactor*path[0].edge.v2.x, -scaleFactor*path[0].edge.v2.y);
                }
            }

            for(var i:int=1;i<path.length;i++)
            {
                if(path[i].edge.boundary == undefined)
                {
                    if(path[i].reverse == false)
                        this.graphics.lineTo(scaleFactor*path[i].edge.v2.x, -scaleFactor*path[i].edge.v2.y);
                    else
                        this.graphics.lineTo(scaleFactor*path[i].edge.v1.x, -scaleFactor*path[i].edge.v1.y);
                }
                else
                {
                    if(path[i].edge.boundary == true && path[i].edge.angle == 0)
                    {
                        if(path[i].reverse == false)
                            this.graphics.lineTo(scaleFactor*path[i].edge.v2.x, -scaleFactor*path[i].edge.v2.y);
                        else
                            this.graphics.lineTo(scaleFactor*path[i].edge.v1.x, -scaleFactor*path[i].edge.v1.y);
                    }
                    else
                    {
                        var k:int;
                        if(path[i].reverse == false)
                        {
                            for(k=0;k<path[i].edge.curve_path.length;k++)
                            {
                                this.graphics.lineTo(path[i].edge.curve_path[k].x * scaleFactor, -path[i].edge.curve_path[k].y * scaleFactor);
                            }
                            this.graphics.lineTo(scaleFactor*path[i].edge.v2.x, -scaleFactor*path[i].edge.v2.y);
                        }
                        else if(path[i].reverse == true)
                        {
                            for(k=path[i].edge.curve_path.length-1;k>=0;k--)
                            {
                                this.graphics.lineTo(path[i].edge.curve_path[k].x * scaleFactor, -path[i].edge.curve_path[k].y * scaleFactor);
                            }
                            this.graphics.lineTo(scaleFactor*path[i].edge.v1.x, -scaleFactor*path[i].edge.v1.y);
                        }
                    }
                }
            }

            this.graphics.endFill();
        }

        public function timeOut(evt:TimerEvent):void
        {
            if(this.parent != null)
            {
                this.timer.stop();
                this.parent.removeChild(this);
            }
        }
    }
}

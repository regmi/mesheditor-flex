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
        public function drawBorder(vertexList:Array):void
        {
            this.x = vertexList[0].x;
            this.y = vertexList[0].y;

            this.graphics.clear();
            this.graphics.lineStyle(1, 0x0033FF);

            this.graphics.beginFill(0x3399CC, 0.5);
            for(var i:int=1;i<vertexList.length;i++)
            {
                var gp:Point = this.parent.localToGlobal(new Point(vertexList[i].x, vertexList[i].y));
                var lp:Point = this.globalToLocal(gp);
                this.graphics.lineTo(lp.x, lp.y);
            }

            this.graphics.lineTo(0,0);
            this.graphics.endFill();
        }

        public function timeOut(evt:TimerEvent):void
        {
            this.timer.stop();
            this.parent.removeChild(this);
        }
    }
}

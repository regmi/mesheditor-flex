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
            this.x = scaleFactor*data.v1.x;
            this.y = -scaleFactor*data.v1.y;

            this.graphics.clear();
            this.graphics.lineStyle(2, 0xAA0000);
            this.graphics.beginFill(0x3399CC, 0.5);

            var gp:Point = this.parent.localToGlobal(new Point(scaleFactor*data.v2.x, -scaleFactor*data.v2.y));
            var lp:Point = this.globalToLocal(gp);
            this.graphics.lineTo(lp.x, lp.y);

            try
            {
                gp = this.parent.localToGlobal(new Point(scaleFactor*data.v3.x, -scaleFactor*data.v3.y));
                lp = this.globalToLocal(gp);
                this.graphics.lineTo(lp.x, lp.y);
            }
            catch(e:Error) { }

            try
            {
                gp = this.parent.localToGlobal(new Point(scaleFactor*data.v4.x, -scaleFactor*data.v4.y));
                lp = this.globalToLocal(gp);
                this.graphics.lineTo(lp.x, lp.y);
            }
            catch(e:Error) { }

            this.graphics.lineTo(0,0);
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

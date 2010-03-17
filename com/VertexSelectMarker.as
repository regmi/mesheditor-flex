package com
{
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.filters.*;

    public class VertexSelectMarker extends Shape
    {
        private var timer:Timer;

        public function VertexSelectMarker()
        {
            super();
            this.timer = null;

            this.graphics.lineStyle(1);
            this.graphics.drawCircle(0, 0, 5);
            
            var gFltr:GlowFilter = new GlowFilter(0xFF0000, 1.0, 6.0, 6.0, 2, 1, false, false);
            this.filters = [gFltr];
        }

        public function setTimeOut():void
        {
            if(this.timer == null)
            {
                this.timer = new Timer(5000);
                this.timer.addEventListener(TimerEvent.TIMER, this.timeOut, false, 0, true);
            }

            this.timer.stop();
            this.timer.start();
        }

        public function timeOut(evt:TimerEvent):void
        {
            this.timer.stop();
            this.parent.removeChild(this);
        }
    }
}

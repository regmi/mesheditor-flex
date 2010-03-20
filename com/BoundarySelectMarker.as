package com
{
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.filters.*;
    import flash.geom.*;

    public class BoundarySelectMarker extends ElementSelectMarker
    {
        private var timer:Timer;

        public function BoundarySelectMarker()
        {
            super();
            this.timer = null;
            this.graphics.lineStyle(2, 0xBB33FF);
            this.filters = [new GlowFilter(0xFF0000, 1.0, 6.0, 6.0, 2, 1, false, false)];
        }
    }
}

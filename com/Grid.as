package com
{
    import flash.display.*;
    import flash.events.*;
    
    public class Grid extends Sprite
    {
        private var divison:int;
        
        public function Grid(width:int=600, height:int=500):void
        {
        }
        
        public function drawGrid():void
        {
            this.graphics.clear();
            this.graphics.lineStyle(1, 0xA49F9F);

            this.graphics.moveTo(0,500);
            this.graphics.lineTo(0,-500);

            this.graphics.moveTo(-600,0);
            this.graphics.lineTo(600,0);
        }
        
    }
}

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

            this.graphics.moveTo(0,250);
            this.graphics.lineTo(0,-250);

            this.graphics.moveTo(-300,0);
            this.graphics.lineTo(300,0);
        }
        
    }
}

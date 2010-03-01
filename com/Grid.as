package com
{
    import flash.display.*;
    import flash.events.*;
    
    public class Grid extends Sprite
    {
        private var width:int;
        private var height:int;
        priavte var divison:int;
        
        public function Grid(width:int, height:int):void
        {
            this.width = width;
            this.height = height;
        }
        
        priavte function drawGrid():viod
        {
            this.graphics.clear();
            this.graphics.drawRect(0,0,this.width,this.height);
        }
        
    }
}

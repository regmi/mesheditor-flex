package com
{
    import flash.display.*;
    import flash.events.*;
    
    public class Grid extends Sprite
    {
        public function Grid(width:int=600, height:int=500):void
        {
        }
        
        public function drawGrid(scaleFactor:int):void
        {
            this.graphics.clear();
            this.graphics.lineStyle(1, 0xA49F9F);

            for(var j:int=-50;j<=-1;j++)
            {
                this.graphics.moveTo(-50*scaleFactor,j*scaleFactor);
                this.graphics.lineTo(50*scaleFactor,j*scaleFactor);

                this.graphics.moveTo(j*scaleFactor,50*scaleFactor);
                this.graphics.lineTo(j*scaleFactor,-50*scaleFactor);
            }

            for(var j:int=1;j<=50;j++)
            {
                this.graphics.moveTo(-50*scaleFactor,j*scaleFactor);
                this.graphics.lineTo(50*scaleFactor,j*scaleFactor);

                this.graphics.moveTo(j*scaleFactor,50*scaleFactor);
                this.graphics.lineTo(j*scaleFactor,-50*scaleFactor);
            }

            this.graphics.lineStyle(1, 0x000000);
            this.graphics.moveTo(-50*scaleFactor,0);
            this.graphics.lineTo(50*scaleFactor,0);

            this.graphics.moveTo(0,50*scaleFactor);
            this.graphics.lineTo(0,-50*scaleFactor);
        }
        
    }
}

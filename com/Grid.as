package com
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;

    public class Grid extends Sprite
    {
        private var xNegUnitLabel:Array = [];
        private var xPosUnitLabel:Array = [];
        private var yNegUnitLabel:Array = [];
        private var yPosUnitLabel:Array = [];

        public function Grid(width:int=600, height:int=500):void
        {
            var tf:TextField;
            for(var i:int=1;i<=50;i++)
            {
                tf = new TextField();
                tf.text = String(i);
                tf.selectable = false;
                xPosUnitLabel.push(tf);
                this.addChild(tf);

                tf = new TextField();
                tf.text = String(i);
                tf.selectable = false;
                yPosUnitLabel.push(tf);
                this.addChild(tf);
            }

            for(i=-1;i>=-50;i--)
            {
                tf = new TextField();
                tf.text = String(i);
                tf.selectable = false;
                xNegUnitLabel.push(tf);
                this.addChild(tf);

                tf = new TextField();
                tf.text = String(i);
                tf.selectable = false;
                yNegUnitLabel.push(tf);
                this.addChild(tf);
            }
        }

        public function drawGrid(scaleFactor:int):void
        {
            this.graphics.clear();
            this.graphics.lineStyle(1, 0xA49F9F);

            for(var j:int=-50;j<=-1;j++)
            {
                this.graphics.moveTo(-50*scaleFactor,j*scaleFactor);
                this.graphics.lineTo(50*scaleFactor,j*scaleFactor);

                yPosUnitLabel[(-j)-1].x = 0;
                yPosUnitLabel[(-j)-1].y = j*scaleFactor;

                xNegUnitLabel[(-j)-1].x = j*scaleFactor;
                xNegUnitLabel[(-j)-1].y = 0;

                this.graphics.moveTo(j*scaleFactor,50*scaleFactor);
                this.graphics.lineTo(j*scaleFactor,-50*scaleFactor);
            }

            for(j=1;j<=50;j++)
            {
                this.graphics.moveTo(-50*scaleFactor,j*scaleFactor);
                this.graphics.lineTo(50*scaleFactor,j*scaleFactor);

                yNegUnitLabel[j-1].x = 0;
                yNegUnitLabel[j-1].y = j*scaleFactor;

                xPosUnitLabel[j-1].x = j*scaleFactor;
                xPosUnitLabel[j-1].y = 0;

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

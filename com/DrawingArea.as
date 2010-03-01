package com
{
    import flash.display.*;
    import flash.events.*;
    import mx.core.*;
    
    public class DrawingArea extends UIComponent
    {        
        public function DrawingArea():void
        {
            this.graphics.beginFill(0xFFFFFF);
            this.graphics.drawRect(0,0,600,500);
            this.graphics.endFill();
        }
    }
}

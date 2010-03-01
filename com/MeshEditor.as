package com
{
    import mx.core.*;
    import mx.containers.*;
    import mx.controls.Button;
    import flash.events.MouseEvent;
    import flash.display.MovieClip;
    import mx.events.FlexEvent;

    public class MeshEditor extends Application
    {
        // Components in MXML
        
        public function MeshEditor()
        {
            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete );
        }

        private function creationComplete(evt:FlexEvent):void
        {

        }
    }
}

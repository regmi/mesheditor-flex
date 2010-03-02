package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.containers.*;
    import mx.managers.PopUpManager;

    import com.WindowAddVertex;
    import com.WindowAddElement;
    
    public dynamic class MeshEditor extends Application
    {
        // Components in MXML
        public var btnShowWindow:Button;
        public var btnRemoveItems:Button;

        private var windowAddVertex:WindowAddVertex;
        private var windowAddElement:WindowAddElement;
        private var windowAddBoundary:WindowAddBoundary;
        
        public function MeshEditor()
        {
            this.windowAddVertex = null;
            this.windowAddElement = null;
            this.windowAddBoundary = null;
            
            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete );
            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete );
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnShowWindow.addEventListener(MouseEvent.CLICK, this.btnShowWindowClick);
            this.btnRemoveItem.addEventListener(MouseEvent.CLICK, this.btnRemoveItemClick);
        }

        private function btnShowWindowClick(evt:MouseEvent):void
        {
            trace("-hello-");
            
            if(this.accordion.selectedIndex == 0)
            {
                if(this.windowAddVertex == null)
                {
                    this.windowAddVertex = new WindowAddVertex();
                    this.windowAddVertex.addEventListener(CloseEvent.CLOSE, this.dialogClose);
                    
                    PopUpManager.addPopUp(this.windowAddVertex, this, false);
                    PopUpManager.centerPopUp(this.windowAddVertex);
                }
            }
            else if(this.accordion.selectedIndex == 1)
            {
                if(this.windowAddElement == null)
                {
                    this.windowAddElement = new WindowAddElement();
                    this.windowAddElement.addEventListener(CloseEvent.CLOSE, this.dialogClose);

                    PopUpManager.addPopUp(this.windowAddElement, this, false);
                    PopUpManager.centerPopUp(this.windowAddElement);   
                }
            }
            else
            {
                if(this.windowAddBoundary == null)
                {
                    this.windowAddBoundary = new WindowAddBoundary();
                    this.windowAddBoundary.addEventListener(CloseEvent.CLOSE, this.dialogClose);

                    PopUpManager.addPopUp(this.windowAddBoundary, this, false);
                    PopUpManager.centerPopUp(this.windowAddBoundary);
                }
            }
        }

        private function btnRemoveItemClick(evt:MouseEvent):void
        {
            
        }
        
        private function dialogClose(evt:CloseEvent):void
        {
            //PopUpManager.removePopUp(evt.target);

            if(evt.target is WindowAddVertex)
            {
                this.windowAddVertex = null;
            }
            else if(evt.target is WindowAddElement)
            {
                this.windowAddElement = null;
            }
            else if (evt.target is WindowAddBoundary)
            {
                this.windowAddBoundary = null;
            }
        }
    }
}

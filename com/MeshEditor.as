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
    import com.WindowAddCurv;

    public dynamic class MeshEditor extends Application
    {
        // Components in MXML
        public var btnShowWindow:Button;
        public var btnRemoveItems:Button;
        public var gridVertices:DataGrid;

        private var windowAddVertex:WindowAddVertex;
        private var windowAddElement:WindowAddElement;
        private var windowAddBoundary:WindowAddBoundary;
        private var windowAddCurv:WindowAddCurv;
        
        [Bindable]
        private var xmlVertices:XMLList; 

        public function MeshEditor()
        {
            this.windowAddVertex = null;
            this.windowAddElement = null;
            this.windowAddBoundary = null;
            this.windowAddCurv = null;
            
            this.xmlVertices = new XMLList("<vertices><vertex><X></X><Y></Y></vertex></vertices>"); 

            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete );
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnShowWindow.addEventListener(MouseEvent.CLICK, this.btnShowWindowClick);
            this.btnRemoveItem.addEventListener(MouseEvent.CLICK, this.btnRemoveItemClick);

            this.gridVertices.dataProvider = this.xmlVertices;
        }

        private function btnShowWindowClick(evt:MouseEvent):void
        {
            if(this.accordion.selectedIndex == 0)
            {
                if(this.windowAddVertex == null)
                {
                    this.windowAddVertex = new WindowAddVertex();
                    this.windowAddVertex.addEventListener(CloseEvent.CLOSE, this.dialogCloseClick);

                    PopUpManager.addPopUp(this.windowAddVertex, this, false);
                    PopUpManager.centerPopUp(this.windowAddVertex);
                }
            }
            else if(this.accordion.selectedIndex == 1)
            {
                if(this.windowAddElement == null)
                {
                    this.windowAddElement = new WindowAddElement();
                    this.windowAddElement.addEventListener(CloseEvent.CLOSE, this.dialogCloseClick);

                    PopUpManager.addPopUp(this.windowAddElement, this, false);
                    PopUpManager.centerPopUp(this.windowAddElement);   
                }
            }
            else if(this.accordion.selectedIndex == 2)
            {
                if(this.windowAddCurv == null)
                {
                    this.windowAddCurv = new WindowAddCurv();
                    this.windowAddCurv.addEventListener(CloseEvent.CLOSE, this.dialogCloseClick);
                
                    PopUpManager.addPopUp(this.windowAddCurv, this, false);
                    PopUpManager.centerPopUp(this.windowAddCurv);
                }
            }
            else if(this.accordion.selectedIndex == 3)
            {
                if(this.windowAddBoundary == null)
                {
                    this.windowAddBoundary = new WindowAddBoundary();
                    this.windowAddBoundary.addEventListener(CloseEvent.CLOSE, this.dialogCloseClick);

                    PopUpManager.addPopUp(this.windowAddBoundary, this, false);
                    PopUpManager.centerPopUp(this.windowAddBoundary);
                }
            }
        }

        private function btnRemoveItemClick(evt:MouseEvent):void
        {
            trace(this.xmlVertices.toXMLString());
        }
        
        private function dialogCloseClick(evt:CloseEvent):void
        {
            if(evt.target is WindowAddVertex)
            {
                PopUpManager.removePopUp(this.windowAddVertex);
                this.windowAddVertex = null;
            }
            else if(evt.target is WindowAddElement)
            {
                PopUpManager.removePopUp(this.windowAddElement);
                this.windowAddElement = null;
            }
            else if (evt.target is WindowAddCurv)
            {
                PopUpManager.removePopUp(this.windowAddCurv);
                this.windowAddCurv = null;
            }
            else if (evt.target is WindowAddBoundary)
            {
                PopUpManager.removePopUp(this.windowAddBoundary);
                this.windowAddBoundary = null;
            }
        }
    }
}

package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import mx.collections.*;
    import flash.events.*;
    import mx.containers.*;
    import mx.controls.dataGridClasses.*;

    import com.WindowSelectVertices_LAYOUT

    public class WindowSelectVertices extends WindowSelectVertices_LAYOUT
    {
        [Bindable]
        protected var availableVertices:ArrayCollection;

        [Bindable]
        protected var selectedVertices:ArrayCollection; 

        public function WindowSelectVertices():void
        {
            super();
            this.availableVertices = new ArrayCollection();
            this.selectedVertices = new ArrayCollection();

            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete, false, 0, true);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.btnAdd.addEventListener(MouseEvent.CLICK, this.btnAddClick, false, 0, true);
            this.btnSelectVertex.addEventListener(MouseEvent.CLICK, this.btnSelectVertexClick, false, 0, true);
            this.btnDeselectVertex.addEventListener(MouseEvent.CLICK, this.btnDeselectVertexClick, false, 0, true);

            this.gridAvailableVertices.addEventListener(ListEvent.ITEM_ROLL_OVER, this.gridAvailableVerticesItemRollOver, false, 0, true);
            this.gridSelectedVertices.addEventListener(ListEvent.ITEM_ROLL_OVER, this.gridAvailableVerticesItemRollOver, false, 0, true);

            this.gridSelectedVertices.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, this.gridSelectedVerticesItemDoubleClick, false, 0, true);
            this.gridAvailableVertices.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, this.gridAvailableVerticesItemDoubleClick, false, 0, true);

            this.gridAvailableVertices.dataProvider = this.availableVertices;
            this.gridSelectedVertices.dataProvider = this.selectedVertices;
        }

        public function initAvailableVertices(aV:ArrayCollection):void
        {
            for(var i:int=0;i<aV.length;i++)
            {
                this.availableVertices.addItem(aV[i]);
            }
        }

        public function addAvailableVertex(data:Object):void
        {
            this.availableVertices.addItem(data);
        }

        public function removeAvailableVertex(data:Object):void
        {
            for(var i:int=0;i<this.availableVertices.length;i++)
            {
                if(this.availableVertices[i].id == data.id)
                {
                    this.availableVertices.removeItemAt(i);
                    break;
                }
            }

            for(var j:int=0;j<this.selectedVertices.length;j++)
            {
                if(this.selectedVertices[j].id == data.id)
                {
                    this.selectedVertices.removeItemAt(j);
                    break;
                }
            }
        }

        protected function gridAvailableVerticesItemRollOver(evt:ListEvent):void
        {
            var dgir:DataGridItemRenderer = DataGridItemRenderer(evt.itemRenderer);
            var dgirData:Object = Object(dgir.data);

            evt.rowIndex = dgirData.id;
            this.dispatchEvent(evt);
        }

        protected function addToSelected():void
        {
            for(var i:int=0;i<this.availableVertices.length;i++)
            {
                if(this.availableVertices[i].id == this.gridAvailableVertices.selectedItem.id)
                {
                    this.selectedVertices.addItem(this.availableVertices[i]);
                    this.availableVertices.removeItemAt(i);
                    break;
                }
            }
        }

        protected function removeFromSelected():void
        {
            for(var i:int=0;i<this.selectedVertices.length;i++)
            {
                if(this.selectedVertices[i].id == this.gridSelectedVertices.selectedItem.id)
                {
                    this.availableVertices.addItem(this.selectedVertices[i]);
                    this.selectedVertices.removeItemAt(i);
                    break;
                }
            }
        }

        protected function btnSelectVertexClick(evt:MouseEvent):void {}

        protected function btnDeselectVertexClick(evt:MouseEvent):void {}

        protected function btnAddClick(evt:MouseEvent):void {}

        private function gridSelectedVerticesItemDoubleClick(evt:ListEvent):void
        {
            this.btnDeselectVertexClick(null);
        }

        private function gridAvailableVerticesItemDoubleClick(evt:ListEvent):void
        {
            this.btnSelectVertexClick(null);
        }
    }
}

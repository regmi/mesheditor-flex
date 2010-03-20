package com
{
    import mx.core.*;
    import mx.events.*;
    import mx.controls.*;
    import flash.events.*;
    import mx.containers.*;
    import mx.validators.*;

    import com.WindowSelectVertices;

    public class WindowAddBoundary extends WindowSelectVertices
    {
        private var txtMarker:TextInput;
        private var numberValidator:NumberValidator;

        public function WindowAddBoundary():void
        {
            super();

            this.numberValidator = new NumberValidator();
            this.addEventListener(FlexEvent.CREATION_COMPLETE, this.creationComplete, false, 0, true);
        }

        private function creationComplete(evt:FlexEvent):void
        {
            this.title = "Add Boundary";
            this.gridSelectedVertices.rowCount = 3;

            var hb:HBox = new HBox();
            hb.percentWidth = 100;
            var lb:Label = new Label();
            lb.text = "Marker";
            hb.addChild(lb);
            this.txtMarker = new TextInput()
            this.txtMarker.text = "1";
            this.txtMarker.percentWidth = 25;
            hb.addChild(this.txtMarker);
            this.vboxRight.addChild(hb);

            this.numberValidator.property  ="text";
            this.numberValidator.minValue = 0;
            this.numberValidator.maxValue = 50;
            this.numberValidator.allowNegative = false;
            this.numberValidator.source = this.txtMarker;
        }

        protected override function btnSelectVertexClick(evt:MouseEvent):void
        {
            if(this.gridAvailableVertices.selectedItem != null && this.xmlSelectedVertices.*.length() < 2)
            {
                this.addToSelected();

                if(this.xmlSelectedVertices.*.length() == 2)
                {
                    var vl:Array = [];
                    for each(var v:XML in this.xmlSelectedVertices.vertex)
                    {
                        vl.push({id:v.@id, x:v.x, y:v.y});
                    }
                    
                    var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_SELECTED);
                    e.data = new Object();
                    e.data.vertexList = vl;
                    this.dispatchEvent(e);
                }
            }
        }

        protected override function btnDeselectVertexClick(evt:MouseEvent):void
        {
            if(this.gridSelectedVertices.selectedItem != null)
            {
                this.removeFromSelected();
            }
        }

        protected override function btnAddClick(evt:MouseEvent):void
        {
            var vArray:Array = [this.numberValidator];
            var errors:Array = Validator.validateAll(vArray);

            if(this.xmlSelectedVertices.*.length() == 2 && errors.length == 0)
            {
                var meEvt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_SUBMIT);
                var dta:Object = new Object();
                dta.vertexList = [];
                dta.marker = this.txtMarker.text;

                for each(var v:XML in this.xmlSelectedVertices.vertex)
                {
                    dta.vertexList.push({id:v.@id, x:v.x, y:v.y});
                }
                meEvt.data = dta;
                this.dispatchEvent(meEvt);

                var closeEvt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
                this.dispatchEvent(closeEvt);
            }
        }
    }
}

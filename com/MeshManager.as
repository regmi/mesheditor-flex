package com
{
    import com.MeshEditorEvent;

    import mx.collections.*;
    import mx.events.*;
    import flash.events.*;
    import flash.utils.*;

    public class MeshManager extends EventDispatcher
    {
        [Bindable]
        public var vertices:ArrayCollection; 

        [Bindable]
        public var elements:ArrayCollection; 

        [Bindable]
        public var boundaries:ArrayCollection; 

        [Bindable]
        public var curves:ArrayCollection; 

        private var nextVertexId:int;
        private var nextElementId:int;
        private var nextBoundaryId:int;
        private var nextCurveId:int;

        public var updatedVertex:Object;

        public function MeshManager():void
        {
            super();

            this.vertices = new ArrayCollection();
            this.vertices.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.verticesChange);

            this.elements = new ArrayCollection();
            this.boundaries = new ArrayCollection();
            this.curves = new ArrayCollection();

            this.nextVertexId = 0;
            this.nextElementId = 0;
            this.nextBoundaryId = 0;
            this.nextCurveId = 0;
        }

        public function addVertex(data:Object):void
        {
            if (! this.checkDuplicateVertex(data))
            {
                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_ADDED);
                evt.data = data;

                if(data.id == null)
                {
                    data.id = this.nextVertexId;
                }
                else
                {
                    if(data.id > this.nextVertexId)
                        this.nextVertexId = data.id;
                }

                this.vertices.addItem(data);
                this.dispatchEvent(evt);
                this.nextVertexId++;
            }
        }

        public function removeVertex(data:Object):void
        {
            this.removeElementWithVertex(data);
            this.removeBoundaryWithVertex(data);
            this.removeCurveWithVertex(data);

            for(var i:int=0; i<this.vertices.length;i++)
            {
                if(this.vertices[i].id == data.id)
                {
                    this.vertices.removeItemAt(i);
                    break;
                }
            }

            var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_REMOVED);
            evt.data = data;

            this.dispatchEvent(evt);

            if(this.vertices.length == 0)
                this.nextVertexId = 0;
        }

        public function addElement(data:Object):void
        {
            if (!this.checkDuplicateElement(data))
            {
                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_ADDED);
                evt.data = data;

                if(data.id == null)
                {
                    data.id = this.nextElementId;
                }
                else
                {
                    if(data.id > this.nextElementId)
                        this.nextElementId = data.id;
                }

                this.elements.addItem(data);
                this.dispatchEvent(evt);
                this.nextElementId++;
            }
        }

        public function removeElement(data:Object):void
        {
            for(var i:int=0; i<this.elements.length;i++)
            {
                if(this.elements[i].id == data.id)
                {
                    this.elements.removeItemAt(i);
                    break;
                }
            }

            var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_REMOVED);
            evt.data = data;

            this.dispatchEvent(evt);

            if(this.elements.length == 0)
                this.nextElementId = 0;
        }

        public function removeElementWithVertex(data:Object):void
        {
            var etr:Array = [];

            for(var i:int=0;i<this.elements.length;i++)
            {
                if(this.elements[i].v1.id == data.id)
                    etr.push(this.elements[i]);
                else
                {
                    if(this.elements[i].v2.id == data.id)
                        etr.push(this.elements[i]);
                    else
                    {
                        if(this.elements[i].v3.id == data.id)
                            etr.push(this.elements[i]);
                        else
                        {
                            try
                            {
                                if(this.elements[i].v4.id == data.id)
                                    etr.push(this.elements[i]);
                            }catch(e:Error){}
                        }
                    }
                }
            }

            for(i=0;i<etr.length;i++)
            {
                this.removeElement(etr[i]);
            }
        }

        public function updateElementWithVertex(data:Object):void
        {
            var etu:Array = [];

            for(var i:int=0;i<this.elements.length;i++)
            {
                if(this.elements[i].v1.id == data.id)
                    etu.push(this.elements[i]);
                else
                {
                    if(this.elements[i].v2.id == data.id)
                        etu.push(this.elements[i]);
                    else
                    {
                        if(this.elements[i].v3.id == data.id)
                            etu.push(this.elements[i]);
                        else
                        {
                            try
                            {
                                if(this.elements[i].v4.id == data.id)
                                    etu.push(this.elements[i]);
                            }catch(e:Error){}
                        }
                    }
                }
            }

            for(i=0;i<etu.length;i++)
            {
                var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_UPDATED);
                e.data = etu[i];

                this.dispatchEvent(e);
            }
            trace("-eu-")
        }

        public function addBoundary(data:Object):void
        {
            if (! this.checkDuplicateBoundary(data))
            {
                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_ADDED);
                evt.data = data;

                if(data.id == null)
                {
                    data.id = this.nextBoundaryId;
                }
                else
                {
                    if(data.id > this.nextBoundaryId)
                        this.nextBoundaryId = data.id;
                }

                this.boundaries.addItem(data);
                this.dispatchEvent(evt);
                this.nextBoundaryId++;
            }
        }

        public function removeBoundary(data:Object):void
        {
            for(var i:int=0; i<this.boundaries.length;i++)
            {
                if(this.boundaries[i].id == data.id)
                {
                    this.boundaries.removeItemAt(i);
                    break;
                }
            }

            var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_REMOVED);
            evt.data = data;

            this.dispatchEvent(evt);

            if(this.boundaries.length == 0)
                this.nextBoundaryId = 0;
        }

        public function removeBoundaryWithVertex(data:Object):void
        {
            var btr:Array = [];

            for(var i:int=0;i<this.boundaries.length;i++)
            {
                if(this.boundaries[i].v1.id == data.id)
                    btr.push(this.boundaries[i]);
                else
                {
                    if(this.boundaries[i].v2.id == data.id)
                        btr.push(this.boundaries[i]);
                }
            }

            for(i=0;i<btr.length;i++)
            {
                this.removeBoundary(btr[i]);
            }
        }

        public function addCurve(data:Object):void
        {
            
        }

        public function removeCurve(id:int):void
        {
            
        }

        public function removeCurveWithVertex(data:Object):void
        {
            
        }

        private function checkDuplicateVertex(data:Object):Boolean
        {
            for(var i:int=0;i<this.vertices.length;i++)
            {
                if(this.vertices[i].x == data.x && this.vertices[i].y == data.y)
                    return true;
            }

            return false;
        }

        private function checkDuplicateElement(data:Object):Boolean
        {
            var vId1:Array = [];
            var vId2:Array = [];
            var count:int = 0;
            var tmp:int = 0;

            try
            {
                vId1.push(data.v1.id);
                vId1.push(data.v2.id);
                vId1.push(data.v3.id);
                vId1.push(data.v4.id);
            }catch(e:Error){}

            for each(var element:Object in this.elements)
            {
                count = 0;
                vId2.splice(0,vId2.length);

                try
                {
                    vId2.push(int(element.v1.id));
                    vId2.push(int(element.v2.id));
                    vId2.push(int(element.v3.id));
                    vId2.push(int(element.v4.id));
                }
                catch(e:Error) {}

                if(vId1.length == vId2.length)
                {
                    for each(var val:Number in vId2)
                    {
                        if(vId1.indexOf(val) == -1)
                            break;
                        else
                            count++;
                    }
                }

                if(count == vId1.length)
                    return true;
            }

            return false;
        }

        private function checkDuplicateBoundary(data:Object):Boolean
        {
            for(var i:int=0;i<this.boundaries.length;i++)
            {
                if((this.boundaries[i].v1.id == data.v1.id && this.boundaries[i].v2.id == data.v2.id) || (this.boundaries[i].v1.id == data.v2.id && this.boundaries[i].v2.id == data.v1.id))
                    return true;
            }

            return false;
        }

        private function checkDuplicateCurve(data:Object):Boolean
        {
            return false;
        }

        public function getVertex(id:int):Object
        {
            for(var i:int=0;i<this.vertices.length;i++)
            {
                if(this.vertices[i].id == id)
                    return this.vertices[i];
            }
            return null
        }

        private function getVertexIndex(data:Object):int
        {
            for(var i:int=0;i<this.vertices.length;i++)
            {
                if(this.vertices[i].id == data.id)
                    return i;
            }
            return -1;
        }

        public function getElement(id:int):Object
        {
            for(var i:int=0;i<this.elements.length;i++)
            {
                if(this.elements[i].id == id)
                    return this.elements[i];
            }
            return null
        }

        public function getBoundary(id:int):Object
        {
            for(var i:int=0;i<this.boundaries.length;i++)
            {
                if(this.boundaries[i].id == id)
                    return this.boundaries[i];
            }
            return null
        }

        public function getCurve(id:int):Object
        {
            return {id:1};
        }

        public function clear():void
        {
            this.vertices.removeAll();
            this.elements.removeAll();
            this.boundaries.removeAll();
            this.curves.removeAll();

            this.nextVertexId = 0;
            this.nextElementId = 0;
            this.nextBoundaryId = 0;
            this.nextCurveId = 0;
        }

        private function verticesChange(evt:CollectionEvent):void
        {
            if(evt.kind == CollectionEventKind.UPDATE)
            {
                var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_UPDATED);
                e.data = this.updatedVertex;

                this.dispatchEvent(e);

                this.updateElementWithVertex(this.updatedVertex);
            }
        }

        private function elementsChange(evt:CollectionEvent):void
        {
            if(evt.kind == CollectionEventKind.UPDATE)
            {
                //var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_UPDATED);
                //e.data = this.updatedVertex;

                //this.dispatchEvent(e);
            }
        }

        private function loadXmlVertices(vertices:XMLList):void
        {
            for each(var v:XML in vertices.vertex)
            {
                this.addVertex({id:int(v.@id), x:v.x, y:v.y});
            }
        }

        private function loadXmlElements(elements:XMLList):void
        {
            var v1:Object, v2:Object, v3:Object, v4:Object;

            for each(var e:XML in elements.element)
            {
                if(e.*.length() == 3)
                {
                    v1 = this.getVertex(int(e.v1));
                    v2 = this.getVertex(int(e.v2));
                    v3 = this.getVertex(int(e.v3));

                    this.addElement({id:int(e.@id), v1:v1, v2:v2, v3:v3});
                }
                else
                {
                    v1 = this.getVertex(int(e.v1));
                    v2 = this.getVertex(int(e.v2));
                    v3 = this.getVertex(int(e.v3));
                    v4 = this.getVertex(int(e.v4));

                    this.addElement({id:int(e.@id), v1:v1, v2:v2, v3:v3, v4:v4});
                }
            }
        }

        private function loadXmlBoundaries(boundaries:XMLList):void
        {
            var v1:Object, v2:Object;

            for each(var b:XML in boundaries.boundary)
            {
                v1 = this.getVertex(int(b.v1));
                v2 = this.getVertex(int(b.v2));

                this.addBoundary({id:int(b.@id), v1:v1, v2:v2, marker:b.marker});
            }
        }

        private function loadXmlCurves(curves:XMLList):void
        {

        }

        public function loadXmlData(data:XML):void
        {
            this.clear();

            this.loadXmlVertices(data.vertices);
            this.loadXmlElements(data.elements);
            this.loadXmlBoundaries(data.boundaries);
            this.loadXmlCurves(data.curves);
        }

        public function getMeshXML():String
        {
            var i:int = 0;
            var str:String = "<?xml version='1.0' encoding='UTF8'/?>";
            str += "<mesheditor><vertices>";
            for(i=0;i<this.vertices.length;i++)
            {
                str += "<vertex id='" + this.vertices[i].id + "'>";
                str += "<x>" + this.vertices[i].x + "</x>";
                str += "<y>" + this.vertices[i].y + "</y>";
                str += "</vertex>";
            }

            str += "</vertices><elements>";

            for(i=0;i<this.elements.length;i++)
            {
                str += "<element id='" + this.elements[i].id + "'>";
                str += "<v1>" + this.elements[i].v1.id + "</v1>";
                str += "<v2>" + this.elements[i].v2.id + "</v2>";
                str += "<v3>" + this.elements[i].v3.id + "</v3>";

                try
                {
                    str += "<v4>" + this.elements[i].v4.id + "</v4>";
                }catch(e:Error) {}

                str += "</element>";
            }

            str += "</elements><boundaries>";

            for(i=0;i<this.boundaries.length;i++)
            {
                str += "<boundary id='" + this.boundaries[i].id + "'>";
                str += "<v1>" + this.boundaries[i].v1.id + "</v1>";
                str += "<v2>" + this.boundaries[i].v2.id + "</v2>";
                str += "<marker>" + this.boundaries[i].marker + "</marker>";
                str += "</boundary>";
            }

            str += "</boundaries><curves>";

            for(i=0;i<this.curves.length;i++)
            {
                str += "<curve id='" + this.curves[i].id + "'>";
                str += "<v1>" + this.curves[i].v1.id + "</v1>";
                str += "<v2>" + this.curves[i].v2.id + "</v2>";
                str += "<angle>" + this.curves[i].angle + "</angle>";
                str += "</curve>";
            }

            str += "</curves></mesheditor>";

            return str;
        }

        public function getMeshCSV():String
        {
            var str:String = "[";
            
            for each (var v:Object in this.vertices)
            {
                str += "[" + v.x + "," + v.y + "],";
            }
            str += "],[";

            for each( var el:Object in this.elements)
            {
                var i1:int = this.vertices.getItemIndex(el.v1);
                var i2:int = this.vertices.getItemIndex(el.v2);
                var i3:int = this.vertices.getItemIndex(el.v3);

                try
                {
                    var i4:int = -1;
                    i4 = this.vertices.getItemIndex(el.v4);
                }
                catch(e:Error) {}
                
                if(i4 == -1)
                {
                    str += "[" + i1 + "," + i2 + "," + i3 +  "],";
                }
                else
                {
                    str += "[" + i1 + "," + i2 + "," + i3 + "," + i4 + "],";
                }
            }
            str += "],[";

            for each (var b:Object in this.boundaries)
            {
                i1 = this.vertices.getItemIndex(el.v1);
                i2 = this.vertices.getItemIndex(el.v2);

                str += "[" + i1 + "," + i2 + "," + b.marker +"],";
            }
            str += "],[]";

            return str;
        }
    }
}

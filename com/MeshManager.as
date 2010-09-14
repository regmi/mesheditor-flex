package com
{
    import com.Geometry
    import com.MeshEditorEvent;

    import mx.collections.*;
    import mx.events.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.geom.*;

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
            this.curves = new ArrayCollection();

            this.boundaries = new ArrayCollection();

            this.nextVertexId = 0;
            this.nextElementId = 0;
            this.nextBoundaryId = 0;
            this.nextCurveId = 0;
        }

        public function addVertex(data:Object):void
        {
            if (!this.checkDuplicateVertex(data) && !this.isVertexInsideOtherElement(data))
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
            if(!this.checkDuplicateElement(data) && !this.isElementEncloseOtherVertex(data) && !this.isNewElementIntersectingOtherEdge(data) && !this.isElementWithDuplicateVertices(data))
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

        public function getVertexNotInElement(data:Object):Array
        {
            var vertices:Array = [];

            for each(var vertex:Object in this.vertices)
            {
                var quad:Boolean = false;

                if(data.v1.id == vertex.id || data.v2.id == vertex.id || data.v3.id == vertex.id)
                {
                    continue;
                }
                else
                {
                    try
                    {
                        if(data.v4.id == vertex.id)
                        {
                            continue;
                        }
                    }
                    catch(e:Error){}

                    vertices.push(vertex);
                }
            }
            return vertices;
        }

        public function getElementWithVertex(data:Object, _with:Boolean = true):Array 
        {
            var ewv:Array = [];
            var ewov:Array = [];

            var triangel_element:int;

            for(var i:int=0;i<this.elements.length;i++)
            {
                triangel_element = -1;

                if(this.elements[i].v1.id == data.id)
                    ewv.push(this.elements[i]);
                else
                {
                    if(this.elements[i].v2.id == data.id)
                        ewv.push(this.elements[i]);
                    else
                    {
                        if(this.elements[i].v3.id == data.id)
                            ewv.push(this.elements[i]);
                        else
                        {
                            try
                            {
                                if(this.elements[i].v4.id == data.id)
                                    ewv.push(this.elements[i]);
                                else
                                    ewov.push(this.elements[i]);

                            }catch(e:Error)
                            {
                                triangel_element = 1;
                            }

                            if(triangel_element == 1)
                                ewov.push(this.elements[i]);
                        }
                    }
                }
            }

            if(_with == true)
                return ewv;
            else
                return ewov;
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
        }

        public function updateBoundaryWithVertex(data:Object):void
        {
            var btu:Array = [];

            for(var i:int=0;i<this.boundaries.length;i++)
            {
                if(this.boundaries[i].v1.id == data.id)
                    btu.push(this.boundaries[i]);
                else
                {
                    if(this.boundaries[i].v2.id == data.id)
                        btu.push(this.boundaries[i]);
                }
            }

            for(i=0;i<btu.length;i++)
            {
                var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_UPDATED);
                e.data = btu[i];

                this.dispatchEvent(e);
            }
        }

        public function addBoundary(data:Object):void
        {
            if (!this.checkDuplicateBoundary(data) && !this.isNewBoundaryIntersectingOtherEdge(data) && !this.isMoreThenTwoBoundariesFromSameVertex(data))
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

        public function isVertexInsideElement(data:Object, element:Object):Boolean
        {
            var poly:Array = [];

            poly.push([element.v1.x, element.v1.y]);
            poly.push([element.v2.x, element.v2.y]);
            poly.push([element.v3.x, element.v3.y]);

            try
            {
                poly.push([element.v4.x, element.v4.y]);
            }catch(e:Error){}

            var check_point:Array = [data.x, data.y];

            return Geometry.point_inside_polygon(check_point, poly);
        }

        public function isVertexInsideOtherElement(data:Object):Boolean
        {
            var count:int = 0;
            var ewov:Array;

            ewov = this.getElementWithVertex(data, false);

            for each(var element:Object in ewov)
            {
                if(this.isVertexInsideElement(data, element))
                {
                    count += 1;
                    break;
                }
            }

            if(count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }

            return false;
        }

        public function isNewBoundaryIntersectingOtherEdge(b:Object):Boolean
        {
            var _edges:Array = this.getArrayEdges();
            _edges.push([int(b.v1.id), int(b.v2.id)]);

            var edges:Array = this.getArrayUniqueEdges(_edges);

            return Geometry.any_edges_intersect(this.getArrayNodes(),edges);
        }

        public function isNewElementIntersectingOtherEdge(e:Object):Boolean
        {
            var _edges:Array = this.getArrayEdges();
            _edges.push([int(e.v1.id), int(e.v2.id)]);
            _edges.push([int(e.v2.id), int(e.v3.id)]);

            if(e.v4 == undefined)
            {
                _edges.push([int(e.v3.id),int(e.v1.id)]);
            }
            else
            {
                _edges.push([int(e.v3.id), int(e.v4.id)]);
                _edges.push([int(e.v4.id), int(e.v1.id)]);
            }

            var edges:Array = this.getArrayUniqueEdges(_edges);

            return Geometry.any_edges_intersect(this.getArrayNodes(),edges);
        }

        public function isEdgeIntersectingEdge():Boolean
        {
            return Geometry.any_edges_intersect(this.getArrayNodes(), this.getArrayEdges());
        }

        public function isMoreThenTwoBoundariesFromSameVertex(data:Object):Boolean
        {
            var boundary_count:Dictionary = new Dictionary(); //boundary_count[ vertex_id ] = count

            for each(var b:Object in this.boundaries)
            {
                if(boundary_count[int(b.v1.id)] == undefined)
                {
                    boundary_count[int(b.v1.id)] = 1;
                }
                else
                {
                    boundary_count[int(b.v1.id)] += 1;
                }

                if(boundary_count[int(b.v2.id)] == undefined)
                {
                    boundary_count[int(b.v2.id)] = 1;
                }
                else
                {
                    boundary_count[int(b.v2.id)] += 1;
                }
            }

            if(boundary_count[int(data.v1.id)] == undefined)
            {
                boundary_count[int(data.v1.id)] = 1;
            }
            else
            {
                boundary_count[int(data.v1.id)] += 1;
            }

            if(boundary_count[int(data.v2.id)] == undefined)
            {
                boundary_count[int(data.v2.id)] = 1;
            }
            else
            {
                boundary_count[int(data.v2.id)] += 1;
            }

            if(boundary_count[int(data.v1.id)] <= 2 && boundary_count[int(data.v2.id)] <= 2)
                return false;

            return true;
        }

        public function getArrayNodes():Array
        {
            var nodes:Array = [];
  
            for each(var v:Object in this.vertices)
            {
                nodes.push([Number(v.x),Number(v.y)]);
            }

            return nodes;
        }

        public function getArrayBoundaries():Array
        {
            var _boundaries:Array = [];

            for each(var b:Object in this.boundaries)
            {
                _boundaries.push([int(b.v1.id),int(b.v2.id)]);
            }

            return _boundaries;
        }

        public function getArrayEdges():Array
        {
            var _edges:Array = [];

            for each(var e:Object in this.elements)
            {
                _edges.push([int(e.v1.id),int(e.v2.id)]);
                _edges.push([int(e.v2.id),int(e.v3.id)]);

                if(e.v4 == undefined)
                {
                    _edges.push([int(e.v3.id),int(e.v1.id)]);
                }
                else
                {
                    _edges.push([int(e.v3.id),int(e.v4.id)]);
                    _edges.push([int(e.v4.id),int(e.v1.id)]);
                }
            }

            var edges:Array = this.getArrayUniqueEdges(_edges);
            return edges;
        }

        private function getArrayUniqueEdges(_edges:Array):Array
        {
            var dup:Array = [];
            for(var i:int=0;i<_edges.length;i++)
            {
                for(var j:int=i+1;j<_edges.length;j++)
                {
                    if( (_edges[i][0] == _edges[j][0] && _edges[i][1] == _edges[j][1]) || (_edges[i][0] == _edges[j][1] && _edges[i][1] == _edges[j][0]))
                        dup.push(j);
                }
            }

            var uniqueEdges:Array = [];
            for(i=0;i<_edges.length;i++)
            {
                if(dup.indexOf(i) == -1)
                {
                    uniqueEdges.push([_edges[i][0],_edges[i][1]]);
                }
            }

            return uniqueEdges;
        }

        public function isElementEncloseOtherVertex(data:Object):Boolean
        {
            var vnie:Array = this.getVertexNotInElement(data);

            for each(var vertex:Object in vnie)
            {
                if(this.isVertexInsideElement(vertex, data))
                    return true;
            }
            return false;
        }

        private function isElementWithDuplicateVertices(data:Object):Boolean
        {
            var v:Array = [];
            v.push(data.v1.id)
            v.push(data.v2.id)
            v.push(data.v3.id)

            if(data.v4 != undefined)
            {
                v.push(data.v4.id)
            }

            var dup:Boolean = false;

            for(var i:int=0;i<v.length-1;i++)
            {
                for(var j:int=i+1;j<v.length;j++)
                {
                    if(v[i] == v[j])
                    {
                        dup = true;
                    }
                }
            }

            return dup;
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

        private function getBoundaryVertexId():Array
        {
            var vertex_id:Array = [];

            for each(var b:Object in this.boundaries)
            {
                vertex_id.push(b.v1.id);
                vertex_id.push(b.v2.id);
            }

            return UtilityFunction.getUniqueValue(vertex_id);
        }

        public function isVertexOutsideBoundary():Boolean
        {
            var i:int, v:Object;

            var boundaryVertexId:Array = this.getBoundaryVertexId();
            trace("-boundaryVertexId-")
            trace(boundaryVertexId)

            var boundaryVertexArray:Array = []

            for(i=0;i<boundaryVertexId.length;i++)
            {
                v = this.getVertex(boundaryVertexId[i]);
                boundaryVertexArray.push([v.x, v.y]);
            }

            trace("-boundaryVertexArray-")
            trace(boundaryVertexArray);

            var allVertexId:Array = [];

            for each(v in this.vertices)
            {
                allVertexId.push(v.id);
            }

            var otherVertexId:Array = [];
            
            for(i=0;i<allVertexId.length;i++)
            {
                if(boundaryVertexId.indexOf(allVertexId[i]) == -1)
                {
                    otherVertexId.push(allVertexId[i]);
                }
            }

            trace("-otherVertexId-")
            trace(otherVertexId);

            var inside:Boolean = true;

            for(i=0;i<otherVertexId.length;i++)
            {
                v = this.getVertex(otherVertexId[i]);
                var check_point:Array = [v.x, v.y];

                inside = Geometry.point_inside_polygon(check_point, boundaryVertexArray);
                trace(check_point, inside)

                if(inside == false)
                {
                    trace("-Final-",inside);
                    return inside;
                }
            }

            trace("-Final-",inside);
            return inside;
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
            this.updatedVertex = null;
        }

        private function verticesChange(evt:CollectionEvent):void
        {
            if(evt.kind == CollectionEventKind.UPDATE)
            {
                var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_UPDATED);
                e.data = this.updatedVertex;

                this.dispatchEvent(e);

                this.updateElementWithVertex(this.updatedVertex);
                this.updateBoundaryWithVertex(this.updatedVertex);
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
            var m:int = -1;

            for each(var e:XML in elements.element)
            {
                v1 = this.getVertex(int(e.v1));
                v2 = this.getVertex(int(e.v2));
                v3 = this.getVertex(int(e.v3));

                m = int(e.material)

                if(e.*.length() == 4)
                {
                    this.addElement({id:int(e.@id), v1:v1, v2:v2, v3:v3, material:m});
                }
                else
                {
                    v4 = this.getVertex(int(e.v4));
                    this.addElement({id:int(e.@id), v1:v1, v2:v2, v3:v3, v4:v4, material:m});
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
            this.loadXmlVertices(data.vertices);
            this.loadXmlElements(data.elements);
            this.loadXmlBoundaries(data.boundaries);
            //this.loadXmlCurves(data.curves);
        }

        public function loadHermesData(data:String):void
        {
            //read vertices
            var i:int = data.indexOf("vertices");
            var start_section:Boolean = false;
            var start_data:Boolean = false;
            var tmp_value:String = "";
            var x:Number = 0;
            var y:Number = 0;

            while(true)
            {
                if(data.charAt(i) == "{")
                {
                    if(start_section)
                    {
                        start_data = true;
                    }
                    else
                    {
                        start_section = true;
                    }
                }
                else if(data.charAt(i) == "}")
                {
                    if(start_data)
                    {
                        start_data = false;
                        y = parseFloat(tmp_value);
                        tmp_value = "";

                        this.addVertex({x:x, y:y});
                    }
                    else
                    {
                        start_section = false;
                        break;
                    }
                }
                else
                {
                    if(start_section && start_data)
                    {
                        if(data.charAt(i) == ",")
                        {
                            x = parseFloat(tmp_value);
                            tmp_value = "";
                        }
                        else
                            tmp_value += data.charAt(i);
                    }
                }
                i++;
            }

            //read elements
            i = data.indexOf("elements");
            start_section = false;
            start_data = false;
            tmp_value = "";

            var v1:Object = null;
            var v2:Object = null;
            var v3:Object = null;
            var v4:Object = null;
            var material:int = -1;

            while(true)
            {
                if(data.charAt(i) == "{")
                {
                    if(start_section)
                    {
                        start_data = true;
                    }
                    else
                    {
                        start_section = true;
                    }
                }
                else if(data.charAt(i) == "}")
                {
                    if(start_data)
                    {
                        start_data = false;

                        material = parseInt(tmp_value);

                        tmp_value = "";

                        if(v4 == -1)
                        {
                            this.addElement({v1:v1, v2:v2, v3:v3, material:material});
                        }
                        else
                        {
                            this.addElement({v1:v1, v2:v2, v3:v3, v4:v4, material:material});
                        }
                        v1 = null;
                        v2 = null;
                        v3 = null;
                        v4 = null;
                        material = -1;
                    }
                    else
                    {
                        start_section = false;
                        break;
                    }
                }
                else
                {
                    if(start_section && start_data)
                    {
                        if(data.charAt(i) == ",")
                        {
                            if(v1 == null)
                                v1 = this.getVertex(parseInt(tmp_value));
                            else if(v2 == null)
                                v2 = this.getVertex(parseInt(tmp_value));
                            else if(v3 == null)
                                v3 = this.getVertex(parseInt(tmp_value));
                            else if(v4 == null)
                                v4 = this.getVertex(parseInt(tmp_value));

                            tmp_value = "";
                        }
                        else
                            tmp_value += data.charAt(i);
                    }
                }
                i++;
            }

            //read boundaries
            i = data.indexOf("boundaries");
            start_section = false;
            start_data = false;
            tmp_value = "";

            v1 = null;
            v2 = null;
            var marker:int = -1;

            while(true)
            {
                if(data.charAt(i) == "{")
                {
                    if(start_section)
                    {
                        start_data = true;
                    }
                    else
                    {
                        start_section = true;
                    }
                }
                else if(data.charAt(i) == "}")
                {
                    if(start_data)
                    {
                        start_data = false;

                        marker = parseInt(tmp_value);
                        tmp_value = "";

                        this.addBoundary({v1:v1, v2:v2, marker:marker});

                        v1 = null;
                        v2 = null;
                        marker = -1;
                    }
                    else
                    {
                        start_section = false;
                        break;
                    }
                }
                else
                {
                    if(start_section && start_data)
                    {
                        if(data.charAt(i) == ",")
                        {
                            if(v1 == null)
                                v1 = this.getVertex(parseInt(tmp_value));
                            else if(v2 == null)
                                v2 = this.getVertex(parseInt(tmp_value));

                            tmp_value = "";
                        }
                        else
                            tmp_value += data.charAt(i);
                    }
                }
                i++;
            }
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

                str += "<material>" + this.elements[i].material + "</material>";
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
                i1 = this.vertices.getItemIndex(b.v1);
                i2 = this.vertices.getItemIndex(b.v2);

                str += "[" + i1 + "," + i2 + "," + b.marker +"],";
            }
            str += "],[]";

            return str;
        }

        public function getMeshHermes():String
        {
            var str:String = "vertices = \n{\n";

            for(var i:int=0;i<this.vertices.length;i++)
            {
                if(i==this.vertices.length-1)
                    str += "    {" + this.vertices[i].x + "," + this.vertices[i].y + "}\n";
                else
                    str += "    {" + this.vertices[i].x + "," + this.vertices[i].y + "},\n";
            }

            str += "}\n\nelements = \n{\n";

            for(i=0;i<this.elements.length;i++)
            {
                var i1:int = this.vertices.getItemIndex(this.elements[i].v1);
                var i2:int = this.vertices.getItemIndex(this.elements[i].v2);
                var i3:int = this.vertices.getItemIndex(this.elements[i].v3);
                var material:int = this.elements[i].material;

                try
                {
                    var i4:int = -1;
                    i4 = this.vertices.getItemIndex(this.elements[i].v4);
                }
                catch(e:Error) {}

                if(i==this.elements.length-1)
                {
                    if(i4 == -1)
                    {
                        str += "    {" + i1 + "," + i2 + "," + i3 + "," + material + "}\n";
                    }
                    else
                    {
                        str += "    {" + i1 + "," + i2 + "," + i3 + "," + i4 + "," + material + "}\n";
                    }
                }
                else
                {
                    if(i4 == -1)
                    {
                        str += "    {" + i1 + "," + i2 + "," + i3 + "," + material + "},\n";
                    }
                    else
                    {
                        str += "    {" + i1 + "," + i2 + "," + i3 + "," + i4 + "," + material + "},\n";
                    }
                }
            }

            str += "}\n\nboundaries = \n{\n";

            for(i=0;i<this.boundaries.length;i++)
            {
                i1 = this.vertices.getItemIndex(this.boundaries[i].v1);
                i2 = this.vertices.getItemIndex(this.boundaries[i].v2);

                if(i==this.boundaries.length-1)
                    str += "    {" + i1 + "," + i2 + "," + this.boundaries[i].marker +"}\n";
                else
                    str += "    {" + i1 + "," + i2 + "," + this.boundaries[i].marker +"},\n";
            }

            str += "}\n";

            return str;
        }

        public function getDomainForTriangulation():Object
        {
            var nodes:String = ""
            var boundaries:String = "";

            for each(var v:Object in this.vertices)
            {
                nodes += (v.x + " " + v.y + ",");
            }

            for each (var b:Object in this.boundaries)
            {
                var i1:int = this.vertices.getItemIndex(b.v1);
                var i2:int = this.vertices.getItemIndex(b.v2);

                boundaries += (i1 + " " + i2 + " " + b.marker +",");
            }

            return {"nodes":nodes, "boundaries":boundaries};
        }
    }
}

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

        private var edges:ArrayCollection;

        private var nextVertexId:int;
        private var nextElementId:int;
        private var nextBoundaryId:int;
        private var nextEdgeId:int;

        public var updatedVertex:Object;
        public var updatedBoundary:Object;

        public function MeshManager():void
        {
            super();

            this.vertices = new ArrayCollection();
            this.vertices.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.verticesChange, false);

            this.elements = new ArrayCollection();

            this.boundaries = new ArrayCollection();
            this.boundaries.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.boundariesChange, false);

            this.edges = new ArrayCollection();

            this.nextVertexId = 0;
            this.nextElementId = 0;
            this.nextBoundaryId = 0;
            this.nextEdgeId = 0;
        }

        public function addVertex(data:Object):void
        {
            if (!this.checkDuplicateVertex(data) && !this.isThisVertexInsideAlreadyDrawnElement(data))
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
            this.removeEdgeWithVertex(data);

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
                var ei1:Object = null, ei2:Object = null, ei3:Object = null, ei4:Object = null;

                ei1 = this.addEdge({v1:data.v1, v2:data.v2}, false);
                ei2 = this.addEdge({v1:data.v2, v2:data.v3}, false);

                if(data.v4 == undefined)
                    ei3 = this.addEdge({v1:data.v3, v2:data.v1}, false);
                else
                {
                    ei3 = this.addEdge({v1:data.v3, v2:data.v4}, false);
                    ei4 = this.addEdge({v1:data.v4, v2:data.v1}, false);
                }

                this.traceEdges("addElement()");

                if(data.v4 == undefined)
                    data.edges = [ei1.edge,ei2.edge,ei3.edge];
                else
                    data.edges = [ei1.edge,ei2.edge,ei3.edge,ei4.edge];

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
                this.nextElementId++;

                var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_ADDED);
                evt.data = data;
                this.dispatchEvent(evt);
            }
        }

        public function removeElement(data:Object):void
        {
            for(var i:int=0; i<this.elements.length;i++)
            {
                if(this.elements[i].id == data.id)
                {
                    for each(var edg:Object in this.elements[i].edges)
                    {
                        this.removeEdge(edg, false);
                    }

                    this.elements.removeItemAt(i);

                    break;
                }
            }

            //this.traceEdges("removeElement()");

            var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.ELEMENT_REMOVED);
            evt.data = data;

            this.dispatchEvent(evt);

            if(this.elements.length == 0)
                this.nextElementId = 0;
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
                if(this.elements[i].v1 == data)
                    etu.push(this.elements[i]);
                else
                {
                    if(this.elements[i].v2 == data)
                        etu.push(this.elements[i]);
                    else
                    {
                        if(this.elements[i].v3 == data)
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

        public function updateElementWithEdge(edge:Object):void
        {
            var etu:Array = [];

            for(var i:int=0;i<this.elements.length;i++)
            {
                for each(var edg:Object in this.elements[i].edges)
                {
                    if(edg == edge)
                        etu.push(this.elements[i]);
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
                if(this.boundaries[i].v1 == data)
                    btu.push(this.boundaries[i]);
                else
                {
                    if(this.boundaries[i].v2 == data)
                        btu.push(this.boundaries[i]);
                }
            }

            trace("--boundary updated--")

            for(i=0;i<btu.length;i++)
            {
                var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_UPDATED);
                e.data = btu[i];

                this.dispatchEvent(e);
            }
        }

        private function getEdgeWithVertex(v1:Object, v2:Object):Object
        {
            for each(var e:Object in this.edges)
            {
                if((e.v1 == v1 && e.v2 == v2) || (e.v1 == v2 && e.v2 == v1))
                {
                    return e;
                }
            }

            return null
        }

        private function addEdge(data:Object, validate:Boolean=true):Object
        {
            var edgeInfo:Object = {newEdge:false, edge:null};
            var dupEdge:Object = this.checkDuplicateEdge(data);

            var tooManyBoundaryFromSameVertex:Boolean = false;
            var newEdgeIntersectOtherEdge:Boolean = false;

            if(dupEdge != null)
            {
                edgeInfo.newEdge = false;
                edgeInfo.edge = dupEdge;
                return edgeInfo;
            }

            if(validate)
            {
                if(data.boundary == true)
                    tooManyBoundaryFromSameVertex = this.isMoreThenTwoBoundariesFromSameVertex(data);

                newEdgeIntersectOtherEdge = this.isNewEdgeIntersectingOtherEdge(data);
            }

            if (!tooManyBoundaryFromSameVertex && !newEdgeIntersectOtherEdge)
            {
                if(data.id == null)
                {
                    data.id = this.nextEdgeId;
                }
                else
                {
                    if(data.id > this.nextEdgeId)
                        this.nextEdgeId = data.id;
                }

                this.edges.addItem(data);
                this.nextEdgeId++;

                edgeInfo.newEdge = true;
                edgeInfo.edge = this.edges[this.edges.length-1];
            }

            return edgeInfo;
        }

        public function addBoundary(data:Object):void
        {
            var edgeInfo:Object = this.addEdge(data);

            if(edgeInfo.edge != null)
            {
                if(this.boundaries.getItemIndex(edgeInfo.edge) == -1)
                {
                    edgeInfo.edge.marker = data.marker;
                    edgeInfo.edge.angle = data.angle;
                    edgeInfo.edge.boundary = true;

                    edgeInfo.edge.v1 = data.v1;
                    edgeInfo.edge.v2 = data.v2;

                    //this.traceEdges("addBoundary()");

                    this.boundaries.addItem(edgeInfo.edge);

                    var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_ADDED);
                    evt.data = edgeInfo.edge;

                    this.dispatchEvent(evt);

                    this.updateElementWithEdge(edgeInfo.edge);
                }
            }
        }

        private function traceEdges(msg:String):void
        {
            trace("--- All Edges: " + msg + " ---")
            trace(this.edges.length);
            for(var i:Number=0 ;i<this.edges.length;i++)
            {
                trace(this.edges[i].v1.id, this.edges[i].v2.id, this.edges[i].boundary)
            }
        }

        public function removeEdge(data:Object, removeBoundary:Boolean):void
        {
            if(data.boundary == true)
            {
                if(removeBoundary)
                    this.edges.removeItemAt(this.edges.getItemIndex(data));
            }
            else
            {
                this.edges.removeItemAt(this.edges.getItemIndex(data));
            }

            if(this.edges.length == 0)
                this.nextEdgeId = 0;
        }

        public function removeBoundary(data:Object):void
        {
            this.boundaries.removeItemAt(this.boundaries.getItemIndex(data));

            if(this.boundaries.length == 0)
                this.nextBoundaryId = 0;

            if(!this.isEdgeInElement(data))
            {
                this.removeEdge(data, true);
            }
            else
            {
                delete data.marker;
                delete data.angle;
                delete data.boundary;
            }

            //this.traceEdges("removeBoundary()");

            var evt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_REMOVED);
            evt.data = data;

            this.dispatchEvent(evt);
        }

        public function removeEdgeWithVertex(data:Object):void
        {
            var etr:Array = [];

            for(var i:int=0;i<this.edges.length;i++)
            {
                if(this.edges[i].v1.id == data.id)
                    etr.push(this.edges[i]);
                else
                {
                    if(this.edges[i].v2.id == data.id)
                        etr.push(this.edges[i]);
                }
            }

            for(i=0;i<etr.length;i++)
            {
                this.removeEdge(etr[i], true);
            }

            if(this.edges.length == 0)
                this.nextEdgeId = 0;
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

        private function checkDuplicateVertex(data:Object):Boolean
        {
            for(var i:int=0;i<this.vertices.length;i++)
            {
                if(this.vertices[i].x == data.x && this.vertices[i].y == data.y)
                    return true;
            }

            return false;
        }

        public function isVertexInsideElement(vertex:Object, element:Object):Boolean
        {
            var polyEdges:Array = [];

            polyEdges.push([element.v1, element.v2]);
            polyEdges.push([element.v2, element.v3]);

            if(element.v4 == undefined)
            {
                polyEdges.push([element.v3, element.v1]);
            }
            else
            {
                polyEdges.push([element.v3, element.v4]);
                polyEdges.push([element.v4, element.v1]);
            }

            return Geometry.pointInsidePolygon(vertex, polyEdges);
        }

        public function isAnyVertexOutsideBoundary():int
        {
            var domain:Array = this.getArrayBoundaries();

            var loops:Array = Geometry.findLoop(domain);

            if(loops == null)
            {
                //Open Boundaries
                return -1;
            }
            else
            {
                var boundaryVertexArray:Array = []
                for each(var b:Object in this.boundaries)
                {
                    if(boundaryVertexArray.indexOf(b.v1) == -1)
                        boundaryVertexArray.push(b.v1);

                    if(boundaryVertexArray.indexOf(b.v2) == -1)
                        boundaryVertexArray.push(b.v2);
                }

                var otherVertexArray:Array = [];
                for each(var v:Object in this.vertices)
                {
                    if(boundaryVertexArray.indexOf(v) == -1)
                    {
                        otherVertexArray.push(v);
                    }
                }

                for(var a:int=0;a<otherVertexArray.length;a++)
                {
                    var check_point:Object = otherVertexArray[a];
                    var inside:Boolean = Geometry.pointInsidePolygon(check_point, domain);

                    if(inside == false)
                    {
                        return -2;
                    }
                }

                return 0;
            }

            return -3;
        }

        public function isThisVertexInsideAlreadyDrawnElement(data:Object):Boolean
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

        private function isEdgeInElement(edge:Object):Boolean
        {
            var cnt:Number = 0;
            for each(var e:Object in this.elements)
            {
                if( e.edges.indexOf(edge) == -1)
                    cnt++;
                else
                    return true;
            }

            if(cnt == this.elements.length)
                return false;

            return true;
        }

        public function isAnyVertexInsideAnyElement():Boolean
        {
            var count:int = 0;

            for each(var v:Object in this.vertices)
            {
                var ewov:Array = this.getElementWithVertex(v, false);
                count = 0;

                for each(var element:Object in ewov)
                {
                    if(this.isVertexInsideElement(v, element))
                    {
                        count += 1;
                        break;
                    }
                }

                if(count != 0)
                    return true;
            }

            return false;
        }

        public function isNewEdgeIntersectingOtherEdge(b:Object):Boolean
        {
            var _edges:Array = this.getArrayEdges();
            _edges.push([b.v1, b.v2]);

            var edges:Array = this.getArrayUniqueEdges(_edges);

            return Geometry.anyEdgesIntersect(edges);
        }

        public function isNewElementIntersectingOtherEdge(e:Object):Boolean
        {
            var _edges:Array = this.getArrayEdges();
            _edges.push([e.v1, e.v2]);
            _edges.push([e.v2, e.v3]);

            if(e.v4 == undefined)
            {
                _edges.push([e.v3, e.v1]);
            }
            else
            {
                _edges.push([e.v3, e.v4]);
                _edges.push([e.v4, e.v1]);
            }

            var edges:Array = this.getArrayUniqueEdges(_edges);

            return Geometry.anyEdgesIntersect(edges);
        }

        public function isEdgeIntersectingEdge():Boolean
        {
            return Geometry.anyEdgesIntersect(this.getArrayEdges());
        }

        public function isMoreThenTwoBoundariesFromSameVertex(data:Object):Boolean
        {
            var boundary_count:Dictionary = new Dictionary(); //boundary_count[ vertex_Obj ] = count

            for each(var b:Object in this.boundaries)
            {
                if(boundary_count[b.v1] == undefined)
                {
                    boundary_count[b.v1] = 1;
                }
                else
                {
                    boundary_count[b.v1] += 1;
                }

                if(boundary_count[b.v2] == undefined)
                {
                    boundary_count[b.v2] = 1;
                }
                else
                {
                    boundary_count[b.v2] += 1;
                }
            }

            if(boundary_count[data.v1] == undefined)
            {
                boundary_count[data.v1] = 1;
            }
            else
            {
                boundary_count[data.v1] += 1;
            }

            if(boundary_count[data.v2] == undefined)
            {
                boundary_count[data.v2] = 1;
            }
            else
            {
                boundary_count[data.v2] += 1;
            }

            if(boundary_count[data.v1] <= 2 && boundary_count[data.v2] <= 2)
                return false;

            return true;
        }

        public function getArrayBoundaries():Array
        {
            var _boundaries:Array = [];

            for each(var b:Object in this.boundaries)
            {
                _boundaries.push([b.v1,b.v2]);
            }

            return _boundaries;
        }

        public function getArrayEdges():Array
        {
            var _edges:Array = [];

            for each(var e:Object in this.edges)
            {
                _edges.push([e.v1,e.v2]);
            }
    
            return _edges;
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
            v.push(data.v1)
            v.push(data.v2)
            v.push(data.v3)

            if(data.v4 != undefined)
            {
                v.push(data.v4)
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

            vId1.push(data.v1);
            vId1.push(data.v2);
            vId1.push(data.v3);

            if(data.v4 != undefined)
                vId1.push(data.v4);

            for each(var element:Object in this.elements)
            {
                count = 0;
                vId2.splice(0,vId2.length);

                vId2.push(element.v1);
                vId2.push(element.v2);
                vId2.push(element.v3);

                if(data.v4 != undefined)
                    vId1.push(data.v4);

                if(vId1.length == vId2.length)
                {
                    for each(var val:Object in vId2)
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

        private function checkDuplicateEdge(data:Object):Object
        {
            for(var i:int=0;i<this.edges.length;i++)
            {
                if((this.edges[i].v1 == data.v1 && this.edges[i].v2 == data.v2) || (this.edges[i].v1 == data.v2 && this.edges[i].v2 == data.v1))
                    return this.edges[i];
            }

            return null;
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

        public function clear():void
        {
            this.vertices.removeAll();
            this.elements.removeAll();
            this.boundaries.removeAll();
            this.edges.removeAll();

            this.nextVertexId = 0;
            this.nextElementId = 0;
            this.nextEdgeId = 0;
            this.nextBoundaryId = 0;
            this.updatedVertex = null;
            this.updatedBoundary = null;
        }

        private function verticesChange(evt:CollectionEvent):void
        {
            if(evt.kind == CollectionEventKind.UPDATE)
            {
                if(this.updatedVertex != null)
                {
                    this.updatedVertex.x = Number(this.updatedVertex.x);
                    this.updatedVertex.y = Number(this.updatedVertex.y);

                    var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.VERTEX_UPDATED);
                    e.data = this.updatedVertex;

                    this.dispatchEvent(e);

                    this.updateElementWithVertex(this.updatedVertex);
                    this.updateBoundaryWithVertex(this.updatedVertex);
                }
            }
        }

        private function boundariesChange(evt:CollectionEvent):void
        {
            if(evt.kind == CollectionEventKind.UPDATE)
            {
                if(this.updatedBoundary != null)
                {
                    this.updatedBoundary.angle = Number(this.updatedBoundary.angle);
                    this.updatedBoundary.marker = int(this.updatedBoundary.marker);

                    var e:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.BOUNDARY_UPDATED);
                    e.data = this.updatedBoundary;

                    this.dispatchEvent(e);

                    this.updateElementWithEdge(this.updatedBoundary);
                }
            }
        }

        private function loadXmlVertices(vertices:XMLList):void
        {
            for each(var v:XML in vertices.vertex)
            {
                this.addVertex({id:int(v.@id), x:Number(v.x), y:Number(v.y)});
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

                this.addBoundary({id:int(b.@id), v1:v1, v2:v2, marker:int(b.marker), angle:Number(b.angle), boundary:true});
            }
        }

        public function loadXmlData(data:XML):void
        {
            this.loadXmlVertices(data.vertices);
            this.loadXmlElements(data.elements);
            this.loadXmlBoundaries(data.boundaries);
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

            //read curves
            var _curves:Array = [];
            i = data.indexOf("curves");
            if(i != -1)
            {
                start_section = false;
                start_data = false;
                tmp_value = "";

                v1 = null;
                v2 = null;
                var angle:int = -1;

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

                            angle = parseInt(tmp_value);
                            tmp_value = "";

                            _curves.push({v1:v1, v2:v2, angle:angle});

                            v1 = null;
                            v2 = null;
                            angle = -1;
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
            else
                var noCurves:Boolean = true;

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

                        if(noCurves)
                        {
                            this.addBoundary({v1:v1, v2:v2, marker:marker, boundary:true, angle:0});
                        }
                        else
                        {
                            for each(var c:Object in _curves)
                            {
                                if((v1 == c.v1 && v2 == c.v2) || (v1 == c.v2 && v2 == c.v1))
                                {
                                    c.marker = marker;
                                    c.boundary = true;
                                    this.addBoundary(c);

                                    _curves.splice(_curves.indexOf(c),1);

                                    var curveAdded:Boolean = true;
                                }
                            }

                            if(!curveAdded)
                                this.addBoundary({v1:v1, v2:v2, marker:marker, boundary:true, angle:0});

                            curveAdded = false;
                        }

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

            str += "</boundaries></mesheditor>";

            return str;
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
            var hasCurves:Boolean = false;
            var strCurves:String = "";

            for(i=0;i<this.boundaries.length;i++)
            {
                i1 = this.vertices.getItemIndex(this.boundaries[i].v1);
                i2 = this.vertices.getItemIndex(this.boundaries[i].v2);

                if(this.boundaries[i].angle != 0)
                {
                    hasCurves = true;
                    strCurves += "    {" + i1 + "," + i2 + "," + this.boundaries[i].angle +"},\n";
                }

                if(i==this.boundaries.length-1)
                    str += "    {" + i1 + "," + i2 + "," + this.boundaries[i].marker +"}\n";
                else
                    str += "    {" + i1 + "," + i2 + "," + this.boundaries[i].marker +"},\n";
            }

            if(hasCurves)
            {
                str += "}\n\ncurves = \n{\n";
                str += ( strCurves.slice(0,strCurves.length-2) + "\n" );
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

                boundaries += (i1 + " " + i2 + " " + b.marker + " " + b.angle + ",");
            }

            return {"nodes":nodes, "boundaries":boundaries};
        }
    }
}

package com
{
    import mx.collections.*;

    public class Geometry
    {
        public static function ccw(A:Object, B:Object, C:Object):Boolean
        {
            return (C.y-A.y)*(B.x-A.x) > (B.y-A.y)*(C.x-A.x);
        }

        public static function intersect(A:Object, B:Object, C:Object, D:Object):Boolean
        {
            return Geometry.ccw(A, C, D) != Geometry.ccw(B, C, D) && Geometry.ccw(A, B, C) != Geometry.ccw(A, B, D);
        }

        public static function twoEdgesIntersect(e1:Array, e2:Array):Boolean
        {
            return Geometry.intersect(e1[0], e1[1], e2[0], e2[1]);
        }

        public static function anyEdgesIntersect(edges:Array):Boolean
        {
            for(var i:int = 0; i<edges.length; i++)
            {
                for(var j:int = i+1; j<edges.length; j++)
                {
                    var e1:Array = edges[i];
                    var e2:Array = edges[j];

                    if(e1[1] == e2[0] || e1[0] == e2[1])
                        continue;

                    if(Geometry.twoEdgesIntersect(e1, e2))
                        return true;
                }
            }
            return false;
        }

        public static function edgeIntersectsEdges(e1:Array, edges:Array):Boolean
        {
            for(var i:int=0; i<edges.length; i++)
            {
                var e2:Array = edges[i];

                if(e1[1] == e2[0] || e1[0] == e2[1])
                    continue;

                if(Geometry.twoEdgesIntersect(e1, e2))
                    return true
            }

            return false
        }

        public static function pointInsidePolygon(checkPoint:Object, polyEdges:Array):Boolean
        {
            var intersect:int = 0;
            var testEdge:Array = [checkPoint, {x:100, y:checkPoint.y}];

            for each(var e:Array in polyEdges)
            {
                if(Geometry.twoEdgesIntersect(testEdge, e))
                    intersect += 1;
            }

            if(intersect % 2 == 0)
                return false;
            else
                return true;

            return false;
        }

        public static function findLoop(edges:Array):Array
        {
            var loops:Array = [];
            var loopId:int = 0, currentEdge:int = 0;

            loops.push([edges[0]]);
            edges.splice(0,1);

            var currentLoop:Array = loops[loopId];
            var l:int = edges.length;

            try
            {
                while(l > 0)
                {
                    for(var i:int=0;i<edges.length;i++)
                    {
                        if(currentLoop[currentEdge][0] == edges[i][0] || currentLoop[currentEdge][0] == edges[i][1] || currentLoop[currentEdge][1] == edges[i][0] || currentLoop[currentEdge][1] == edges[i][1])
                        {
                            currentLoop.push(edges[i])
                            edges.splice(i,1);
                            break;
                        }
                    }

                    currentEdge++;

                    if(currentLoop.length > 2 && (currentLoop[0][0] == currentLoop[currentLoop.length-1][0] || currentLoop[0][0] == currentLoop[currentLoop.length-1][1] || currentLoop[0][1] == currentLoop[currentLoop.length-1][0] || currentLoop[0][1] == currentLoop[currentLoop.length-1][1]))
                    {
                        if(edges.length >= 1)
                        {
                            loops.push([edges[0]])
                            edges.splice(0,1);
                            loopId += 1;
                            currentLoop = loops[loopId];
                            currentEdge = 0;
                        }
                    }

                    l--;
                }
            }
            catch(e:Error)
            {
                return null;
            }

            if(currentLoop.length > 2 && (currentLoop[0][0] == currentLoop[currentLoop.length-1][0] || currentLoop[0][0] == currentLoop[currentLoop.length-1][1] || currentLoop[0][1] == currentLoop[currentLoop.length-1][0] || currentLoop[0][1] == currentLoop[currentLoop.length-1][1]))
                return loops
            else
                return null;

            return loops;
        }

        public static function getPolygonVerticesFromPolygonEdges(polygonEdges:Array):Array
        {
            var polyVertices:Array = [];

            var e1:Array = polygonEdges[0];
            for(var i:int=1; i<=polygonEdges.length;i++)
            {
                var e2:Array = polygonEdges[i%polygonEdges.length];

                if(e1[0] == e2[0] || e1[0] == e2[1])
                {
                    polyVertices.push(e1[0]);
                }
                else if(e2[0] == e1[0] || e2[0] == e1[1])
                {
                    polyVertices.push(e2[0]);
                }

                e1 = e2;
            }

            //polyVertices.push(polyVertices[0]);

            return polyVertices;
        }
    }
}

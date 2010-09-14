package com
{
    public class Geometry
    {
        public static function ccw(A:Array, B:Array, C:Array):Boolean
        {
            return (C[1]-A[1])*(B[0]-A[0]) > (B[1]-A[1])*(C[0]-A[0]);
        }

        public static function intersect(A:Array, B:Array, C:Array, D:Array):Boolean
        {
            return Geometry.ccw(A, C, D) != Geometry.ccw(B, C, D) && Geometry.ccw(A, B, C) != Geometry.ccw(A, B, D);
        }

        public static function two_edges_intersect(nodes:Array, e1:Array, e2:Array):Boolean
        {
            var A:Array = nodes[e1[0]];
            var B:Array = nodes[e1[1]];
            var C:Array = nodes[e2[0]];
            var D:Array = nodes[e2[1]];

            return Geometry.intersect(A, B, C, D);
        }

        public static function any_edges_intersect(nodes:Array, edges:Array):Boolean
        {
            for(var i:int = 0; i<edges.length; i++)
            {
                for(var j:int = i+1; j<edges.length; j++)
                {
                    var e1:Array = edges[i];
                    var e2:Array = edges[j];

                    if(e1[1] == e2[0] || e1[0] == e2[1])
                        continue;

                    if(Geometry.two_edges_intersect(nodes, e1, e2))
                        return true;
                }
            }
            return false;
        }

        public static function edge_intersects_edges(e1:Array, nodes:Array, edges:Array):Boolean
        {
            for(var i:int=0; i<edges.length; i++)
            {
                var e2:Array = edges[i];

                if(e1[1] == e2[0] || e1[0] == e2[1])
                    continue;

                if(Geometry.two_edges_intersect(nodes, e1, e2))
                    return true
            }

            return false
        }

        public static function point_inside_polygon(check_point:Array, poly:Array):Boolean
        {
            var cx:Number = check_point[0];
            var cy:Number = check_point[1];

            var n:int = poly.length;

            var inside:Boolean = false;

            var p1x:Number = poly[0][0];
            var p1y:Number = poly[0][1];

            for(var i:int=1;i<=n;i++)
            {
                var p2x:Number = poly[i%n][0]
                var p2y:Number = poly[i%n][1]

                if(cy > Math.min(p1y,p2y) && cy <= Math.max(p1y,p2y))
                {
                    if(cx <= Math.max(p1x,p2x))
                    {
                        if(p1y != p2y)
                        {
                            var xinters:Number = (cy-p1y)*(p2x-p1x)/(p2y-p1y)+p1x;

                            if(p1x == p2x || cx <= xinters)
                            {
                                inside = (!inside);
                            }
                        }
                    }
                }

                p1x = p2x;
                p1y = p2y;
            }

            return inside;
        }

        public static function pointInPoly(check_point:Array, poly:Array):Boolean
        {
            var i:int, j:int, c:Boolean = false;

            for (i = 0, j = poly.length-1; i < poly.length; j = i++)
            {
                if ( ((poly[i][1]>check_point[1]) != (poly[j][1]>check_point[1])) && (check_point[0] < (poly[j][0]-poly[i][0]) * (check_point[1]-poly[i][1]) / (poly[j][1]-poly[i][1]) + poly[i][0]) )
                   c = !c;
            }

            return c;
        }

        public static function find_loop(edges:Array):Array
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
    }
}

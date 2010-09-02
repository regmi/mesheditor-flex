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
            trace(edges.length)

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
    }
}

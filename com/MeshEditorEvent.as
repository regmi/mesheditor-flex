package com
{
    import flash.events.Event;

    public class MeshEditorEvent extends Event
    {
        public static const VERTEX_ADDED:String = "vertexAdded";
        public static const VERTEX_REMOVED:String = "vertexRemoved";
        public static const VERTEX_SUBMITTED:String = "vertexSubmitted";
        public static const VERTEX_UPDATED:String = "vertexUpdated";
        public static const VERTEX_DRAG_END:String = "vertexDragEnd";

        public static const ELEMENT_ADDED:String = "elementAdded";
        public static const ELEMENT_REMOVED:String = "elementRemoved";
        public static const ELEMENT_SUBMITTED:String = "elementSubmitted";
        public static const ELEMENT_SELECTED:String = "elementSelected";
        public static const ELEMENT_UPDATED:String = "elementUpdated";

        public static const BOUNDARY_ADDED:String = "boundaryAdded";
        public static const BOUNDARY_REMOVED:String = "boundaryRemoved";
        public static const BOUNDARY_SUBMITTED:String = "boundarySubmitted";
        public static const BOUNDARY_SELECTED:String = "boundarySelected";
        public static const BOUNDARY_UPDATED:String = "boundaryUpdated";

        public var data:Object;
        public var data2:Object;

        public function MeshEditorEvent(eventName:String)
        {
            super(eventName);
        }

        public override function clone():Event 
        {
            return new MeshEditorEvent(this.type);
        }
    }
}

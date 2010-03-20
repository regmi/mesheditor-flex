package com
{
    import flash.events.Event;

    public class MeshEditorEvent extends Event
    {
        public static const VERTEX_ADDED:String = "vertexAdded";
        public static const VERTEX_REMOVED:String = "vertexRemoved";
        public static const VERTEX_SUBMIT:String = "vertexSubmit";

        public static const ELEMENT_ADDED:String = "elementAdded";
        public static const ELEMENT_REMOVED:String = "elementRemoved";
        public static const ELEMENT_SUBMIT:String = "elementSubmit";
        public static const ELEMENT_SELECTED:String = "elementSelected";

        public static const BOUNDARY_ADDED:String = "boundaryAdded";
        public static const BOUNDARY_REMOVED:String = "boundaryRemoved";
        public static const BOUNDARY_SUBMIT:String = "boundarySubmit";
        public static const BOUNDARY_SELECTED:String = "boundarySelected";

        /*
        *
        */
        public var data:Object;

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

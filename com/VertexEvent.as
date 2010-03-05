package com
{
    import flash.events.Event;

    public class VertexEvent extends Event
    {
        public static const ADD_VERTEX:String = "addVertex";
        public static const REMOVE_VERTEX:String = "removeVertex";
        public static const EDIT_VERTEX:String = "editVertex";
        public static const VERTEX_LIST_CHANGE:String = "vertexListChange";

        public var data:Object;

        public function VertexEvent(eventName:String)
        {
            super (eventName);
        }
    }
}

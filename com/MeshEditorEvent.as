package com
{
    import flash.events.Event;

    public class MeshEditorEvent extends Event
    {
        public static const VERTEX_ADD:String = "vertexAdd";
        public static const VERTEX_REMOVE:String = "vertexRemove";
        public static const VERTEX_EDIT:String = "vertexEdit";
        public static const VERTEX_SUBMIT:String = "vertexSubmit";
        public static const VERTEX_LIST_CHANGE:String = "vertexListChange";

        public static const ELEMENT_ADD:String = "elementAdd";
        public static const ELEMENT_REMOVE:String = "elementRemove";
        public static const ELEMENT_EDIT:String = "elementEdit";
        public static const ELEMENT_SUBMIT:String = "elementSubmit";
        public static const ELEMENT_LIST_CHANGE:String = "elementListChange";

        /*
        *
        *
        */
        public var data:Object;

        public function MeshEditorEvent(eventName:String)
        {
            super (eventName);
        }

        public override function clone():Event 
        {
            return new MeshEditorEvent(this.type);
        }
    }
}

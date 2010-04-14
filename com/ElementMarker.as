package com
{
    import com.MeshEditorEvent;
    import flash.ui.*;
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;

    public class ElementMarker extends Sprite
    {
        public function ElementMarker()
        {
            super();

            var menuItem:ContextMenuItem = new ContextMenuItem("Change Color");
            //menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,changeColor);

            var customContextMenu:ContextMenu = new ContextMenu();

            //hide the Flash menu
            //customContextMenu.hideBuiltInItems();
            customContextMenu.customItems.push(menuItem);

            this.contextMenu = customContextMenu;
        }

        //It should be called only after ElementMarker is placed in the display list
        public function drawBorder(vertexList:Array):void
        {
            this.x = vertexList[0].x;
            this.y = -vertexList[0].y;

            this.graphics.clear();
            this.graphics.lineStyle(1, 0x0033FF);
            this.graphics.beginFill(0xCECECE, 0.5);

            for(var i:int=1;i<vertexList.length;i++)
            {   
                var gp:Point = this.parent.localToGlobal(new Point(vertexList[i].x, -vertexList[i].y));
                var lp:Point = this.globalToLocal(gp);
                this.graphics.lineTo(lp.x, lp.y);
            }

            this.graphics.lineTo(0,0);
            this.graphics.endFill();
        }
    }
}

package com
{
    import com.MeshEditorEvent;
    import flash.ui.*;
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;

    public class ElementMarker extends Sprite
    {
        public var dataProvider:Object;

        public function ElementMarker(data:Object)
        {
            super();
            this.dataProvider = data;
            this.doubleClickEnabled = true;

            /*
            var menuItem:ContextMenuItem = new ContextMenuItem("Change Color");
            //menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,changeColor);

            var customContextMenu:ContextMenu = new ContextMenu();

            //hide the Flash menu
            //customContextMenu.hideBuiltInItems();
            customContextMenu.customItems.push(menuItem);
            this.contextMenu = customContextMenu;
            */

            //this.buttonMode = true;
            //this.useHandCursor = true;
        }

        //It should be called only after ElementMarker is placed in the display list
        public function __drawBorder(data:Object, scaleFactor:Number):void
        {
            this.x = scaleFactor*data.v1.x;
            this.y = -scaleFactor*data.v1.y;

            this.graphics.clear();
            this.graphics.lineStyle(1, 0x0033FF);
            this.graphics.beginFill(0xCECECE, 0.5);

            var gp:Point = this.parent.localToGlobal(new Point(scaleFactor*data.v2.x, -scaleFactor*data.v2.y));
            var lp:Point = this.globalToLocal(gp);
            this.graphics.lineTo(lp.x, lp.y);

            try
            {
                gp = this.parent.localToGlobal(new Point(scaleFactor*data.v3.x, -scaleFactor*data.v3.y));
                lp = this.globalToLocal(gp);
                this.graphics.lineTo(lp.x, lp.y);
            }
            catch(e:Error) { }

            try
            {
                gp = this.parent.localToGlobal(new Point(scaleFactor*data.v4.x, -scaleFactor*data.v4.y));
                lp = this.globalToLocal(gp);
                this.graphics.lineTo(lp.x, lp.y);
            }
            catch(e:Error) { }

            this.graphics.lineTo(0,0);
            this.graphics.endFill();
        }

        public function drawBorder(data:Object, scaleFactor:Number):void
        {
            this.graphics.clear();
            this.graphics.lineStyle(1, 0x0033FF);

            this.graphics.beginFill(0xCECECE, 0.5);

            for each(var edg:Object in data.edges)
            {
                if(edg.boundary == true && edg.angle != 0)
                {
                    var arcInfo:Object = Geometry.getArcInfo(edg);
                    DrawingShapes.drawArc1(this.graphics, arcInfo, scaleFactor);
                }
                else
                {
                    this.graphics.moveTo(scaleFactor*edg.v1.x, -scaleFactor*edg.v1.y);
                    this.graphics.lineTo(scaleFactor*edg.v2.x, -scaleFactor*edg.v2.y);
                }
            }

            this.graphics.endFill();
        }
    }
}

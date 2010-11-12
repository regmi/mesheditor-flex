package com
{   
    import flash.external.*;

    public class Debug
    {
        public static function jsLog(val:Object, alert:Boolean=false):void
        {
            if(ExternalInterface.available)
            {
                ExternalInterface.call("console.log", val);

                if(alert)
                    ExternalInterface.call("alert", val);
            }
        }
    }
}

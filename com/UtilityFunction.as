package com
{
    import flash.utils.*;
    
    public class UtilityFunction
    {
        //Get Unique values from an Array
        public static function getUniqueValue(originalArray:Array):Array
        {
            var lookup:Dictionary = new Dictionary();
            var uniqueArr:Array = [];

            for(var i:int=0;i < originalArray.length;i++)
            {
                var num:int = originalArray[i];

                if(lookup[num] == undefined)
                {
                    uniqueArr.push(num);
                    lookup[num] = true;
                }
            }

            return uniqueArr;
        }
    }
}

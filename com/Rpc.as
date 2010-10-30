package com
{
    import flash.events.*;
    import mx.rpc.http.*;
    import mx.rpc.events.*;

    import com.adobe.serialization.json.JSON;

    public class Rpc extends EventDispatcher
    {
        private var uuid:String = "";
        private var httpUserRequest:HTTPService;

        public function Rpc(url:String, uuid:String="101"):void
        {
            this.uuid = uuid;

            this.httpUserRequest = new HTTPService();

            this.httpUserRequest.url = url;
            this.httpUserRequest.method = "POST";
            this.httpUserRequest.contentType = "application/json"
            this.httpUserRequest.resultFormat = "text";

            this.init();
        }

        private function init():void
        {
            this.httpUserRequest.addEventListener(ResultEvent.RESULT, this.initResult);

            var arg:Object = {
                                "jsonrpc": "2.0",
                                "params": { "uuid":uuid },
                                "method": "init",
                                "id": 1
                            };

            var jsonArgs:String = JSON.encode(arg);

            this.httpUserRequest.request = jsonArgs;
            this.httpUserRequest.send();
        }

        private function initResult(evt:ResultEvent):void
        {
            var resObject:Object = JSON.decode(String(evt.result));

            if(resObject.result.status == "started" || resObject.result.status == "running")
            {
                Debug.trace("-- RPC initialization suceed ! --");
            }
            else
            {
                this.uuid = "";

                Debug.trace("-- RPC initialization failed --", true);
                Debug.trace(String(evt.result));
            }

            this.httpUserRequest.removeEventListener(ResultEvent.RESULT, this.initResult);
            this.httpUserRequest.addEventListener(ResultEvent.RESULT, this.queryResult);
        }

        public function evaluate(source:String):void
        {
            var arg:Object = {
                                "jsonrpc": "2.0",
                                "params": { "uuid":this.uuid, "source": source },
                                "method": "evaluate",
                                "id": 1
                            };

            var jsonArgs:String = JSON.encode(arg);
            this.httpUserRequest.request = jsonArgs;
            this.httpUserRequest.send();
        }

        private function queryResult(evt:ResultEvent):void
        {
            var meEvt:MeshEditorEvent = new MeshEditorEvent(MeshEditorEvent.RPC_RESULT);
            var res:String = String(evt.result);
            //Debug.trace(res)
            meEvt.data = JSON.decode(res);
            this.dispatchEvent(meEvt);
        }
    }
}

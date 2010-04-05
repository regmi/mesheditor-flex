import cgi
from django.http import HttpResponse

def index(request):
    return HttpResponse("""
    a-ok
    <a href="/upload/">upload</a></br>
    <a href="/worksheet/">worksheet</a></br>
    """)

def upload(request):
    return HttpResponse("""
    request obj: <pre>%s</pre>
    """ % (cgi.escape(str(request))))

def worksheet(request):
    return HttpResponse("""
    <html>
        <head>
            <script language="JavaScript" type="text/javascript">
                function showAlert(msg)
                {
                    alert(msg);
                }
            </script>
        </head>

        <body>
            <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="830" height="600">
                <param name="movie" value="/MeshEditor.swf">
                <!--[if !IE]>-->
                <object type="application/x-shockwave-flash" data="/MeshEditor.swf" width="830" height="600">
                <!--<![endif]-->
                    <param name="flashvars" value="variable1=a&variable2=b" />
                    <p>Alternative Content</p>
                <!--[if !IE]>-->
                </object>
                <!--<![endif]-->
            </object>
        </body>
    </html>
    """)

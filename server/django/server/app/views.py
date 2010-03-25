import cgi
from django.http import HttpResponse

def index(request):
    return HttpResponse("""
    a-ok
    <a href="/upload/">upload</a>
    """)

def upload(request):
    f = open("/home/aayush/test.ok", "w")
    f.close()
    return HttpResponse("""
    request obj: <pre>%s</pre>
    """ % (cgi.escape(str(request))))

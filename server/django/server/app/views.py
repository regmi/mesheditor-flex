import cgi
from django.http import HttpResponse

def index(request):
    return HttpResponse("""
    a-ok
    <a href="/upload/">upload</a></br>
    <a href="/flex/">flex</a></br>
    """)

def upload(request):
    f = open("/home/aayush/test.ok", "w")
    f.close()
    return HttpResponse("""
    request obj: <pre>%s</pre>
    """ % (cgi.escape(str(request))))

def flex(request):
    return HttpResponse("""
    LOAD FLEX</br>
    <button onclick="

alert('ok');

">Save</button>
    """)

from django.conf.urls.defaults import *
# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

import os.path
p = os.path.join(os.path.dirname(__file__), 'static/')

urlpatterns = patterns('',
    # Example:
    # (r'^server/', include('server.foo.urls')),
    (r'^$', 'app.views.index'),
    (r'^upload/$', 'app.views.upload'),
    (r'^worksheet/$', 'app.views.worksheet'),

    (r'^(?P<path>.*)$', 'django.views.static.serve', {'document_root': p}),
)

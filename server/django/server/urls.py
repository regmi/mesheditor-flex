from django.conf.urls.defaults import *
# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

import os.path
p = os.path.join(os.path.dirname(__file__), 'media/')

urlpatterns = patterns('',
    # Example:
    # (r'^server/', include('server.foo.urls')),
    (r'^$', 'app.views.index'),
    (r'^upload/$', 'app.views.upload'),

    (r'^(?P<path>.*)$', 'django.views.static.serve',
        {'document_root': p}),

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # (r'^admin/', include(admin.site.urls)),
)

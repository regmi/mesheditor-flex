#!/usr/bin/python
"""
Mesheditor server.
"""

import logging, os
from wsgiref import simple_server

import pyamf
from pyamf import amf3
from pyamf.remoting.gateway.wsgi import WSGIGateway

#: Host and port to run the server on
host_info = ('localhost', 8000)

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(levelname)-5.5s [%(name)s] %(message)s')

class MeshService(object):
    """
    Provide Mesh related services.
    """
    def __init__(self):
        pass

    def saveMesh(self, xmlData):
        """
        Save the mesh drawn in client side in a file.
        """
        f = open("meshfile.xml", "w")
        f.write(xmlData)
        f.close()

        return True

class EchoService(object):
    """
    Provide a simple server for testing.
    """
    def echo(self, data):
        """
        Return data with chevrons surrounding it.
        """
        return '<<%s>>' % data

class CrossdomainMiddleware(object):
    """
    """

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        if environ['PATH_INFO'] == '/crossdomain.xml':
            fn = os.path.join(os.getcwd(), os.path.dirname(__file__),
               'crossdomain.xml')

            fp = open(fn, 'rt')
            buffer = fp.readlines()
            fp.close()

            start_response('200 OK', [
                ('Content-Type', 'application/xml'),
                ('Content-Length', str(len(''.join(buffer))))
            ])

            return buffer

        return self.app(environ, start_response)

def main():
    """
    Create a WSGIGateway application and serve it.
    """

    # our gateway will have two services
    services = { 'echo': EchoService, 'mesh': MeshService }

    # setup our server
    application = CrossdomainMiddleware(WSGIGateway(services, logger=logging))
    httpd = simple_server.WSGIServer(host_info, simple_server.WSGIRequestHandler)
    httpd.set_app(application)

    try:
        # open for business
        print "Running Mesheditor PyAMF gateway on http://%s:%d" % (
            host_info[0], host_info[1])
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option("-p", "--port", default=host_info[1],
        dest="port", help="port number [default: %default]")
    parser.add_option("--host", default=host_info[0],
        dest="host", help="host address [default: %default]")
    (options, args) = parser.parse_args()

    host_info = (options.host, options.port)

    # now we rock the code
    main()

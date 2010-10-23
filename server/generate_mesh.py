#!/usr/bin/env python
import cgi, cgitb
from femhub import Domain, Mesh

cgitb.enable()

form = cgi.FieldStorage()
if form.has_key('nodes') and form['nodes'] != '':

    print "Content-type: text/xml\n"

    node_list = []
    edge_list = []

    for n in form['nodes'].value.split(','):
        if(len(n)!=0):
            xy = n.split(' ')
            node_list.append((float(xy[0]),float(xy[1])))

    for b in form['boundaries'].value.split(','):
        if(len(b)!=0):
            xyz = b.split(' ')
            edge_list.append([int(xyz[0]),int(xyz[1]),int(xyz[2]),int(xyz[3])])

    d = Domain(node_list, [(edge[0], edge[1]) for edge in edge_list])
    m = d.triangulate()
    m._boundaries = edge_list

    xml = "<?xml version='1.0' encoding='UTF-8'?>"
    xml += "<mesheditor>"

    xml += "<vertices>"
    for i,n in enumerate(m._nodes):
        xml += "<vertex id='" + str(i) + "'>"
        xml += "<x>" + str(n[0]) + "</x><y>" + str(n[1]) + "</y>"
        xml += "</vertex>"
    xml += "</vertices>"

    xml += "<elements>"
    for i,e in enumerate(m._elements):
        xml += "<element id='" + str(i) + "'>"
        for j, v in enumerate(e):
            xml += "<v" + str(j + 1) + ">" + str(v) + "</v" + str(j + 1) + ">"
        xml += "<material>0</material>"
        xml += "</element>"
    xml += "</elements>"

    xml += "<boundaries>"
    for i,b in enumerate(m._boundaries):
        xml += "<boundary id='" + str(i) + "'>"
        for j,v in enumerate(b):
            if j<2:
                xml += "<v" + str(j + 1) + ">" + str(v) + "</v" + str(j + 1) + ">"
        xml += "<marker>" + str(b[2]) + "</marker>"
        xml += "<angle>" + str(b[3]) + "</angle>"
        xml += "</boundary>"
    xml += "</boundaries>"

    xml += "</mesheditor>"
    print xml

else:
    print "Content-type: text/html\n"
    print """<title>Triangulation...</title>
    <h1>Auto Triangulation</h1>
    <form method='GET' action='http://hpfem.org/~aayush/cgi-bin/generate_mesh.py'>
    <p>Nodes: <input type='text' name='nodes'>
    <p>Boundaries: <input type='text' name='boundaries'>
    <p><input type='submit' value='Submit'>
    </form>
    """
